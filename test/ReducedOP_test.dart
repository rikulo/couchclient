//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';
import 'CouchbaseTestUtil.dart' as cc;

//test getViewOP
void testReducedOP0(CouchClient client, String designDocName, String viewName) {
  Future f = client.getView(designDocName, viewName);
  Future f2 = f.then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("by_location"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("beer-sample"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isTrue);
    Query query = new Query();
    return client.query(view, query);
  });
  f2.then((resp) {
    print("---------------------------");
    for(ViewRowReduced row in resp.rows) {
      print(row);
    }
  });
  expect(f, completes);
  expect(f2, completes);
}

void main() {
  group('ReducedOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testReducedOP0(client, 'beer', 'by_location'));
  });
}


