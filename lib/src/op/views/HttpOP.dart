//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:43:41 PM
// Author: hernichen

part of couchclient;

abstract class HttpOP {
  Logger _logger;
  Uri _cmd; //command in a byte array
  OPState _state; //null is state 0
  int seq;

  HttpOP() {
    _logger = initLogger('couchclient.op.views', this);
  }

  Uri get cmd
  => _cmd;

  OPState get state
  => _state;

  void set state(OPState s) {
    _state = s;
  }

  /**
   * Returns whether this OP is canceled by the user.
   */
  bool get isCancel
  => state == OPState.CANCELED;

  /**
   * Cancel this OP if not processed yet(still in write queue).
   */
  void cancel() {
    if (state == OPState.WRITE_QUEUED)
      state = OPState.CANCELED;
  }

  void processResponse(HttpResult result);

  Future<HttpResult> handleCommand(HttpClient hc, Uri baseUri, Uri cmd,
      AuthDescriptor authDescriptor);

  /**
   * Transition to next state.
   */
  void nextState() {
    if (_state == null)
      _state = OPState.WRITE_QUEUED;
    else if (_state == OPState.WRITE_QUEUED)
      _state = OPState.WRITING;
    else if (_state == OPState.WRITING)
      _state = OPState.READING;
    else if (_state == OPState.READING)
      _state = OPState.COMPLETE;
    else if (_state == OPState.RETRY)
      _state = OPState.WRITE_QUEUED;
    else if (_state == OPState.CANCELED)
      _state = OPState.COMPLETE;
  }

  /**
   * Indicate the completion of processing an OP.
   */
  void complete() {
    _state = OPState.COMPLETE;
  }
}

