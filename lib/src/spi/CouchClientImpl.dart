//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

class CouchClientImpl extends MemcachedClientImpl implements CouchClient {
  ViewConnection _viewConn;
  CouchbaseConnectionFactory _connFactory;
  Logger _logger;

  static Future<CouchClient> connect(CouchbaseConnectionFactory factory) {
    return factory.vbucketConfig.then((config) {
      ViewConnection viewConn = null;
      List<SocketAddress> saddrs = _toSocketAddresses(config.servers);
      if (config.configType == ConfigType.COUCHBASE) {
        List<SocketAddress> uaddrs = _toSocketAddressesFromUri(config.couchServers);
        viewConn = factory.createViewConnection(uaddrs);
      }
      return factory.createConnection(saddrs)
        .then((conn) => new CouchClientImpl(viewConn, conn, factory));
    });
  }

  static List<SocketAddress> _toSocketAddressesFromUri(List<Uri> servers) {
    List<SocketAddress> saddrs = new List();
    for (Uri server in servers) {
      saddrs.add(new SocketAddress(server.domain, server.port));
    }
    if (saddrs.isEmpty)
      throw new ArgumentError("servers cannot be empty");

    return saddrs;
  }

  static List<SocketAddress> _toSocketAddresses(List<String> servers) {
    List<SocketAddress> saddrs = new List();
    for (String server in servers) {
      int colon = server.lastIndexOf(':');
      if (colon < 1)
        throw new ArgumentError('Invalid server "$server" in list: $servers');
      String host = server.substring(0, colon);
      String port = server.substring(colon+1);
      saddrs.add(new SocketAddress(host, int.parse(port)));
    }
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

  Future<Map<MemcachedNode, ObserveResult>> observe(String key, [int cas]) {
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
         results[primary].isPrimary = true;
         return results;
       });
    });
  }
//
//  Future<bool> observePoll(String key, int cas, PersistTo persist,
//      ReplicateTo replicate, bool delete) {
//    Completer cmpl = new Completer();
//
//    if (persist == null) {
//      persist = PersistTo.ZERO;
//    }
//    if (replicate == null) {
//      replicate = ReplicateTo.ZERO;
//    }
//    return _connFactory.checkConfigAgainstDurability(persist, replicate)
//    .then((ok) {
//      if (!ok) return false;
//
//      int persistReplica = persist.value > 0 ? persist.value - 1 : 0;
//      int replicateTo = replicate.value;
//      int obsPolls = 0;
//      int obsPollMax = _connFactory.observePollMax;
//      int obsPollInterval = _connFactory.observePollInterval;
//      bool persistMaster = persist.value > 0;
//      return _connFactory.vbucketConfig
//        .then((cfg) {
//          VbucketNodeLocator vlocator = locator;
//
//          if (!_checkObserveReplica(key, persistReplica, replicateTo, cfg, vlocator))
//            return false;
//
//          int replicaPersistedTo = 0;
//          int replicatedTo = 0;
//          bool persistedMaster = false;
//
//
//      while(replicateTo > replicatedTo || persistReplica - 1 > replicaPersistedTo
//          || (!persistedMaster && persistMaster)) {
//        if (!_checkObserveReplica(key, persistReplica, replicateTo, cfg, vlocator))
//          return false;
//
//        if (++obsPolls >= obsPollMax) {
//          long timeTried = obsPollMax * obsPollInterval;
//          TimeUnit tu = TimeUnit.MILLISECONDS;
//          throw new ObservedTimeoutException("Observe Timeout - Polled"
//              + " Unsuccessfully for at least " + tu.toSeconds(timeTried)
//              + " seconds.");
//        }
//
//        Map<MemcachedNode, ObserveResponse> response = observe(key, cas);
//
//        int vb = vlocator.getVBucketIndex(key);
//        MemcachedNode master = vlocator.getServerByIndex(cfg.getMaster(vb));
//
//        replicaPersistedTo = 0;
//        replicatedTo = 0;
//        persistedMaster = false;
//        for (Entry<MemcachedNode, ObserveResponse> r : response.entrySet()) {
//          boolean isMaster = r.getKey() == master ? true : false;
//          if (isMaster && r.getValue() == ObserveResponse.MODIFIED) {
//            throw new ObservedModifiedException("Key was modified");
//          }
//          if (!isDelete) {
//            if (!isMaster && r.getValue()
//              == ObserveResponse.FOUND_NOT_PERSISTED) {
//              replicatedTo++;
//            }
//            if (r.getValue() == ObserveResponse.FOUND_PERSISTED) {
//              if (isMaster) {
//                persistedMaster = true;
//              } else {
//                replicatedTo++;
//                replicaPersistedTo++;
//              }
//            }
//          } else {
//            if (r.getValue() == ObserveResponse.NOT_FOUND_NOT_PERSISTED) {
//              replicatedTo++;
//            }
//            if (r.getValue() == ObserveResponse.NOT_FOUND_PERSISTED) {
//              replicatedTo++;
//              replicaPersistedTo++;
//              if (isMaster) {
//                persistedMaster = true;
//              } else {
//                replicaPersistedTo++;
//              }
//            }
//          }
//        }
//        try {
//          Thread.sleep(obsPollInterval);
//        } catch (InterruptedException e) {
//          getLogger().error("Interrupted while in observe loop.", e);
//          throw new ObservedException("Observe was Interrupted ");
//        }
//    }
//  }
//
//  bool _checkObserveReplica(String key, int numPersist, int numReplica,
//                            Config cfg, VbucketNodeLocator locator) {
//    if(numReplica > 0) {
//      int vbucketIndex = locator.getVbucketIndex(key);
//      int currentReplicaNum = cfg.getReplica(vbucketIndex, numReplica - 1);
//      if (currentReplicaNum < 0) {
//        _logger.fine("Currently, there is no replica available "
//            "for the given replica index. This can be the case because of a "
//            "failed over node which has not yet been rebalanced.");
//        return false;
//      }
//    }
//
//    int replicaCount = math.min(locator.allNodes.length - 1, cfg.replicasCount);
//
//    if (numReplica > replicaCount) {
//      _logger.fine("Requested replication to " + numReplica
//          + " node(s), but only " + replicaCount + " are avaliable");
//      return false;
//    } else if (numPersist > replicaCount + 1) {
//      _logger.fine("Requested persistence to " + numPersist
//          + " node(s), but only " + (replicaCount + 1) + " are available.");
//      return false;
//    }
//
//    return true;
//  }

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
}

const int _FREQ = 0; //operation process timer frequency