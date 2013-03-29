//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of rikulo_memcached;

class CouchbaseConnectionFactory extends BinaryConnectionFactory {
  String _bucket;
  String _password;
  final AuthDescriptor _authDescriptor;

  Logger _logger;
  ConfigProvider _configProvider;
  int _configProviderLastUpdate;
  bool _needReconnect = false;
  List<Uri> _storedBaseList;
  int _viewTimeout;

  CouchbaseConnectionFactory(List<Uri> baseList, String bucket, String password)
      : _viewTimeout = 75000,
        _authDescriptor = new AuthDescriptor(["PLAIN"], bucket, password),
        super(KETAMA_HASH, FailureMode.Retry) {

    _logger = initLogger('couchbase', this);
    _bucket = _authDescriptor.bucket;
    _password = _authDescriptor.password;
    _storedBaseList = new List();
    for(Uri bu in baseList) {
      if (!bu.isAbsolute)
        throw new ArgumentError('The base Uri must be absolute');
      _storedBaseList.add(bu);
    }
    _configProvider = new ConfigProvider(baseList, authDescriptor.bucket, authDescriptor.password);
  }

  //@Override
  Future<MemcachedConnection> createConnection(List<SocketAddress> saddrs) {
    List<MemcachedNode> nodes = createNodes(saddrs);
    return createLocator(nodes)
    .then((locator) {
      Future<Config> configf = vbucketConfig;
      return configf.then((config) {
        if (config.configType == ConfigType.MEMCACHE) {
          return new CouchbaseMemcachedConnection(locator, this, opFactory, failureMode);
        } else if (config.configType == ConfigType.COUCHBASE) {
          return new CouchbaseConnection(locator, this, opFactory, failureMode);
        }
        throw new StateError('No ConnectionFactory for the specified bucket type'
            '"${config.configType}"');
      });
    });
  }

  //@Override
  Future<NodeLocator> createLocator(List<MemcachedNode> nodes) {
    Future<Config> configf = vbucketConfig;
    return configf.then((config) {
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
  AuthDescriptor get authDescriptor
  => _authDescriptor;

  String get bucketName
  => _bucket;

  int get viewTimeout
  => _viewTimeout;

  Future<Config> get vbucketConfig {
    Future<Bucket> bucketConfigf = _configProvider.getBucketConfig(_bucket);
    return bucketConfigf.then((bucketConfig) {
      if (bucketConfig == null)
        throw new StateError("Could not fetch valid configuration "
            "from provided nodes. Stopping.");
      else if (bucketConfig.isNotUpdating) {
        _logger.warning("Noticed bucket configuration to be disconnected, "
            "will attempt to reconnect");
        setupConfigProvider(new ConfigProvider(_storedBaseList, _bucket, _password));
      }
      return _configProvider
          .getBucketConfig(_bucket)
          .then((bucket) => bucket.config);
    });
  }

  ViewNode createViewNode(SocketAddress saddr)
  => new ViewNode(saddr, opTimeout, authDescriptor.bucket, authDescriptor.password);

  ViewConnection createViewConnection(List<SocketAddress> saddrs)
  => new ViewConnection(saddrs, this);

  ConfigProvider get configProvider
  => _configProvider;

  void setupConfigProvider(ConfigProvider configProvider) {
    _configProvider = configProvider;
    _configProviderLastUpdate = new DateTime.now().millisecondsSinceEpoch;
  }

  //TODO: Reconfiguration
//  void requestConfigReconnect(String bucket, Reconfiguable reconfig) {
//    configProvider.markForResubscribe(bucket, reconfig);
//    _needReconnect = true;
//  }


}

