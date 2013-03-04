//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:33:48 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';

//delete key3
void testDelete1(Client client) {
  expect(client.set('key3', encodeUtf8('va13')), completion(isTrue));
  expect(client.delete('key3'), completion(isTrue));
}

//delete inexist key3; should throw NOT_FOUND
void testDelete2(Client client) {
  expect(client.delete('key3'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

void main() {
  group('TextDeleteTest:', () {
    Client client;
    setUp(() => client = new Client('localhost'));
    tearDown(() => client.close());
    test('TestDelete1', () => testDelete1(client));
    test('TestDelete2', () => testDelete2(client));
  });
  group('BinaryDeleteTest:', () {
    Client client;
    setUp(() => client = new Client('localhost', factory: new BinaryOPFactory()));
    tearDown(() => client.close());
    test('TestDelete1', () => testDelete1(client));
    test('TestDelete2', () => testDelete2(client));
  });
}



