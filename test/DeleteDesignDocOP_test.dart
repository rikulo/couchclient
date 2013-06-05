//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testDeleteDesignDocOP0(CouchClient client, String designDocName) {
  expect(client.deleteDesignDoc(designDocName), completion(isNotNull));
}

void main() {
  setupLogger();
  group('DeleteDesignDocOPTest:', () {
    CouchClient client;
    setUp(() =>
        cc.prepareCouchClient()
        .then((c) => client = c)
        .catchError((err) => print("err:$err")));
    tearDown(() => client.close());
    test('TestDeleteDesignDocOP0', () => testDeleteDesignDocOP0(client, 'noSuchDoc'));
  });
}


