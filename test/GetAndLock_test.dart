//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testGetAndLock1(String key, CouchClient client) {
  expect(client.set(key, UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 1) //lock for 1 seconds
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
      print("wait 2 seconds....");
      return new Future.delayed(new Duration(seconds:2)); //wait 2 seconds
    })
    .then((_) {
      return client.set(key, UTF8.encode('newVal100'));
    })
    .then((_) {
      return client.get(key);
    })
    .then((val) {
      expect(val.data, equals(UTF8.encode('newVal100')));
    });

  expect(f1, completes);
}

// 1. locktime not expired, set shall complain KEY_EXIST
//  and get shall return the original value back
void testGetAndLock4(String key, CouchClient client) {
  expect(client.set(key, UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 3) //lock 3 seconds
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
      print("wait 2 seconds....");
      return new Future.delayed(new Duration(seconds:2)); //wait for 2 seconds
    }).then((_) {
      return client.set(key, UTF8.encode('newVal100'));
    });

  expect(f1, throwsA(equals(OPStatus.KEY_EXISTS)));

  Future f2 = client.get(key)
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
    });

  expect(f2, completes);
}

// 1. set with cas will unlock the key and get shall return
//  the new value.
// 2. set again, shall sucessful and get shall return the new value.
void testGetAndLock2(String key, CouchClient client) {
  expect(client.set(key, UTF8.encode('val100')), completion(isTrue));
  int cas;
  Future f1 = client.getAndLock(key, 5) //lock 5 seconds
    .then((val) {
      cas = val.cas;
      print("cas:$cas");
      expect(val.data, equals(UTF8.encode('val100')));
      print("wait 2 seconds....");
      return new Future.delayed(new Duration(seconds:2)); //wait for 2 seconds
    })
    .then((_) {
      return client.set(key, UTF8.encode('newVal100'), cas:cas); //unlock
    })
    .then((_) => client.get(key))
    .then((val) {
      expect(val.data, equals(UTF8.encode('newVal100')));
    })
    .then((_) => client.set(key, UTF8.encode('newVal200')))
    .then((_) => client.get(key))
    .then((val) {
       expect(val.data, equals(UTF8.encode('newVal200')));
    });

  expect(f1, completes);
}

// locktime not expired, and getAndLock again, show throw Temporary Failure
void testGetAndLock3(String key, CouchClient client) {
  expect(client.set(key, UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.getAndLock(key, 3) //lock 3 seconds
    .then((val) {
      return client.getAndLock(key, 3); //lock 1 seconds
    });

  expect(f1, throwsA(equals(OPStatus.TEMP_FAIL)));
}

void main() {
//  setupLogger();
  group('BinaryGetAndLockTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetAndLock1', () => testGetAndLock1('keyb100', client));
    test('TestGetAndLock2', () => testGetAndLock2('keyb200', client));
    test('TestGetAndLock3', () => testGetAndLock3('keyb300', client));
    test('TestGetAndLock4', () => testGetAndLock4('keyb400', client));
  });
}
