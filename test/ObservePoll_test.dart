//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//persist
void testObservePoll1(CouchClient client) {
  Future f = client.set('key0', UTF8.encode('"value0"'))
  .then((ok) {

    if (ok) {
      return client.observePoll('key0', persistTo: PersistTo.ONE,
        replicateTo: ReplicateTo.ZERO);
    } else {
      throw new StateError("Cannot set key0");
    }
  })
  .then((ok) {
    expect(ok, isTrue);
  });
  expect(f, completes);

}

//not persisted
void testObservePoll2(CouchClient client) {
  Future f = client.delete('key0')
  .then((ok) {
    if (ok) {
      return client.observePoll('key0', persistTo: PersistTo.ONE, isDelete: true);
    } else {
      throw new StateError("Cannot delete key0");
    }
  })
  .then((ok) {
    expect(ok, isTrue);
  });
  expect(f, completes);
}

//not found until timeout
void testObservePoll3(CouchClient client) {
  expect(client.observePoll('key101', persistTo: PersistTo.ONE),
      throwsA(new isInstanceOf<ObservedTimeoutException>()));
}

//modified (because cas is different)
void testObservePoll4(CouchClient client) {

  Future f = client.set('key0', UTF8.encode('"value0"'))
  .then((ok) {
    if (ok) {
      expect(client.observePoll('key0', cas: 0, persistTo: PersistTo.ONE),
          throwsA(new isInstanceOf<ObservedModifiedException>()));
    } else {
      throw new StateError("Cannot set key0");
    }
  });
  expect(f, completes);
}

//Not enough nodes to handle the requested replica and persistent
void testObservePoll5(CouchClient client) {
  expect(client.observePoll('key0', persistTo: PersistTo.TWO),
      throwsA(new isInstanceOf<ObservedException>()));
}

void main() {
  setupLogger();
  group('ObserveOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) {
      client = c;
      (client as CouchClientImpl).connectionFactory.observePollMax = 50; //timeout at 50 * 100
      return client;
    }));
    tearDown(() {client.close(); client = null;});
    test('testObservePoll1', () => testObservePoll1(client));
    test('testObservePoll2', () => testObservePoll2(client));
    test('testObservePoll3', () => testObservePoll3(client));
    test('testObservePoll4', () => testObservePoll4(client));
    test('testObservePoll5', () => testObservePoll5(client));
  });
}
