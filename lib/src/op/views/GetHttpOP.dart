//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:43:41 PM
// Author: hernichen

part of couchclient;

abstract class GetHttpOP extends HttpOP {
  Future<String> handleCommand(HttpClient hc, Uri baseUri, Uri cmd,
      AuthDescriptor authDescriptor) {
    final String user = authDescriptor == null ? null : authDescriptor.bucket;
    final String pass = authDescriptor == null ? null : authDescriptor.password;
    return HttpUtil.uriGet(hc, baseUri, cmd, user, pass)
    .then((base) {
      hc.close();
      return base;
    });
  }
}

