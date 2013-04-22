//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 19, 2013  06:03:22 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'dart:typeddata';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//Unconditonal set key0
void testSaslMechs0(CouchClient client) {
  Future f1 = client.listSaslMechs();
  expect(f1, completion(equals(['PLAIN'])));
}

void main() {
  group('SaslMechsTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestSaslMechs0', () => testSaslMechs0(client));
  });
}