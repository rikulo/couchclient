//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:43:41 PM
// Author: hernichen

part of rikulo_memcached;

abstract class HttpOP {
  Uri _cmd; //command in a byte array
  final int _msecs; //TODO: timeout before giving up(in milliseconds)
  OPState _state; //null is state 0
  int seq;

  Uri get cmd
  => _cmd;

  OPState get state
  => _state;

  void set state(OPState s) {
    _state = s;
  }

  HttpOP([int msecs = _TIMEOUT])
  : _msecs = msecs;

  void processResponse(String result);

  Future<String> handleCommand(HttpClient hc, Uri baseUri, Uri cmd,
      String user, String pass);
}

