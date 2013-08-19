//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//noSuchDoc is not in DB, so delete a not existing doc is deemed success
void testDeleteDesignDocOP0(CouchClient client, String designDocName) {
  expect(client.deleteDesignDoc(designDocName), completion(true));
}

//now create a doc and delete it
void testDeleteDesignDocOP1(CouchClient client, String designDocName) {
  ViewDesign view1 = new ViewDesign('xyzview', 'function(doc, meta) {emit([doc.brewery_id]);}');
  Future f = client.addDesignDoc(new DesignDoc(designDocName, views:[view1]))
      .then((ok) {
        expect(ok, true);
        return client.deleteDesignDoc(designDocName);
      });
  expect(f, completion(true));
}

void main() {
  setupLogger();
  group('DeleteDesignDocOPTest:', () {
    CouchClient client;
    setUp(() =>
        cc.prepareCouchClient()
        .then((c) => client = c)
        .catchError((err) => print("err:$err")));
    tearDown(() => client.close());
    test('TestDeleteDesignDocOP0', () => testDeleteDesignDocOP0(client, 'noSuchDoc'));
    test('TestDeleteDesignDocOP1', () => testDeleteDesignDocOP0(client, 'noSuchDoc'));
  });
}


