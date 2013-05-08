import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import '../../packages/unittest/unittest.dart';
import '../../packages/couchclient/couchclient.dart';

int keyi = new DateTime.now().millisecondsSinceEpoch;

Future process(CouchClient client) {
  return setDoc(client)
    .then((_) => tryQuery(client));
}

Future<bool> setDoc(CouchClient client) {
  return new Future.value(true);
//  return client.set('viewkey$keyi', encodeUtf8('"viewval$keyi"'));
}

Future<bool> delDoc(CouchClient client) {
  return client
         .delete('viewkey$keyi')
         .catchError((err) {/*ignore*/});
}

int begin, end;
Stale stale = Stale.FALSE;
Future tryQuery(CouchClient client) {
  Completer cmpl = new Completer();
  begin = new DateTime.now().millisecondsSinceEpoch;
  tryQuery0(client, cmpl);
  return cmpl.future;
}

int retry = 0;
void tryQuery0(CouchClient client, Completer cmpl) {
  new Future<int>.delayed(new Duration(), () {
    query(client)
      .then((v) {
        if (v) {
          end = new DateTime.now().millisecondsSinceEpoch;
          //print('diff-time: ${end-begin}');
          cmpl.complete(null);
        } else {
          ++retry;
          tryQuery0(client, cmpl);
//          print("retry:$retry");
        }
      });
  });
}

Future<bool> query(CouchClient client) {
  View view = new View('default', 'dev_design1', 'view1', true, false);
  Query query = new Query();
  query.stale = stale;
  query.key = 'viewkey$keyi';
  return client.query(view, query)
    .then((vr) {
      return !vr.rows.isEmpty && vr.rows[0].key == 'viewkey$keyi';
    });
}

void main() {
  CouchbaseConnectionFactory fact
  = new CouchbaseConnectionFactory(
      [Uri.parse("http://localhost:8091/pools")], 'default', '');
  CouchClient.connect(fact)
    .then((CouchClient client) {
      stale = Stale.FALSE;
      Future f = process(client);
      f
      .then((_) {
        print("1st: begin:$begin, end:$end, diff:${end-begin}, retries:$retry");
      })
      .then((_) {
        begin = end = retry = 0;
        stale = Stale.FALSE;
        return tryQuery(client);
      })
      .then((_) {
        print("2nd: begin:$begin, end:$end, diff:${end-begin}, retries:$retry");
      })
      .then((_) {
        begin = end = retry = 0;
        stale = Stale.FALSE;
        return tryQuery(client);
      })
      .then((_) {
        print("3rd: begin:$begin, end:$end, diff:${end-begin}, retries:$retry");
      })
      .then((_) {
        begin = end = retry = 0;
        stale = Stale.FALSE;
        return tryQuery(client);
      })
      .then((_) {
        print("4th: begin:$begin, end:$end, diff:${end-begin}, retries:$retry");
      })
      .then((_) {
        return delDoc(client);
      })
      .then((_) {
        client.close();
      });
      expect(f, completes);
    });
}
