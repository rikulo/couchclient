//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

class CouchClientImpl extends MemcachedClientImpl implements CouchClient {
  RestClient _restClient;
  ViewConnection _viewConn;
  CouchbaseConnectionFactory _connFactory;
  Logger _logger;

  static Future<CouchClient> connect(CouchbaseConnectionFactory factory) {
    return factory.vbucketConfig.then((config) {
      ViewConnection viewConn = null;
      List<SocketAddress> saddrs =
          HttpUtil.parseSocketAddressesFromStrings(config.servers);
      if (config.configType == ConfigType.COUCHBASE) {
        List<SocketAddress> uaddrs = _toSocketAddressesFromUri(config.couchServers);
        viewConn = factory.createViewConnection(uaddrs);
      }
      return factory.createConnection(saddrs)
      .then((conn) => new CouchClientImpl(viewConn, conn, factory))
      .then((client) {
        return factory.configProvider.subscribe(factory.bucketName, client)
        .then((ok) => client);
      });
    });
  }

  static List<SocketAddress> _toSocketAddressesFromUri(List<Uri> uris) {
    List<SocketAddress> saddrs = HttpUtil.parseSocketAddressesFromUris(uris);
    if (saddrs.isEmpty)
      throw new ArgumentError("servers cannot be empty");

    return saddrs;
  }

  CouchClientImpl(ViewConnection viewConn, CouchbaseConnection memcachedConn,
                   CouchbaseConnectionFactory connFactory)
      : _viewConn = viewConn,
        _connFactory = connFactory,
        super(memcachedConn, connFactory) {

    _logger = initLogger('couchclient', this);
  }

  CouchbaseConnectionFactory get connectionFactory => _connFactory;

  Future<bool> addDesignDoc(DesignDoc doc) {
    PutDesignDocOP op = new PutDesignDocOP(_connFactory.bucketName, doc.name, doc.toJson());
    _handleHttpOperation(op);
    return op.future;
  }

  Future<bool> deleteDesignDoc(String docName) {
    DeleteDesignDocOP op = new DeleteDesignDocOP(_connFactory.bucketName, docName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<DesignDoc> getDesignDoc(String docName) {
    GetDesignDocOP op = new GetDesignDocOP(_connFactory.bucketName, docName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<View> getView(String docName, String viewName) {
    GetViewOP op = new GetViewOP(_connFactory.bucketName, docName, viewName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<SpatialView> getSpatialView(String docName, String viewName) {
    GetSpatialViewOP op = new GetSpatialViewOP(_connFactory.bucketName, docName, viewName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<ViewResponse> query(ViewBase view, Query query) {
    if (view.hasReduce && !query.args.containsKey('reduce')) {
      query.reduce = true;
    }

    if (query.willReduce) {
      return _queryReduced(view, query);
    } else if (query.includeDocs) {
      return _queryWithDocs(view, query);
    } else {
      return _queryNoDocs(view, query);
    }
  }

  Future<Map<SocketAddress, ObserveResult>> observe(String key, [int cas]) {
    return _connFactory.vbucketConfig
    .then((Config cfg) {
       VbucketNodeLocator vlocator = locator;
       int vb = vlocator.getVbucketIndex(key);
       List<MemcachedNode> nodes = new List();
       MemcachedNode primary = vlocator.getServerByIndex(cfg.getMaster(vb));
       nodes.add(primary);
       for (int j = 0, repCount = cfg.replicasCount; j < repCount; ++j) {
         int replica = cfg.getReplica(vb, j);
         if (replica >= 0)
           nodes.add(vlocator.getServerByIndex(replica));
       }
       return handleBroadcastOperation(() =>
           opFactory.newObserveOP(key, cas), nodes.iterator)
       .then((results) {
         results[primary.socketAddress].isPrimary = true;
         return results;
       });
    });
  }

  Future<bool> observePoll(String key, {
      int cas,
      PersistTo persistTo: PersistTo.ZERO,
      ReplicateTo replicateTo: ReplicateTo.ZERO,
      bool isDelete: false}) {

    final Completer<bool> cmpl = new Completer();
    _connFactory.checkConfigAgainstDurability(persistTo, replicateTo)
    .then((_) => _connFactory.vbucketConfig)
    .then((cfg) {
      final int numPersistReplica = persistTo.value > 0 ? persistTo.value - 1 : 0;
      final int numReplica = replicateTo.value;
      final bool isPersistMaster = persistTo.value > 0;
      VbucketNodeLocator vlocator = locator;

      _checkObserveReplica(key, numPersistReplica, numReplica, cfg, vlocator);

      if (numReplica <= 0 && numPersistReplica <= 0 && !isPersistMaster) {
        cmpl.complete(true);
      } else {
        final int obsPolls = 0;
        final int obsPollMax = _connFactory.observePollMax;
        final Duration obsPollInterval =
            new Duration(milliseconds: _connFactory.observePollInterval);

        _observePoll0(
            cmpl,
            key,
            cas,
            isDelete,
            cfg,
            vlocator,
            numReplica,
            numPersistReplica,
            isPersistMaster,
            obsPolls,
            obsPollMax,
            obsPollInterval);
      }
    })
    .catchError((err) => cmpl.completeError(err));

    return cmpl.future;
  }

  RestClient get restClient {
    if (_restClient == null) {
      _restClient = new RestClientImpl(_connFactory);
    }
    return _restClient;
  }

  void close() {
    if (isClosing) return;
    super.close();
    //TODO(20130605,henrichen): Shutdown the monitor channel
    _connFactory.configProvider.shutdown();
  }

  void _observePoll0(
      Completer cmpl,
      String key,
      int cas,
      bool isDelete,
      Config cfg,
      VbucketNodeLocator vlocator,
      int numReplica,
      int numPersistReplica,
      bool isPersistMaster,
      int obsPolls,
      int obsPollMax,
      Duration obsPollInterval) {

    _checkObserveReplica(key, numPersistReplica, numReplica, cfg, vlocator);

    this.observe(key, cas)
    .then((response) {
      int vb = vlocator.getVbucketIndex(key);
      MemcachedNode master = vlocator.getServerByIndex(cfg.getMaster(vb));

      int observePersistReplica = 0;
      int observeReplica = 0;
      bool observePersistMaster = false;
      for (SocketAddress node in response.keys) {
        final bool isMaster = node == master.socketAddress;
        final ObserveStatus status = response[node].status;
        if (isMaster && status == ObserveStatus.MODIFIED) {
          throw new ObservedModifiedException("Key was modified");
        }
        if (!isDelete) {
          if (!isMaster && status == ObserveStatus.NOT_PERSISTED) {
            observeReplica++;
          } else if (status == ObserveStatus.PERSISTED) {
            if (isMaster) {
              observePersistMaster = true;
            } else {
              observeReplica++;
              observePersistReplica++;
            }
          }
        } else {
//TODO(20130520, henrichen): The following code is from Couchbase Java client
//  but the program logic is strange to me, so I rewrite it to be symetric to
//  of isDelete is false.
//          if (status == ObserveStatus.LOGICALLY_DELETED) {
//            observeReplica++;
//          } else if (status == ObserveStatus.NOT_FOUND) {
//            observeReplica++;
//            observePersistReplica++;
//            if (isMaster) {
//              obervePersistMaster = true;
//            } else {
//              observePersistReplica++;
//            }
//          }
          if (!isMaster && status == ObserveStatus.LOGICALLY_DELETED) {
            observeReplica++;
          } else if (status == ObserveStatus.NOT_FOUND) {
            if (isMaster) {
              observePersistMaster = true;
            } else {
              observeReplica++;
              observePersistReplica++;
            }
          }
        }
      }

      if (numReplica <= observeReplica
          && numPersistReplica <= observePersistReplica
          && (observePersistMaster || !isPersistMaster)) {
        cmpl.complete(true);
      } else {
        if (++obsPolls >= obsPollMax) {
          int timeTried = obsPollMax * obsPollInterval.inMilliseconds;
          throw new ObservedTimeoutException("Observe Timeout - Polled"
              " Unsuccessfully for at least $timeTried milliseconds.");
        }

        return new Future.delayed(obsPollInterval)
        .then((_) =>
            _observePoll0( //recursive
                cmpl,
                key,
                cas,
                isDelete,
                cfg,
                vlocator,
                numReplica,
                numPersistReplica,
                isPersistMaster,
                obsPolls,
                obsPollMax,
                obsPollInterval)
        );
      }
    })
    .catchError((err) => cmpl.completeError(err));
  }

  void _checkObserveReplica(String key, int numPersist, int numReplica,
                            Config cfg, VbucketNodeLocator locator) {
    if(numReplica > 0) {
      int vbucketIndex = locator.getVbucketIndex(key);
      int currentReplicaNum = cfg.getReplica(vbucketIndex, numReplica - 1);
      if (currentReplicaNum < 0) {
        throw new ObservedException("Currently, there is no replica available "
            "for the given replica index. This can be the case because of a "
            "failed over node which has not yet been rebalanced.");
      }
    }

    int replicaCount = math.min(locator.allNodes.length - 1, cfg.replicasCount);

    if (numReplica > replicaCount) {
      throw new ObservedException("Requested replication to $numReplica"
          " node(s), but only $replicaCount are avaliable");
    } else if (numPersist > replicaCount + 1) {
      throw new ObservedException("Requested persistence to $numPersist"
          " node(s), but only (${replicaCount + 1}) are available.");
    }
  }

  Future<ViewResponseWithDocs> _queryWithDocs(ViewBase view, Query query) {
    WithDocsOP op = new WithDocsOP(view, query);
    _handleHttpOperation(op);
    Completer<ViewResponseWithDocs> cmpl = new Completer();
    op.future.then((vr) {
      List<String> ids = new List();
      for (ViewRowNoDocs row in vr.rows) {
        ids.add(row.id);
      }
      _logger.finest("--->ids:$ids");
      Map<String, GetResult> results = new HashMap();
      if (ids.isEmpty) {
        cmpl.complete(new ViewResponseWithDocs([], [], results));
      } else {
        Stream<GetResult> st = getAll(ids);
        st.listen(
          (data) {
            results[data.key] = data;
            _logger.finest("data:${data.key}");
          },
          onError: (err) => print(err),
          onDone: () {
            List<ViewRowWithDocs> docs = new List();
            for (ViewRowNoDocs r in vr.rows) {
              docs.add(new ViewRowWithDocs(r.id, r.key, r.value, results[r.id]));
            }
            cmpl.complete(new ViewResponseWithDocs(docs, vr.errors, results));
          }
        );
      }
    });
    return cmpl.future;
  }

  Future<ViewResponseNoDocs> _queryNoDocs(ViewBase view, Query query) {
    NoDocsOP op = new NoDocsOP(view, query);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<ViewResponseReduced> _queryReduced(ViewBase view, Query query) {
    ReducedOP op = new ReducedOP(view, query);
    _handleHttpOperation(op);
    return op.future;
  }

  void _handleHttpOperation(HttpOP op) {
    _viewConn.addOP(op);
  }

//--Reconfigurable--//
  bool _reconfiguring = false;
  void reconfigure(Bucket bucket) {
    if (_reconfiguring) return;
    try {
      _reconfiguring = true;
      if (bucket.isNotUpdating) {
        _logger.info("Bucket configuration is disconnected from cluster "
            "configuration updates, attempting to reconnect.");
        _connFactory.requestConfigReconnect(_connFactory.bucketName, this);
        _connFactory.checkConfigUpdate();
      }
      _connFactory.configProvider.buckets[_connFactory.bucketName] = bucket;

      if(_viewConn != null) {
        _viewConn.reconfigure(bucket);
      }
      if (memcachedConn is Reconfigurable) {
        (memcachedConn as Reconfigurable).reconfigure(bucket);
      }
    } finally {
      _reconfiguring = false;
    }
  }
}

const int _FREQ = 0; //operation process timer frequency