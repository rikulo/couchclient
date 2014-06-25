    import 'dart:io';
    import 'dart:async';
    import 'dart:convert';

    void main() {
      HttpClient hc = new HttpClient();
      hc.getUrl(Uri.parse("http://127.0.0.1:8091/pools"))
      .then((req) => req.close())
      .then((resp) => resp.first)
      .then((bytes) => print("${UTF8.decode(bytes)}"));
    }