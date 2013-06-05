//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//test getDesignDocOP
void testGetDesignDocOP0(CouchClient client, String designDocName) {
  expect(client.getDesignDoc(designDocName), completion(isNotNull));
}

void testGetDesignDocOP1(CouchClient client, String designDocName) {
  expect(client.getDesignDoc(designDocName), completion(isNull));
}

void main() {
  setupLogger();
  group('GetDesignDocOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetDesignDocOP0', () => testGetDesignDocOP0(client, 'beer'));
    test('TestGetDesignDocOP1', () => testGetDesignDocOP1(client, 'noSuchDoc'));
  });
}


