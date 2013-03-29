//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testPutDesignDocOP0(CouchClient client, String designDocName) {
  ViewDesign view1 = new ViewDesign('xyzview', 'function(doc, meta) {emit([doc.brewery_id]);}');
  List<ViewDesign> views = [view1];
  expect(client.putDesignDoc(new DesignDoc(designDocName, views:views)), completion(true));
}

String REST_USER = 'Administrator';
String REST_PWD = 'password';
String DEFAULT_BUCKET_NAME = 'default';

void main() {
  group('GetDesignDocOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestPutDesignDocOP0', () => testPutDesignDocOP0(client, 'xyzdoc'));
  });
}


