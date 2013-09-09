//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:06:21 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testTouch(CouchClient client) {
  expect(client.set('key100', UTF8.encode('val100')), completion(isTrue));
  Future f1 = client.get('key100')
    .then((val) {
      expect(val.data, equals(UTF8.encode('val100')));
      print("wait 1 second ...");
      return client.touch('key100', 1); //expire in 1 seconds
    }).then((b) {
      expect(b, isTrue);
      print("wait 2 seconds ...");
      return new Future.delayed(new Duration(seconds:2)); //wait 2 seconds
    }).then((_) {
      return client.get('key100');
    });

  expect(f1, throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

void main() {
  setupLogger();
  group('BinaryTouchTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestTouch', () => testTouch(client));
  });
}
