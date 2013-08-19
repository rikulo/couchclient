//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

/**
 * The JavaScript Map-Reduce View function. It will look at the documents in
 * the bucket and emite the name and id as a key value pairs, if they are of
 * type "beer" and they have a name
 */
String VIEW = '''
function (doc, meta) {
  if (doc.type && doc.name && doc.type == "beer") {
    emit(doc.name, meta.id);
  }
}''';

//test getViewOP
void testGetViewOP0(CouchClient client) {
  // Prepare View function with name "by_name"
  ViewDesign vd = new ViewDesign("by_name", VIEW);
  // Prepare Design document with the name "beer"
  DesignDoc dd = new DesignDoc("beer", views: [vd]);

  // Add the DesignDocument "beer" into database
  Future f = client.addDesignDoc(dd);
  f.then((_) =>client.getView("beer", "by_name"))
  .then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("by_name"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("default"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isFalse);
  });
  expect(f, completes);
}

void main() {
  group('GetViewOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testGetViewOP0(client));
  });
}


