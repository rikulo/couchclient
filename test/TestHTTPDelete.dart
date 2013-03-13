import 'dart:async';
import 'dart:io';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';

Future<String> testDelete() {
  HttpClient hc = new HttpClient();
  Future<HttpClientRequest> reqf =
      hc.openUrl('DELETE', Uri.parse('http://localhost:8092/default/_design/xyz'));
  Future<HttpClientResponse> respf =
      reqf.then((req) {
        req.done.then((v) => print("request DONE: $v"));
        print("close request");
        return req.close();
      });
  return respf.then((resp) {
    //20130308, henrichen: Strange! must call resp.statusCode to gurantee
    //Couchbase server not to close the connection
    int status = resp.statusCode;
    print('status:$status');
    print("resp.headers: ${resp.headers}");
    print("conninfo: ${resp.connectionInfo.remoteHost}");
    resp.first.then((bytes) => print("first: ${decodeUtf8(bytes)}"));
    StringBuffer sb = new StringBuffer();
//    resp.listen((bytes) => sb.write(decodeUtf8(bytes)),
//      onError : (err) => print("onError:$err"),
//      onDone : () {
//        print("onDone: $sb");
//        //hc.close();
//      }
//    );
    return sb.toString();
  });
}

void main() {
  expect(testDelete(), completes);
}


