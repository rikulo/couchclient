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
void testObserve1(CouchClient client) {
  Future f = client.set('key0', UTF8.encode('"value0"'))
  .then((ok) {
    if (ok) {
      return new Future.delayed(new Duration(seconds:1), () => ok);
    } else {
      throw new StateError("Cannot set key0");
    }
  })
//  .then((_) => client.gets('key0'))
  .then((_) => client.observe('key0'))
  .then((Map<SocketAddress, ObserveResult> rv) {
    expect(rv.values.first.status, equals(ObserveStatus.PERSISTED));
  });
  expect(f, completes);

}

//not persisted
void testObserve2(CouchClient client) {
  Future f = client.set('key0', UTF8.encode('"value0"'))
    .then((_) => client.gets('key0'))
    .then((GetResult rv) => client.observe('key0'))
    .then((Map<SocketAddress, ObserveResult> rv) {
      expect(rv.values.first.status, equals(ObserveStatus.NOT_PERSISTED));
    });
  expect(f, completes);
}

//not found
void testObserve3(CouchClient client) {
  Future f = client.observe('key101')
    .then((Map<SocketAddress, ObserveResult> rv) {
      expect(rv.values.first.status, equals(ObserveStatus.NOT_FOUND));
    });
  expect(f, completes);
}

//modified
void testObserve4(CouchClient client) {
  int cas;
  Future f = client.gets('key0')
    .then((GetResult rv) => cas = rv.cas)
    .then((_) => client.set('key0', UTF8.encode('"value0"')))
    .then((_) => client.observe('key0'))
    .then((Map<SocketAddress, ObserveResult> rv) {
      expect(rv.values.first.status, equals(ObserveStatus.NOT_PERSISTED));
      expect(rv.values.first.cas, isNot(equals(cas)));
    });
  expect(f, completes);
}

//logically deleted
void testObserve5(CouchClient client) {
  int cas;
  Future f = client.gets('key0')
    .then((GetResult rv) => cas = rv.cas)
    .then((_) => client.delete('key0'))
    .then((_) => client.observe('key0'))
    .then((Map<SocketAddress, ObserveResult> rv) {
      expect(rv.values.first.status, equals(ObserveStatus.LOGICALLY_DELETED));
    })
    .then((_) => client.set('key0', UTF8.encode('"value0"')));
  expect(f, completes);
}

void main() {
  setupLogger();
  group('ObserveOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestObserve1', () => testObserve1(client));
    test('TestObserve2', () => testObserve2(client));
    test('TestObserve3', () => testObserve3(client));
    test('TestObserve4', () => testObserve4(client));
    test('TestObserve5', () => testObserve5(client));
  });
}
