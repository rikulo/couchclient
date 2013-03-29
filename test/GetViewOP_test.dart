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
void testGetViewOP0(CouchClient client, String designDocName, String viewName) {
  Future f = client.getView(designDocName, viewName);
  f.then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("brewery_beers"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("beer-sample"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isFalse);
  });
  expect(f, completion(isNotNull));
}

void main() {
  group('GetViewOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testGetViewOP0(client, 'beer', 'brewery_beers'));
  });
}


