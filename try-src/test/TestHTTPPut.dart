import 'dart:async';
import 'dart:io';
import '../../packages/unittest/unittest.dart';
import '../../packages/couchclient/couchclient.dart';

Future<String> testDelete() {
  HttpClient hc = new HttpClient();
  Future<HttpClientRequest> reqf =
      hc.openUrl('PUT', Uri.parse('http://localhost:8092/default00/_design/xyzdoc'));

  ViewDesign view1 = new ViewDesign('xyzview', 'function(doc, meta) {emit([doc.brewery_id]);}');
  List<ViewDesign> views = [view1];

  reqf.catchError((reqfErr) => print("reqErr:$reqfErr"));
  DesignDoc doc = new DesignDoc('xyz', views:views);
  String docstr = doc.toJson();
  print("designdoc.toJson:$docstr");
  Future<HttpClientResponse> respf =
      reqf.then((req) {
        req.done.then((v) => print("request DONE: $v"));
        HttpHeaders h = req.headers;
        h.set(HttpHeaders.CONTENT_TYPE, "application/json");
        h.set(HttpHeaders.ACCEPT, "application/json");
        h.set(HttpHeaders.USER_AGENT, "Couchbase Dart Client");
        h.set("X-memcachekv-Store-Client-Specification-Version", "1.0");
        h.set("Connection", "Keep-Alive");
        req.addString(docstr);
        print("close request");
        return req.close();
      }, onError: (err) => print("in-place-reqf:$err"));

//  respf.catchError((err) => print("requestError:$err"));
  Future<String> resultf = respf.then((resp) {
    print("resp.headers: ${resp.headers}");
//    print("conninfo: ${resp.connectionInfo.remoteHost}");
//    resp.first.then((bytes) => print("first: ${decodeUtf8(bytes)}"));
    StringBuffer sb = new StringBuffer();
//    resp.listen((bytes) => sb.write(decodeUtf8(bytes)),
//      onError : (err) => print("onError:$err"),
//      onDone : () {
//        print("onDone: $sb");
//        //hc.close();
//      }
//    );
    return sb.toString();
  }, onError: (err) => print("in-place-respf:$err"));

//  resultf.catchError((err) => print("responseError:$err"));
  return resultf;
}

void main() {
  Future<String> f = testDelete();
  f.catchError((err) {print("mainErr:$err");}, test: (e) => true);
  expect(f, completes);
}


