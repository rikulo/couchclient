//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';

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

String REST_USER = 'Administrator';
String REST_PWD = 'password';
String DEFAULT_BUCKET_NAME = 'default';

void main() {
  group('ReducedOPTest:', () {
    CouchClient client;
    List<Uri> baseList = new List();
    setUp(() => client = new CouchClient('localhost', port : 8092, bucket : 'beer-sample'));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testReducedOP0(client, 'beer', 'by_location'));
  });
}


