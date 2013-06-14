//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//test RestClient#getDesignDocsOP
void testGetDesignDocsOP0(CouchClient client) {
  String mapfunc = 'function(doc, meta) {emit([doc.brewery_id]);}';
  ViewDesign view1 = new ViewDesign('testview', mapfunc);
  Future f = client.addDesignDoc(new DesignDoc("testddoc", views:[view1]))
  .then((_) => client.restClient.getDesignDocs())
  .then((ddocs) {
    bool exist = false;
    for (DesignDoc ddoc in ddocs) {
      if (ddoc.name == 'testddoc') {
        exist = true;
        expect(ddoc.views.first.map, equals(mapfunc));
      }
    }
    expect(exist, isTrue);
  })
  .then((_) => client.deleteDesignDoc('testddoc'));
  expect(f, completion(true));
}

void main() {
  setupLogger();
  group('GetDesignDocsOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetDesignDocsOP0', () => testGetDesignDocsOP0(client));
  });
}
