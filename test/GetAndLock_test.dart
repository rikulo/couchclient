//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testGetAndLock(String key, CouchClient client) {
  expect(client.set(key, encodeUtf8('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 1) //lock for 1 seconds
    .then((val) {
      expect(val.data, equals(encodeUtf8('val100')));
      print("wait 2 seconds....");
      return new Future.delayed(new Duration(seconds:2)); //wait 2 seconds
    })
    .then((_) {
      return client.set(key, encodeUtf8('newVal100'));
    })
    .then((_) {
      return client.get(key);
    })
    .then((val) {
      expect(val.data, equals(encodeUtf8('newVal100')));
    });

  expect(f1, completes);
}

// locktime not expired, set shall complain KEY_EXIST
//  and get shall return the original value back
void testGetAndLock2(String key, CouchClient client) {
  expect(client.set(key, encodeUtf8('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 3) //lock 3 seconds
    .then((val) {
      expect(val.data, equals(encodeUtf8('val100')));
      print("wait 2 seconds....");
      return new Future.delayed(new Duration(seconds:2)); //wait for 2 seconds
    }).then((_) {
      return client.set(key, encodeUtf8('newVal100'));
    });

  expect(f1, throwsA(equals(OPStatus.KEY_EXISTS)));

  Future f2 = client.get(key)
    .then((val) {
      expect(val.data, equals(encodeUtf8('val100')));
    });

  expect(f2, completes);
}

void main() {
//  setupLogger();
  group('BinaryGetAndLockTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetAndLock', () => testGetAndLock('keyb100', client));
    test('TestGetAndLock2', () => testGetAndLock2('keyb100', client));
  });
}
