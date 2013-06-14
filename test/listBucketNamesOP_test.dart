//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//test RestClient#listBucketNamesOP
void testlistBucketNamesOP0(CouchClient client) {
  Future f = client.restClient.listBucketNames()
  .then((names) {
    bool exist = false;
    for (var name in names) {
      if (name == 'beer-sample') {
        exist = true;
      }
    }
    return exist;
  });
  expect(f, completion(true));
}

void main() {
  setupLogger();
  group('listBucketNamesOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestlistBucketNamesOP0', () => testlistBucketNamesOP0(client));
  });
}
