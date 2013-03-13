//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';

void testTouch(MemcachedClient client) {
  expect(client.set('key100', encodeUtf8('val100')), completion(isTrue));
  Future f1 = null; //touch expiration time to 2 seconds
  Future f2 = client.get('key100');
  f2.then((val) {
    expect(val.data, equals(encodeUtf8('val100')));
    f1 = client.touch('key100', 1);
    f1.then((b) {
      expect(b, isTrue);
      new Timer(new Duration(seconds:2),expectAsync0(() {
        expect(client.get('key100'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
      }));
    });
    expect(f1, completes);
  });

  expect(f2, completes);
}

void main() {
  group('TextTouchTest:', () {
    MemcachedClient client;
    setUp(() => client = new MemcachedClient('localhost'));
    tearDown(() => client.close());
    test('TestTouch', () => testTouch(client));
  });
  group('BinaryTouchTest:', () {
    MemcachedClient client;
    setUp(() => client = new MemcachedClient('localhost'));
    tearDown(() => client.close());
    test('TestTouch', () => testTouch(client));
  });
}
