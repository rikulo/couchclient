//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//test getViewOP
void testNoDocsOP0(CouchClient client, String designDocName, String viewName) {
  Future f = client.getView(designDocName, viewName);
  Future f2 = f.then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("brewery_beers"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("beer-sample"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isFalse);
    Query query = new Query();
    query.limit = 10;
    query.descending = true;
    return client.query(view, query);
  });
  f2.then((resp) {
    print("---------------------------");
    for(ViewRowNoDocs row in resp.rows) {
      print(row);
    }
  });
  expect(f, completes);
  expect(f2, completes);
}

String REST_USER = 'Administrator';
String REST_PWD = 'password';
String DEFAULT_BUCKET_NAME = 'default';

void main() {
  group('NoDocsOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testNoDocsOP0(client, 'beer', 'brewery_beers'));
  });
}


