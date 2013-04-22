//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

class CouchbaseConnectionFactory extends BinaryConnectionFactory {
  /**
   * Specify a default minimum reconnect interval of 1.1s.
   *
   * This means that if a reconnect is needed, it won't try to reconnect
   * more frequently than 1.1s between tries.  The initial HTTP connections
   * under us take up to 500ms per request.
   */
  static const int DEFAULT_MIN_RECONNECT_INTERVAL = 1100;

  /**
   * Default View request timeout in ms.
   */
  static const int DEFAULT_VIEW_TIMEOUT = 75000;

  /**
   * Default Observe poll interval in ms.
   */
  static const int DEFAULT_OBS_POLL_INTERVAL = 100;

  /**
   * Default maximum amount of poll cycles before failure.
   */
  static final int DEFAULT_OBS_POLL_MAX = 400;

  String _bucket;
  String _password;
  final AuthDescriptor _authDescriptor;

  Logger _logger;
  ConfigProvider _configProvider;
  int _configProviderLastUpdateTimestamp;
  bool _needReconnect = false;
  bool _doingResubscribe = false;
  List<Uri> _storedBaseList;
  int _viewTimeout = DEFAULT_VIEW_TIMEOUT;
  //maximum allowed checks before we reconnect in a 10 sec interval
  int _maxConfigCheck = 10;
  bool _needsReconnect = false;
  int _thresholdLastCheck = new DateTime.now().millisecondsSinceEpoch;
  int _configThresholdCount = 0;

  /**
   * minimum reconnect interval in milliseconds.
   */
  int minReconnectInterval = DEFAULT_MIN_RECONNECT_INTERVAL;
  int obsPollInterval = DEFAULT_OBS_POLL_INTERVAL;
  int obsPollMax = DEFAULT_OBS_POLL_MAX;

  CouchbaseConnectionFactory(List<Uri> baseList, String bucket, String password)
      : _viewTimeout = 75000,
        _authDescriptor = new AuthDescriptor(["PLAIN"], bucket, password),
        super(KETAMA_HASH) {

    _logger = initLogger('couchbase', this);
    _bucket = _authDescriptor.bucket;
    _password = _authDescriptor.password;
    _storedBaseList = new List();
    for(Uri bu in baseList) {
      if (!bu.isAbsolute)
        throw new ArgumentError('The base Uri must be absolute');
      _storedBaseList.add(bu);
    }
    _configProvider = new ConfigProvider(baseList, _bucket, _password);
  }

  //@Override
  Future<MemcachedConnection> createConnection(List<SocketAddress> saddrs) {
    return new Future.sync(() {
      List<MemcachedNode> nodes = createNodes(saddrs);
      return createLocator(nodes).then((locator) {
        return vbucketConfig.then((config) {
          if (config.configType == ConfigType.MEMCACHE) {
            return new CouchbaseMemcachedConnection(locator, this, opFactory, failureMode);
          } else if (config.configType == ConfigType.COUCHBASE) {
            return new CouchbaseConnection(locator, this, opFactory, failureMode);
          }
          throw new StateError('No ConnectionFactory for the specified bucket type'
                '"${config.configType}"');
        });
      });
    });
  }

  //@Override
  Future<NodeLocator> createLocator(List<MemcachedNode> nodes) {
    return vbucketConfig.then((config) {
      if (config == null)
        throw new StateError("Couldn't get config");

      if (config.configType == ConfigType.MEMCACHE)
        return new KetamaNodeLocator(nodes, KETAMA_HASH);
      else if (config.configType == ConfigType.COUCHBASE)
        return new VbucketNodeLocator(nodes, config);
      else
        throw new StateError('Unhandled locator type: $config.configType');
    });
  }

  //@Override
  FailureMode get failureMode => FailureMode.Retry;

  //@Override
  AuthDescriptor get authDescriptor => _authDescriptor;

  String get bucketName => _bucket;

  int get viewTimeout => _viewTimeout;

  Future<Config> get vbucketConfig {
    return _configProvider.getBucketConfig(_bucket).then((bucketConfig) {
      if (bucketConfig == null)
        throw new StateError("Could not fetch valid configuration "
            "from provided nodes. Stopping.");
      else if (bucketConfig.isNotUpdating) {
        _logger.warning("Noticed bucket configuration to be disconnected, "
            "will attempt to reconnect");
        configProvider = new ConfigProvider(_storedBaseList, _bucket, _password);
      }
      return _configProvider
          .getBucketConfig(_bucket)
          .then((bucket) => bucket.config);
    });
  }

  ViewNode createViewNode(SocketAddress saddr) =>
      new ViewNode(saddr, opTimeout, authDescriptor.bucket,
                   authDescriptor.password);

  ViewConnection createViewConnection(List<SocketAddress> saddrs) =>
      new ViewConnection(saddrs, this);

  ConfigProvider get configProvider => _configProvider;

  void set configProvider(ConfigProvider configProvider) {
    _configProvider = configProvider;
    _configProviderLastUpdateTimestamp = new DateTime.now().millisecondsSinceEpoch;
  }

  void requestConfigReconnect(String bucket, Reconfigurable reconfig) {
    configProvider.markForResubscribe(bucket, reconfig);
    _needReconnect = true;
  }

  /**
   * Checks whether we have enough nodes for requested persistence.
   */
  Future<bool> checkConfigAgainstPersistence(PersistTo pers) {
    return vbucketConfig.then((config) {
      int nodeCount = config.serversCount;
      if(pers.value > nodeCount) {
        _logger.fine("Currently, there are less nodes in the "
          "cluster than required to satisfy the persistence constraint.");
        return false;
      }
      return true;
    });
  }

  /**
   * Checks whether we have enough nodes for requested replication.
   */
  Future<bool> checkConfigAgainstReplication(ReplicateTo repl) {
    return vbucketConfig.then((config) {
      int nodeCount = config.serversCount;
      if(repl.value >= nodeCount) {
        _logger.fine("Currently, there are less nodes in the "
          "cluster than required to satisfy the replication constraint.");
        return false;
      }
      return true;
    });
  }

  /**
   * Check if a configuration update is needed.
   *
   * There are two main reasons that would trigger a configuration update.
   * Either there is a configuration update happening in the cluster, or
   * operations added to the queue and can not find their corresponding node.
   * For the latter, see the [#pastReconnThreshold()] method for further details.
   *
   * If a configuration update is needed, a resubscription for configuration
   * updates is triggered. Note that since reconnection takes some time,
   * the method will also wait a time period given by
   * [minReconnectInterval] before the resubscription is triggered.
   */
  void checkConfigUpdate() {
    if (_needsReconnect || pastReconnThreshold) {
      int now = new DateTime.now().millisecondsSinceEpoch;
      int intervalWaited = now - _configProviderLastUpdateTimestamp;
      if (intervalWaited < minReconnectInterval) {
        _logger.fine("Ignoring config update check. Only ${intervalWaited}ms out"
          " of a threshold of ${minReconnectInterval}ms since last update.");
        return;
      }

      if (!_doingResubscribe) {
        _doingResubscribe = true;
        resubscribeConfigUpdate();
      } else {
        _logger.config("Duplicate resubscribe for config updates suppressed.");
      }
    } else {
      _logger.fine("No reconnect required, though check requested. "
              "Current config check is ${_configThresholdCount} out of "
              "a threshold of ${_maxConfigCheck}.");
    }
  }

  /**
   * Resubscribe for configuration updates.
   */
  void resubscribeConfigUpdate() {
    _logger.info("Attempting to resubscribe for cluster config updates.");
    resubscribeProcess(0);
  }

  /**
   * Checks if there have been more requests than allowed through
   * maxConfigCheck in a 10 second period.
   *
   * If this is the case, then true is returned. If the timeframe between
   * two distinct requests is more than 10 seconds, a fresh timeframe starts.
   * This means that 10 calls every second would trigger an update while
   * 1 operation, then a 11 second sleep and one more operation would not.
   *
   * Returns true if there were more config check requests than maxConfigCheck
   * in the 10 second period.
   */
  bool get pastReconnThreshold {
    int currentTime = new DateTime.now().millisecondsSinceEpoch;

    if (currentTime - _thresholdLastCheck >= 10000) //more than 10 seconds
      _configThresholdCount = 0;

    _thresholdLastCheck = currentTime;
    return ++_configThresholdCount >= _maxConfigCheck;
  }

  /**
   * Returns the amount of how many config checks in a given time period
   * (currently 10 seconds) are allowed before a reconfiguration is triggered.
   */
  int get maxConfigCheck => _maxConfigCheck;

  /**
   * Resubscribe processing.
   */
  const int backoffTime = 1000;
  const int maxWaitTime = 10000;
  void resubscribeProcess(int reconnectAttempt) {
    int waitTime = (reconnectAttempt++)*backoffTime;
    if(reconnectAttempt >= 10)
      waitTime = maxWaitTime;
    _logger.info("Reconnect attempt ${reconnectAttempt}, waiting ${waitTime}ms");

    new Future.delayed(new Duration(milliseconds:waitTime))
    .then((_) {
      _logger.config("Resubscribing for ${_bucket} using base list "
      "${_storedBaseList}");

      ConfigProvider oldConfigProvider = configProvider;

      if (null != oldConfigProvider) {
        oldConfigProvider.shutdown();
      }

      ConfigProvider newConfigProvider
        = configProvider
        = new ConfigProvider(_storedBaseList, _bucket, _password);

      return newConfigProvider.subscribe(_bucket,
        oldConfigProvider == null ? null : oldConfigProvider.reconfigurable)
        .then((_) {
          if (_doingResubscribe)
            _doingResubscribe = false;
          else
            _logger.warning("Could not reset from doing a resubscribe.");
        });
    })
    .catchError((err) {
      _logger.warning("Resubscribe attempt failed: $err");
      resubscribeProcess(reconnectAttempt);
    });
  }

  /**
   * Returns a ClusterManager and initializes one if it does not exist.
   */
//  ClusterManager getClusterManager() {
//    if(clusterManager == null) {
//      clusterManager = new ClusterManager(_storedBaseList, _bucket, _pass);
//    }
//    return clusterManager;
//  }

}

