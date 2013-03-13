//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:43:41 PM
// Author: hernichen

part of rikulo_memcached;

abstract class PutHttpOP extends HttpOP {
  final String value;
  PutHttpOP(this.value, int msecs)
    : super(msecs);

  Future<String> handleCommand(HttpClient hc, Uri baseUri, Uri cmd,
        String user, String pass)
  => HttpUtil.uriPut(hc, baseUri, cmd, user, pass, value, {'content-type' : 'application/json'})
      .then((v) {
        hc.close();
        return v;
      });
}

