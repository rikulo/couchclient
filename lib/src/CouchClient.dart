part of rikulo_memcached;

abstract class CouchClient implements MemcachedClient {
  /**
   * Create a DesignDoc and put into Couchbase; asynchronously return true
   * if succeed.
   */
  Future<bool> putDesignDoc(DesignDoc doc);

  /**
   * Delete the named DesignDoc.
   */
  Future<bool> deleteDesignDoc(String docName);

  /**
   * Retrieve the named DesignDoc.
   */
  Future<DesignDoc> getDesignDoc(String docName);

  /**
   * Retrieve the named View in the named DesignDoc.
   */
  Future<View> getView(String docName, String viewName);

  /**
   * Retrieve the named SpatialView in the named DesignDoc.
   */
  Future<SpatialView> getSpatialView(String docName, String viewName);

  /**
   * query data from the couchbase with the spcified View(can be View or
   * SpatialView) and query condition.
   */
  Future<ViewResponse> query(AbstractView view, Query query);

  static Future<CouchClient> connect(CouchbaseConnectionFactory factory)
  => _CouchClientImpl.connect(factory);
}

class _CouchClientImpl extends _MemcachedClientImpl implements CouchClient {
  ViewConnection _viewConn;
  CouchbaseConnectionFactory _connFactory;

  static Future<CouchClient> connect(CouchbaseConnectionFactory factory) {
    Future<Config> configf = factory.vbucketConfig;
    return configf.then((config) {
      ViewConnection viewConn = null;
      List<SocketAddress> saddrs = _toSocketAddresses(config.servers);
      if (config.configType == ConfigType.COUCHBASE) {
        List<SocketAddress> uaddrs = _toSocketAddressesFromUri(config.couchServers);
        viewConn = factory.createViewConnection(uaddrs);
      }
      return factory.createConnection(saddrs)
        .then((conn) => new _CouchClientImpl(viewConn, conn, factory));
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

  _CouchClientImpl(ViewConnection viewConn, CouchbaseConnection memcachedConn,
                   CouchbaseConnectionFactory connFactory)
      : _viewConn = viewConn,
        _connFactory = connFactory,
        super(memcachedConn, connFactory) {

    _logger = initLogger('couchbase', this);
  }

  Future<bool> putDesignDoc(DesignDoc doc) {
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

  Future<ViewResponse> query(AbstractView view, Query query) {
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

  Future<ViewResponseWithDocs> _queryWithDocs(AbstractView view, Query query) {
    WithDocsOP op = new WithDocsOP(view, query);
    _handleHttpOperation(op);
    Completer<ViewResponseWithDocs> cmpl = new Completer();
    op.future.then((vr) {
      List<String> ids = new List();
      for (ViewRowNoDocs row in vr.rows) {
        ids.add(row.id);
      }
      Map<String, GetResult> results = new HashMap();
      //TODO: Need to handle retrieve with 'bucket'!
      Stream<GetResult> st = getAll(ids);
      st.listen((data) {
        results[data.key] = data;
      },
      onError: (err) => print(err),
      onDone: () {
        List<ViewRowWithDocs> docs = new List();
        for (ViewRowNoDocs r in vr.rows) {
          docs.add(new ViewRowWithDocs(r.id, r.key, r.value, results[r.id]));
        }
        cmpl.complete(new ViewResponseWithDocs(docs, vr.errors, results));
      });
    });
    return cmpl.future;
  }

  Future<ViewResponseNoDocs> _queryNoDocs(AbstractView view, Query query) {
    NoDocsOP op = new NoDocsOP(view, query);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<ViewResponseReduced> _queryReduced(AbstractView view, Query query) {
    ReducedOP op = new ReducedOP(view, query);
    _handleHttpOperation(op);
    return op.future;
  }

  void _handleHttpOperation(HttpOP op) {
    _viewConn.addOP(op);
  }
}

const int _FREQ = 0; //operation process timer frequency