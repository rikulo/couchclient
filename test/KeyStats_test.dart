//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, May 24, 2013  12:14:06 PM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

void testKeyStats(CouchClient client) {
  expect(client.set('key100', encodeUtf8('val100')), completion(isTrue));
  Future<Map<String, String>> f1 = client.keyStats('key100')
    .then((stats) {
      print("stats:$stats");
      expect(stats.length, equals(5));
      expect(stats.containsKey('key_vb_state'), isTrue);
      expect(stats.containsKey('key_flags'), isTrue);
      expect(stats.containsKey('key_is_dirty'), isTrue);
      expect(stats.containsKey('key_cas'), isTrue);
//      expect(stats.containsKey('key_data_age'), isTrue);
      expect(stats.containsKey('key_exptime'), isTrue);
//      expect(stats.containsKey('key_last_modification_time'), isTrue);
    });
  expect(f1, completes);
}

// Try to get stats of an in-existing key
void testKeyStats2(CouchClient client) {
  expect(client.keyStats('key200'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

void main() {
  setupLogger();
  group('BinaryKeyStatsTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestKeyStats', () => testKeyStats(client));
    test('TestKeyStats2', () => testKeyStats2(client));
  });
}
