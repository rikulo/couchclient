//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
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

/**
 * The JavaScript Reduce View function; which count emitted documents.
 */
String REDUCE = '''
function(key, values, rereduce) {
  if (rereduce) {
    var result = 0;
    for (var i = 0; i < values.length; i++) {
      result += values[i];
    }
    return result;
  } else {
    return values.length;
  }
}''';

//test getViewOP
void testReducedOP0(CouchClient client) {
  // Prepare View function with name "by_name"
  ViewDesign vd = new ViewDesign("by_name_reduce", VIEW, REDUCE);
  // Prepare Design document with the name "beer"
  DesignDoc dd = new DesignDoc("beer", views: [vd]);
  // Add the DesignDocument "beer" into database
  Future f = client.addDesignDoc(dd)
  .then((_) => client.getView("beer", "by_name_reduce"))
  .then((view) {
    expect(view, isNotNull);
    expect(view.viewName, equals("by_name_reduce"));
    expect(view.designDocName, equals("beer"));
    expect(view.bucketName, equals("default"));
    expect(view.hasMap, isTrue);
    expect(view.hasReduce, isTrue);
    List<Future> fs = new List();
    for (int j = 0; j < 10; ++j)
      fs.add(client.set("beer$j", UTF8.encode('{"name": "beer$j", "type": "beerX"}'))
          .then((_) => client.observePoll("beer$j", persistTo: PersistTo.ONE)));
    return Future.wait(fs)
    .then((_) {
      Query query = new Query();
      query.stale = Stale.FALSE;
      return client.query(view, query);
    })
    .then((resp) {
      print("---------------------------");
      expect(resp.rows.length, equals(1));
      expect(int.parse(resp.rows.first.value), equals(10));
      for(ViewRowReduced row in resp.rows) {
        print(row);
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
  group('ReducedOPTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGetViewOP0', () => testReducedOP0(client));
  });
}


