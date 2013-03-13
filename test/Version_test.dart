//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';

//version should always succeed
void testVersion(MemcachedClient client) {
  expect(client.version(), completion(new isInstanceOf<String>()));
}

void main() {
  group('TextVersionTest:', () {
    MemcachedClient client;
    setUp(() => client = new MemcachedClient('localhost'));
    tearDown(() => client.close());
    test('TestVersion', () => testVersion(client));
  });

  group('BinaryVersionTest:', () {
    MemcachedClient client;
    setUp(() => client = new MemcachedClient('localhost'));
    tearDown(() => client.close());
    test('TestVersion', () => testVersion(client));
  });
}
