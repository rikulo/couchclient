part of rikulo_memcached;

abstract class CouchClient extends MemcachedClient {
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

  factory CouchClient(String host, {int port:11211, String bucket:'default', String password, OPFactory factory})
  => new _CouchClientImpl(host, port, bucket, password, factory);
}

class _CouchClientImpl extends _MemcachedClientImpl implements CouchClient {
  Queue<HttpOP> _httpOPQueue;
  HttpOP _currentHttpOP;
  Uri baseUri;

  _CouchClientImpl(String host, int port,
      String bucketName, String password, OPFactory opFactory)
      : super(host, port, bucketName, password, opFactory) {
    _httpOPQueue = new Queue();
    baseUri = Uri.parse("http://$host:$port");
  }

  Future<bool> putDesignDoc(DesignDoc doc) {
    PutDesignDocOP op = new PutDesignDocOP(bucketName, doc.name, doc.toJson());
    _handleHttpOperation(op);
    return op.future;
  }

  Future<bool> deleteDesignDoc(String docName) {
    DeleteDesignDocOP op = new DeleteDesignDocOP(bucketName, docName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<DesignDoc> getDesignDoc(String docName) {
    GetDesignDocOP op = new GetDesignDocOP(bucketName, docName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<View> getView(String docName, String viewName) {
    GetViewOP op = new GetViewOP(bucketName, docName, viewName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<SpatialView> getSpatialView(String docName, String viewName) {
    GetSpatialViewOP op = new GetSpatialViewOP(bucketName, docName, viewName);
    _handleHttpOperation(op);
    return op.future;
  }

  Future<ViewResponse> query(AbstractView view, Query query) {
    if (view.hasReduce && !query.args.containsKey('reduce')) {
      query.setReduce(true);
    }

    if (query.willReduce) {
      return _queryReduced(view, query);
    } else if (query.willIncludeDocs) {
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
      Stream<GetResult> st = new MemcachedClient('localhost', bucket : bucketName, factory: new BinaryOPFactory()).getAll(ids);
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

  //enque operation into queue and kick start process if necessary
  void _handleHttpOperation(HttpOP op) {
    if (_toBeClose)
      throw new StateError("The client has been closed; no way to access the database.");

//TODO: for debug only
op.seq = seq++;
    if (_httpOPQueue.isEmpty) { // 0 -> 1, new a Timer as Operation process loop
      new Timer.repeating(new Duration(milliseconds:_FREQ), (Timer t) {
        print("Repeating timer\n");
        if (processHttp()) { //no more operation, cancel the Timer
          t.cancel();
          if (_toBeClose)
            _close0();
        }
      });
    }
    _httpOPQueue.add(op);
//    setupTimer();
  }

//  Timer _timer;
//  void setupTimer() {
//    if (_timer == null) {
//      _timer = Timer.run(() {
//        _timer.cancel();
//        _timer = null;
//        //_socket not ready yet or still operation to process, setup timer again!
//        if (!connected) {
//          print("Wait socket connect!");
//          setupTimer();
//        } else if (!processHttp()) {
//          print("Still operation to go!");
//          setupTimer();
//        }
//      });
//    }
//  }

  //process Operation in queue; return true to indicate no opeartion to process
  bool processHttp() {
    if (_currentHttpOP == null || _currentHttpOP.state == OPState.COMPLETE) { //previous operation is complete
      if (!_httpOPQueue.isEmpty) {
        _processHttp0(_currentHttpOP = _httpOPQueue.removeFirst());
      }
    }
    return _httpOPQueue.isEmpty; //no more to process
  }

  void _processHttp0(HttpOP op) {
    print("OPState.WRITING HTTP: $op\n");
    op.state = OPState.WRITING;
    Uri cmd = op.cmd;
    print("write http REST cmd: [${cmd}]");
    HttpClient hc = new HttpClient();
    Future<String> f = op.handleCommand(hc, baseUri, cmd, bucketName, password);
    f.then((String buf) {
      op.processResponse(buf);
//wait no response: we post the command and assume complete immediately
//      op.state = OPState.COMPLETE;
    });
    //wait no response: we post the command and assume complete
    op.state = OPState.COMPLETE; //wait no response: OPState.READING
  }
}

const int _FREQ = 0; //operation process timer frequency