import 'dart:async';
import 'dart:convert' show UTF8;
import '../../packages/unittest/unittest.dart';
import '../../packages/couchclient/couchclient.dart';

int count = 10000;

Future process(CouchClient client) {
  return delDocs(client)
    .then((_) => setDocs(client))
    .then((_) => tryQuery(client));
}

Future<List> setDocs(CouchClient client) {
  List<Future> sfs = new List();
  for (int j = 0; j < count; ++j)
    sfs.add(client.set('viewkey$j', UTF8.encode('"viewval$j"')));
  return Future.wait(sfs);
}

Future<List> delDocs(CouchClient client) {
  List<Future> dfs = new List();
  for (int j = 0; j < count; ++j)
    dfs.add(client.delete('viewkey$j')
        .catchError((err) {/*ignore*/}));
  return Future.wait(dfs);
}

int begin, end;
Completer cmpl = new Completer();
Future tryQuery(CouchClient client) {
  begin = new DateTime.now().millisecondsSinceEpoch;
//  print('begin-time: $begin');
  tryQuery0(client);
  return cmpl.future;
}

int retry = 0;
void tryQuery0(CouchClient client) {
  new Future<int>.delayed(new Duration(), () {
    query(client)
      .then((v) {
        if (v) {
          end = new DateTime.now().millisecondsSinceEpoch;
          //print('end-time: $end');
          print('diff-time: ${end-begin}');
          cmpl.complete(null);
        } else {
          ++retry;
          tryQuery0(client);
//          print("retry:$retry");
        }
      });
  });
}

Future<bool> query(CouchClient client) {
  View view = new View('default', 'dev_design1', 'view1', true, false);
  Query query = new Query();
  query.stale = Stale.FALSE;
  return client.query(view, query)
    .then((vr) {
      return vr.rows.length == count;
    });
}

void main() {
  CouchClient.connect([Uri.parse("http://localhost:8091/pools")], 'default', '')
    .then((CouchClient client) {
      Future f = process(client);
      f.then((_) {
        print("begin:$begin, end:$end, diff:${end-begin}, retries:$retry");
        client.close();
      });
      expect(f, completes);
    });
}
