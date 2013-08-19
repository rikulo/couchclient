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
  if (doc.type && doc.name && doc.type == "beerX") {
    emit(doc.name, meta.id);
  }
}''';

//test getViewOP
void testNoDocsOP0(CouchClient client) {
  // Prepare View function with name "by_name"
  ViewDesign vd = new ViewDesign("by_name", VIEW);
  // Prepare Design document with the name "beer"
  DesignDoc dd = new DesignDoc("beer", views: [vd]);
  // Add the DesignDocument "beer" into database
  Future f = client.addDesignDoc(dd).then((_) =>client.getView("beer", "by_name"))
  .then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("by_name"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("default"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isFalse);
    List<Future> fs = new List();
    for (int j = 0; j < 10; ++j)
      fs.add(client.set("beer$j", encodeUtf8('{"name": "beer$j", "type": "beerX"}'))
          .then((_) => client.observePoll("beer$j", persistTo: PersistTo.ONE)));
    return Future.wait(fs)
    .then((_) {
      Query query = new Query();
      //query.limit = 10;
      query.stale = Stale.FALSE;
      query.descending = true;
      return client.query(view, query);
    })
    .then((resp) {
      print("---------------------------");
      expect(resp.rows.length, equals(10));
      for(ViewRow row in resp.rows) {
        expect(row.doc, isNull);
      }
    })
    .then((_) {
      List<Future> dfs = new List();
      for (int j = 0; j < 10; ++j)
        dfs.add(client.delete("beer$j"));
      return Future.wait(dfs);
    });
  });
  expect(f, completes);
}

void main() {
  group('NoDocsOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testNoDocsOP0(client));
  });
}


