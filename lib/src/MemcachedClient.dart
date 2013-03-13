part of rikulo_memcached;

abstract class MemcachedClient {

  /**
   * Set unconditinally the specified document. Returns
   * true if succeed; throw Error status otherwise.
   */
  Future<bool> set(String key, List<int> document, [int cas]);

  /**
   * Add specified document if the provided key is not existed yet. Returns
   * true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> add(String key, List<int> document);

  /**
   * Replace the existing document of the provided key with the specified byte
   * array. Returns true if succeed; otherwise, throw
   * OPStatus.NOT_STORED or other Error status.
   */
  Future<bool> replace(String key, List<int> document);

  /**
   * Prepend byte array in front of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> prepend(String key, List<int> prepend);

  /**
   * append byte array at the rear of the existing document of the provided key.
   * Returns true if succeed; otherwise, throw OPStatus.NOT_STORED or
   * other Error status.
   */
  Future<bool> append(String key, List<int> document);

  /**
   * Delete the specified key; return true if succeed. Otherwise,
   * throws OPStatus.NOT_FOUND or other errors.
   */
  Future<bool> delete(String key);

  /**
   * Increment the docuemnt(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status.
   */
  Future<int> increment(String key, int by);

  /**
   * Decrement the document(must be an integer) by the provided [by] value.
   * Returns the result integer; otherwise, throw OPStatus.NOT_FOUND or other
   * error status.
   */
  Future<int> decrement(String key, int by);

  /**
   * Get document as a GetResult of the provided key. If you need cas token
   * to avoid racing when setting the document of the key, please use gets API.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> get(String key);

  /**
   * Get list of documents as a Stream of [GetResult]. If you need cas token
   * to avoid racing when setting the document of the key, please use getsAll
   * API. This API returns a Stream of GetResult per the provided key list;
   * return an empty Stream if none of the doucment of the provided key exists.
   */
  Stream<GetResult> getAll(List<String> keys);

  /**
   * Get document as a GetResult of the provided key with cas token. The cas
   * token can be used to avoid racing when setting the document of the key.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> gets(String key);

  /**
   * Get list of documents with cas tokens as a Stream of [GetResult]. The
   * cas token can be used to avoid racing when setting the document of the key.
   * This API returns a Stream of GetResult per the provided key list;
   * return an empty Stream if none of the doucment of the provided key exists.
   */
  Stream<GetResult> getsAll(List<String> keys);

  /** Touch document expiration time in seconds. 0 means permenent.
   * If exptime exceeds 30 days(30*24*60*60), it is deemed as an
   * absolute date in seconds. Returns true if succeed; othewise,
   * throw OPStatus.NOT_FOUND or other Error status.
   */
  Future<bool> touch(String key, int exptime);

  /**
   * Returns the version of the connected server. Returns version as a String.
   */
  Future<String> version();

  /**
   * Close this memcached client.
   */
  void close();

  factory MemcachedClient(String host, {int port:11211, String bucket:'default', String password, OPFactory factory})
  => new _MemcachedClientImpl(host, port, bucket, password, factory);

}

class _MemcachedClientImpl implements MemcachedClient {
  Socket _socket;
  bool connected = false;
  Queue<OP> _opQueue;
  bool _toBeClose = false;
  OP _currentOp;
  int seq = 0;
  OPFactory _factory;
  final String bucketName;
  final String password;

  _MemcachedClientImpl(String host, int port, String bucketName, String password,
      [OPFactory factory])
      : this.bucketName = bucketName,
        this.password = password {
    _factory = factory != null ? factory : new TextOPFactory();
    _opQueue = new Queue();
    Socket.connect(host, port)
          .then((Socket socket) {
            _socket = socket;
            setupResponseHandler();
            connected = true;
          });
  }

  void close() {
    if (_opQueue.isEmpty)
      _close0();
    else
      //cannot close socket until opQueue is processed
      _toBeClose = true;
  }

  /** set command */
  Future<bool> set(String key, List<int> doc, [int cas])
  => _store(OPType.set, key, 0, 0, doc, cas);

  /** add command */
  Future<bool> add(String key, List<int> doc)
  => _store(OPType.add, key, 0, 0, doc);

  /** replace command */
  Future<bool> replace(String key, List<int> doc)
  => _store(OPType.replace, key, 0, 0, doc);

  /** prepend command */
  Future<bool> prepend(String key, List<int> doc)
  => _store(OPType.prepend, key, 0, 0, doc);

  /** append command */
  Future<bool> append(String key, List<int> doc)
  => _store(OPType.append, key, 0, 0, doc);

  Future<bool> _store(OPType type, String key, int flags, int exp, List<int> doc, [int cas, bool noreply]) {
    StoreOP op = _factory.newStoreOP(type, key, flags, exp, doc, cas);
    _handleOperation(op);
    return op.future;
  }

  /** touch command */
  Future<bool> touch(String key, int exp, [bool noreply]) {
    TouchOP op = _factory.newTouchOP(key, exp);
    _handleOperation(op);
    return op.future;
  }

  /** delete command */
  Future<bool> delete(String key) {
    DeleteOP op = _factory.newDeleteOP(key);
    _handleOperation(op);
    return op.future;
  }

  /** increment command */
  Future<int> increment(String key, int value) {
    MutateOP op = _factory.newMutateOP(OPType.incr, key, value);
    _handleOperation(op);
    return op.future;
  }

  /** decrement command */
  Future<int> decrement(String key, int value) {
    MutateOP op = _factory.newMutateOP(OPType.decr, key, value);
    _handleOperation(op);
    return op.future;
  }

  /** version command */
  Future<String> version() {
    VersionOP op = _factory.newVersionOP();
    _handleOperation(op);
    return op.future;
  }

  /** get command */
  Future<GetResult> get(String key)
  => getAll([key]).first
                  .catchError((err) => throw OPStatus.KEY_NOT_FOUND);

  /** get command with multiple keys */
  Stream<GetResult> getAll(List<String> keys) {
    GetOP op = _factory.newGetOP(OPType.get, keys);
    _handleOperation(op);
    return op.stream;
  }

  /** gets(with cas data version token) command */
  Future<GetResult> gets(String key)
  => getsAll([key]).first
                   .catchError((err) => throw OPStatus.KEY_NOT_FOUND);

  /** gets(with cas data version token) command with multiple keys */
  Stream<GetResult> getsAll(List<String> keys) {
    GetOP op = _factory.newGetOP(OPType.gets, keys);
    _handleOperation(op);
    return op.stream;
  }

  //enque operation into queue and kick start process if necessary
  void _handleOperation(OP op) {
    if (_toBeClose)
      throw new StateError("The client has been closed; no way to access the database.");

//TODO: for debug only
op.seq = seq++;
    if (_opQueue.isEmpty) { // 0 -> 1, new a Timer as Operation process loop
      new Timer.repeating(new Duration(milliseconds:_FREQ), (Timer t) {
        print("Repeating timer\n");
        if (connected && process()) { //no more operation, cancel the Timer
          t.cancel();
          if (_toBeClose)
            _close0();
        }
      });
    }
    _opQueue.add(op);
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
//        } else if (!process()) {
//          print("Still operation to go!");
//          setupTimer();
//        }
//      });
//    }
//  }

  //process Operation in queue; return true to indicate no opeartion to process
  bool process() {
    if (_currentOp == null || _currentOp.state == OPState.COMPLETE) { //previous operation is complete
      if (!_opQueue.isEmpty) {
        _currentOp = _opQueue.removeFirst();
        _process0();
      }
    }
    return _opQueue.isEmpty; //no more to process
  }

  void _process0() {
    OP op = _currentOp;
    print("OPState.WRITING: $op\n");
    op.state = OPState.WRITING;
    List<int> cmd = op.cmd;
    print("write sockcet cmd: [${decodeUtf8(cmd)}]");
    _socket.add(cmd); //see setupResponseHandler
    op.state = OPState.READING; //wait socket.input.onData()
  }

  //handle the socket reading of _currentOp
  ByteBuffer pbuf = new ByteBuffer();
  void setupResponseHandler() {
    _socket.listen((List<int> data) {
      if (data == null) //no data
        return;

        pbuf.addAll(data);
        _currentOp.processResponse(pbuf);
    }, onDone: () => print("Socket closed!"));
  }

  void _close0() {
    if (_socket != null)
      _socket.close();
  }
}
