part of rikulo_memcached;

class HttpResult {
  int status;
  HttpHeaders headers;
  List<int> contents;

  HttpResult(this.status, this.headers, this.contents);
}

class HttpUtil {
  static Future<HttpResult> uriDelete(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, [Map<String, String> headers]) {

    Completer<HttpResult> cmpl = new Completer();
    Future<HttpClientRequest> reqf = _httpDelete(hc, base, resource);
    reqf.then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, _buildAuthHeader(usr, pass));
      }
      return req.close();
    }).then((res) {
      int status = res.statusCode;
      HttpHeaders headers = res.headers;
      List<int> contents = new List();
      res.listen((bytes) => contents.add(bytes), //read response
        onDone : () => cmpl.complete(new HttpResult(status, headers, contents)), //done read response
        onError: (err) => print("DELETE:$err")//fail to read response
      );
    });
    return cmpl.future;
  }

  static Future<String> uriPut(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, String value, [Map<String, String> headers]) {
    Completer<String> cmpl = new Completer();
    StringBuffer sb = new StringBuffer();
    Future<HttpClientRequest> reqf = _httpPut(hc, base, resource);
    reqf.then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, _buildAuthHeader(usr, pass));
      }
      req.addString(value);
      return req.close();
    }).then((res) {
      res.listen((bytes) => sb.write(decodeUtf8(bytes)), //read response
        onDone : () => cmpl.complete(sb.toString()), //done read response
        onError: (err) => print("PUT:$err") //fail to read response
      );
    });
    return cmpl.future;
  }

  static Future<String> uriGet(HttpClient hc, Uri base, Uri resource,
      String usr, String pass, [Map<String, String> headers]) {
    Completer<String> cmpl = new Completer();
    StringBuffer sb = new StringBuffer();
    Future<HttpClientRequest> reqf = _httpGet(hc, base, resource);
    reqf.then((req) {
      HttpHeaders h = req.headers;
      if (headers != null) {
        for (String key in headers.keys)
          h.set(key, headers[key]);
      }
      if (usr != null) {
        h.set(HttpHeaders.AUTHORIZATION, _buildAuthHeader(usr, pass));
      }
      return req.close();
    }).then((res) {
      res.listen((bytes) => sb.write(decodeUtf8(bytes)), //read response
        onDone : () => cmpl.complete(sb.toString()), //done read response
        onError: (err) => print("GET:$err") //fail to read response
      );
    });
    return cmpl.future;
  }

  static Future<HttpClientRequest> _httpGet(HttpClient hc, Uri base, Uri resource) {
    if (!resource.isAbsolute && base != null) {
      resource = base.resolveUri(resource);
      print("GET $resource");
    }
    return hc.openUrl('GET', resource);
  }

  static Future<HttpClientRequest> _httpPost(HttpClient hc, Uri base, Uri resource) {
    if (!resource.isAbsolute && base != null) {
      resource = base.resolveUri(resource);
      print("POST $resource");
    }
    return hc.openUrl('POST', resource);
  }

  static Future<HttpClientRequest> _httpPut(HttpClient hc, Uri base, Uri resource) {
    if (!resource.isAbsolute && base != null) {
      resource = base.resolveUri(resource);
      print("PUT $resource");
    }
    return hc.openUrl('PUT', resource);
  }

  static Future<HttpClientRequest> _httpDelete(HttpClient hc, Uri base, Uri resource) {
    if (!resource.isAbsolute && base != null) {
      resource = base.resolveUri(resource);
      print("DELETE $resource");
    }
    return hc.openUrl('DELETE', resource);
  }

  static String _buildAuthHeader(String usr, String pass) {
    StringBuffer sb = new StringBuffer();
    sb..write(usr)
      ..write(':');
    if (pass != null)
      sb.write(pass);

    StringBuffer result = new StringBuffer();
    result..write('Basic ')
          ..write(CryptoUtils.bytesToBase64(encodeUtf8(sb.toString())));
    String st = result.toString();
    if (st.endsWith('\r\n'))
      st = st.substring(0, st.length - 2);
    return st;
  }

  /**
   * Split a string containing whitespace or comma separated host or IP
   * addresses and port numbers of the form "host:port host2:port" or
   * "host:port, host2:port" into a List of InetSocketAddress instances suitable
   * for instantiating a MemcachedClient.
   *
   * Note that colon-delimited IPv6 is also supported. For example: ::1:11211
   */
  static List<SocketAddress> parseSocketAddresses(String s) {
    if (s == null) {
      throw new ArgumentError("Null host list");
    }
    if (s.trim().isEmpty) {
      throw new ArgumentError("No hosts in list: [$s]");
    }
    List<SocketAddress> addrs = new List();

    for (String hoststuff in s.split("(?:\\s|,)+")) {
      if (hoststuff == "") {
        continue;
      }

      int finalColon = hoststuff.lastIndexOf(':');
      if (finalColon < 1) {
        throw new ArgumentError("Invalid server $hoststuff in list:  [$s]");
      }
      String hostPart = hoststuff.substring(0, finalColon);
      String portNum = hoststuff.substring(finalColon + 1);

      addrs.add(new SocketAddress(hostPart, int.parse(portNum)));
    }
    return addrs;
  }
}

