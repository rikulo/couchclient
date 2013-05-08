//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

String VIEW = '''
function (doc, meta) {
  if (doc.type && doc.name && doc.type == "beer") {
    emit(doc.name, meta.id);
  }
}''';

Future writeDesignView(CouchClient client, String designDocName, String viewName) {
  var fact = new CouchbaseConnectionFactory(
      [Uri.parse("http://localhost:8091/pools")], "beer-sample", "");

  // Prepare View Design
  ViewDesign vd = new ViewDesign(viewName, VIEW);
  // Prepare Design document
  DesignDoc dd = new DesignDoc(designDocName, views: [vd]);

  return client.addDesignDoc(dd);
}

//test getViewOP
void testWithDocsOP0(CouchClient client, String designDocName, String viewName) {
  Future f = writeDesignView(client, designDocName, viewName)
  .then((_) => client.getView(designDocName, viewName))
  .then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("by_name"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("beer-sample"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isFalse);
    Query query = new Query()
      ..limit = 10
      ..descending = true
      ..includeDocs = true;
    return client.query(view, query);
  })
  .then((resp) {
    print("---------------------------");
    expect(resp.rows.length, equals(10));
    for(ViewRowWithDocs row in resp.rows) {
      expect(row.doc, isNotNull);
    }
  });
  expect(f, completes);
}

String REST_USER = 'Administrator';
String REST_PWD = 'password';
String DEFAULT_BUCKET_NAME = 'default';

void main() {
  setupLogger();
  group('WithDocsOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testWithDocsOP0(client, 'beer', 'by_name'));
  });
}


