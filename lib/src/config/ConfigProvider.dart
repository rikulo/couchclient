//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:31:09 PM
// Author: hernichen

part of couchclient;

class ConfigProvider {
  static const String DEFAULT_POOL_NAME = 'default';
  static const String ANONYMOUS_AUTH_BUCKET = 'default';

  static const String CLIENT_SPEC_VER = '1.0';

  Logger _logger;
  final List<Uri> baseList;
  String restUsr;
  String restPwd;
  Uri loadedBaseUri;
  Map<String, Bucket> buckets = new HashMap(); //bucketname -> Bucket
  ConfigParserJson configParser = new ConfigParserJson();
  Map<String, BucketMonitor> monitors = new HashMap();
  String reSubBucket;
  Reconfigurable reSubRec;

  ConfigProvider(List<Uri> baseList, [String user, String pass])
      : this.baseList = baseList,
        restUsr = user,
        restPwd = pass {
    _logger = initLogger('couchclient.config', this);
  }

  Future<Bucket> getBucketConfig(String bucketname) {
    return new Future.sync(() {
      if (bucketname == null || bucketname.trim().isEmpty)
        throw new ArgumentError("Bucket name can not be blank.");
      Bucket bucket = buckets[bucketname];
      if (bucket == null) {
        return _readPools(bucketname);
      } else {
        return new Future.value(bucket);
      }
    });
  }

  Future<List<SocketAddress>> getServerList(String bucketname) =>
      getBucketConfig(bucketname).then((Bucket bucket) =>
          HttpUtil.parseSocketAddresses(bucket.config.servers.join(' ')));

  Future<Config> getLastestConfig(String bucketname) =>
      getBucketConfig(bucketname).then((Bucket bucket) => bucket.config);

  String get anonymousAuthBucket => ANONYMOUS_AUTH_BUCKET;

  void finishResubscribe() {
    monitors.clear();
    subscribe(reSubBucket, reSubRec);
  }

  void markForResubscribe(String bucketName, Reconfigurable rec) {
    _logger.fine("Marking bucket ${bucketName} "
                 "for resubscribe with reconfigurable $rec");

    reSubBucket = bucketName;
    reSubRec = rec;
  }

  /**
   * Subscribe for config updates
   */
  Future<bool> subscribe(String bucketname, Reconfigurable rec) {
    return new Future.sync(() {
      if (null == bucketname || (null != reSubBucket
        && bucketname != reSubBucket)) {
        throw new ArgumentError("Bucket name cannot be null and must"
          " never be re-set to a new object.");
      }
      if (null == rec || (null != reSubRec && rec != reSubRec)) {
        throw new ArgumentError("Reconfigurable cannot be null and"
          " must never be re-set to a new object");
      }
      reSubBucket = bucketname;  // More than one subscriber, would be an error
      reSubRec = rec;

      _logger.fine("Subscribing an object for reconfiguration "
          "updates ${rec.runtimeType}");

      final Future<Bucket> f = getBucketConfig(bucketname);
      return f.then((bucket) {
        if (bucket == null) {
          throw new StateError("Could not get bucket Configuration for ${bucketname}");
        }
        ReconfigurableObserver obs = new ReconfigurableObserver(rec);
        BucketMonitor monitor = this.monitors[bucketname];
        if (monitor == null) {
          Uri streamingUri = bucket.streamingUri;
          monitor = new BucketMonitor(this.loadedBaseUri.resolveUri(streamingUri),
            bucket, this.restUsr, this.restPwd, configParser);
          this.monitors[bucketname] = monitor;
          monitor.addObserver(obs);
          monitor.startMonitor();
        } else {
          monitor.addObserver(obs);
        }
        return true;
      });
    });
  }

  /**
   * Unsubscribe from updates on a given bucket and reconfigurable.
   */
  void unsubscribe(String bucketname, Reconfigurable rec) {
    BucketMonitor monitor = this.monitors[bucketname];
    if (monitor != null) {
      monitor.deleteObserver(new ReconfigurableObserver(rec));
    }
  }

  /**
   * Shutdowns a monitor connections to the REST service.
   */
  void shutdown() {
    for (BucketMonitor monitor in monitors.values)
      monitor.shutdown();
  }

  /**
   * Returns the current Reconfigurable.
   */
  Reconfigurable get reconfigurable => reSubRec;

  /**
   * Returns the current bucket name.
   */
  String get bucket => reSubBucket;

  /**
   * Give a bucketname, walk the baseList until found the needed bucket.
   */
  Future<Bucket> _readPools(String bucketname) => _readPools0(bucketname, 0);

  Future<Bucket> _readPools0(String bucketname, int idx) {
    if (idx >= baseList.length) //none found
      return null;

    Uri baseUri = baseList[idx];
    return _readUri(null, baseUri, restUsr, restPwd)
    .then((String base) {
      if (base.trim().isEmpty) {
        return _readPools0(bucketname, idx+1); //check next Pool
      }
      Map<String, Pool> poolMap = configParser.parseBase(base);
      if (!poolMap.containsKey(DEFAULT_POOL_NAME)) {
        return _readPools0(bucketname, idx+1); //check next Pool
      }

      //Load basic information for each Pool
      List<Future<Pool>> poolfs = new List();
      for (Pool pool in poolMap.values) {
        Future<Pool> fpool = _readUri(baseUri, pool.uri, restUsr, restPwd)
        .then((String poolstr) {
          _logger.finest("pool->$poolstr");
          configParser.loadPool(pool, poolstr);
          return pool;
        });
        poolfs.add(fpool);
      }

      //Load Buckets information for each Pool
      //  after all pools loaded basic information
      return Future.wait(poolfs)
      .then((List<Pool> pools) {
        List<Future<Pool>> bucketsfs = new List();
        for (Pool pool in pools) {
          _logger.finest("pool.bucketsUri->${pool.bucketsUri}");
          Future<Pool> fpool = _readUri(baseUri, pool.bucketsUri, restUsr, restPwd)
          .then((String bucketsStr) {
            Map<String, Bucket> bucketsForPool =
                configParser.parseBuckets(bucketsStr);
            pool.replaceBuckets(bucketsForPool);
            return pool;
          });
          bucketsfs.add(fpool);
        }
        return Future.wait(bucketsfs);
      })
      .then((List<Pool> pools) {
        //check if found the named bucket among this set of pools
        //  after all pools loaded Buckets information
        bool bucketFound = false;
        for (Pool pool in pools) {
          if (pool.hasBucket(bucketname)) {
            bucketFound = true;
            break;
          }
        }
        //found the bucket, cache in the ConfigProvider
        if (bucketFound) {
          for (Pool pool in pools) {
            final Map robuckets = pool.currentBuckets;
            for (String key in robuckets.keys) {
              buckets[key] = robuckets[key];
            }
          }
          this.loadedBaseUri = baseUri;
          return buckets[bucketname]; //found the bucket, break out recursive loop
        } else {
          return _readPools0(bucketname, idx+1); //check next Pool
        }
      });
    });
  }

  Future<String> _readUri(Uri base, Uri resource, String usr, String pass) {
    Map<String, String> headers = new LinkedHashMap();
    headers[HttpHeaders.ACCEPT] = "application/json";
    headers[HttpHeaders.USER_AGENT] = "Couchbase Dart Client";
    headers["X-memcachekv-Store-Client-Specification-Version"] = CLIENT_SPEC_VER;
    HttpClient client = new HttpClient();
    return HttpUtil.uriGet(client, base, resource, usr, pass, headers)
    .then((result) {
      client.close();
      return result;
    });
  }
}

