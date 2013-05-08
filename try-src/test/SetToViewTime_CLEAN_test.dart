import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import '../../packages/unittest/unittest.dart';
import '../../packages/couchclient/couchclient.dart';

int count = 10;

Future<List> delDocs(CouchClient client) {
  List<Future> dfs = new List();
  for (int j = 0; j < count; ++j)
    dfs.add(client.delete('viewkey$j')
        .catchError((err) => print('ignore')));
  return Future.wait(dfs);
}

void main() {
  CouchbaseConnectionFactory fact
  = new CouchbaseConnectionFactory(
      [Uri.parse("http://localhost:8091/pools")], 'default', '');
  Future f = CouchClient.connect(fact)
    .then((CouchClient client) {
      expect(delDocs(client), completes);
    });
//  expect(f, completes);
}
