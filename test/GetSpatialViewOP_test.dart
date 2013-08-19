//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 08, 2013  11:09:47 AM
// Author: henrichen

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testGetSpatialViewOP0(CouchClient client, String designDocName, String viewName) {
  ViewDesign view1 = new ViewDesign('xyzview', 'function(doc, meta) {emit([doc.brewery_id]);}');
  Future f = client.addDesignDoc(new DesignDoc(designDocName, views:[view1]))
  .then((ok) {
    expect(ok, true);
    return client.getSpatialView(designDocName, viewName);
  });

  expect(f, completion(isNull));
}

String REST_USER = 'Administrator';
String REST_PWD = 'password';
String DEFAULT_BUCKET_NAME = 'default';

void main() {
  group('GetSpatialViewOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetSpatialViewOP0', () => testGetSpatialViewOP0(client, 'beer', 'brewery_beers'));
  });
}


