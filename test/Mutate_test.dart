//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Feb 21, 2013  12:50:11 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//increment 1 by 5 to 6
void testIncrement1(CouchClient client) {
  expect(client.set('key0', UTF8.encode('1')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('1'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
  expect(client.increment('key0', 5), completion(equals(6)));
}

//increment v1 by 5 to 6; should throws Error
void testIncrement2(CouchClient client) {
  expect(client.set('key0', UTF8.encode('v1')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('v1'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
  expect(client.increment('key0', 5), throwsA(new isInstanceOf<OPStatus>()));
}

//decrement 10 by 4 to 6
void testDecrement1(CouchClient client) {
  expect(client.set('key0', UTF8.encode('10')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('10'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
  expect(client.decrement('key0', 4), completion(equals(6)));
}

//decrement v10 by 4 to 6; should throws error.
void testDecrement2(CouchClient client) {
  expect(client.set('key0', UTF8.encode('v10')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) {
    expect(UTF8.decode(v.data), equals('v10'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
  expect(client.decrement('key0', 4), throwsA(new isInstanceOf<OPStatus>()));
}

void main() {
  setupLogger();
  group('CouchMutateTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestIncrement1', () => testIncrement1(client));
    test('TestIncrement2', () => testIncrement2(client));
    test('TestDecrement1', () => testDecrement1(client));
    test('TestDecrement2', () => testDecrement2(client));
  });
}



