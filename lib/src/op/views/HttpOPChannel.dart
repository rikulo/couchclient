//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  09:34:10 AM
// Author: hernichen

part of couchclient;

/**
 * An Http channel that sends OP to Http server and receive Http response.
 */
class HttpOPChannel implements OPChannel<int, HttpOP> {
  Logger _logger;
  final OPQueue<int, HttpOP> _writeQ;
  final AuthDescriptor _authDescriptor;
  final Uri _baseUri;
  int _seq = 0; //OP sequence id

  bool _closing = false; //Channel is closing
  HttpOP _writeOP; //current OP to be write into socket

  HttpOPChannel(SocketAddress saddr, AuthDescriptor authDescriptor)
      : _authDescriptor = authDescriptor,
        _writeQ = new OPQueueQueue(),
        _baseUri = Uri.parse("http://${saddr.host}:${saddr.port}") {
    _logger = initLogger("couchclient.op.view", this);
  }

  //@Override
  OPQueue<int, HttpOP> get writeQ
  => _writeQ;

  //@Override
  OPQueue<int, HttpOP> get readQ {
    throw new StateError("Should never call readQ in Http protocol");
  }

  //@Override
  bool get isConnected
  => true;

  //@Override
  bool get isAuthenticated
  => true;

  //@Override
  void authenticate() {
    //Should never call here
    throw new StateError("Should never call authenticate in Http protocol");
  }

  //@Override
  void addOP(HttpOP op) {
    if (_closing) {
      //_logger.finest("The client is being closing; no way to addOP.");
      return;
    }

    op.nextState();
    op.seq = _seq++;
    _seq &= 0xffffffff;
    writeQ.add(op);
    if (writeQ.length == 1) { // 0 -> 1, new a Future for OP processing
      _processLoop();
    }
  }

  /**
   * Enque OP at the beginning and kick start process if necessary.
   */
  void prependOP(HttpOP op) {
    if (_closing) {
      //_logger.finest("The client is being closing; no way to prependOP.");
      return;
    }

    op.nextState();
    writeQ.push(op);
    if (writeQ.length == 1) { // 0 -> 1, new a Future for OP processing
      _processLoop();
    }
  }

  /**
   * Close this Operation channel.
   */
  void close() {
    //_logger.finest("close: _writeQ.isEmpty:${writeQ.isEmpty}");
    _closing = true;
    _tryClose();
  }

  /**
   * Process the response from the server.
   */
  void processResponse() {
    throw new StateError("Should never call processResponse in Http protocol");
  }

  void _tryClose() {
    //Do nothing
  }

  void _processLoop() {
    new Future.delayed(new Duration(milliseconds:_FREQ))
    .then((_) {
//      if (!isConnected) {
//        //_logger.finest("Wait HttpClient to be connected.");
//        _processLoop();
//      } else if (isAuthenticated == null) {
//        //_logger.finest("Wait socket to be authenticated.");
//        authenticate();
//        _processLoop();
//      } else if (!isAuthenticated) { //fail to authentication
//        throw new StateError('Fail to authenticate...Stop operation');
//      } else
        if (!_processWriteQ()) {
        //_logger.finest("Still OP in queue, continue the _processLoop.");
        _processLoop();
      }
    })
    .catchError((err, st) => _logger.warning("_processLoop", err, st));
  }

  //Process OP in write queue; return true to indicate no OP to process
  bool _processWriteQ() {
    //fetch next OP in queue when previous OP is complete.
    if (_writeOP == null
        || _writeOP.state == OPState.WRITING
        || _writeOP.state == OPState.COMPLETE) {
        _processNextOP();
    }
    return writeQ.isEmpty; //no more to process
  }

  void _processNextOP() {
    if (writeQ.isEmpty)
      return;

    _writeOP = writeQ.pop();
    //_logger.finest("OPState.WRITING: $_writeOP\n");
    _writeOP.nextState();

    _processWriteOP();
  }

  void _processWriteOP() {
    HttpOP op = _writeOP;
    Uri cmd = op.cmd;
    HttpClient hc = new HttpClient();
    try {
      Future<HttpResult> f = op.handleCommand(hc, _baseUri, cmd, _authDescriptor);
      f.then((result) {
        op.processResponse(result);
      });
      //wait no response: we post the command and assume complete
      op.complete();
    } finally {
      hc.close();
    }
  }
}
