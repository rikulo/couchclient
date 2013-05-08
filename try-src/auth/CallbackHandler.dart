//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of rikulo_memcached;

abstract class CallbackHandler {
  /**
   * Used to pass information to server when requested.
   */
  void handle(List<Callback> callbacks);
}

class PlainCallbackHander implements CallbackHandler {
  String username;
  List<int> password;

  PlainCallbackHander(this.username, this.password);

  void handle(List<Callback> callbacks) {
    for (Callback cb in callbacks) {
      if (cb is NameCallback) {
        cb.name = username;
      } else if (cb is PasswordCallback) {
        cb.password = password;
      } else {
        throw new UnsupportedError("callback: $cb");
      }
    }
  }
}
