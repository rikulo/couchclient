//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 20, 2013  10:19:03 AM
// Author: henrichen

import 'dart:async';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:memcached_client/memcached_client.dart';
import 'package:couchclient/couchclient.dart';
import 'CouchbaseTestUtil.dart' as cc;

//get a key
void testGet1(CouchClient client) {
  expect(client.set('key0', encodeUtf8('"val0"')), completion(isTrue));

  Future f1 = client.get('key0');
  f1.then((v) {
    expect(decodeUtf8(v.data), equals('"val0"'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
}

//get an inexisting key
void testGet2(CouchClient client) {
  expect(client.get('key101'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

//get multiple key
void testGetAll(CouchClient client) {
  int count = 1;
  for (int j = 0; j < count; ++j) {
    expect(client.set('key$j', encodeUtf8('val$j')), completion(isTrue));
  }

  List<String> keys = new List();
  for (int j = 0; j < count; ++j) {
    keys.add('key$j');
  }

  Stream s1 = client.getAll(keys);
  Future<List<GetResult>> f1 = s1.toList();

  f1.then((List<GetResult> grs) {
    int j = 0;
    grs.forEach((GetResult gr) {
      expect(gr.key, equals('key$j'));
      expect(decodeUtf8(gr.data), equals('val$j'));
      expect(gr.cas, isNull);
      ++j;
    });
  });

  expect(f1, completes);
}

//gets a key; sould return with cas token.
void testGets1(CouchClient client) {
  expect(client.set('key0', encodeUtf8('val0')), completion(isTrue));

  Future f1 = client.gets('key0');
  f1.then((v) {
    expect(decodeUtf8(v.data), equals('val0'));
    expect(v.cas, isNotNull);
  });
  expect(f1, completes);
}

//gets an inexisting key
void testGets2(CouchClient client) {
  expect(client.gets('key101'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

//gets multiple key; should return with cas tokens.
void testGetsAll(CouchClient client) {
  int count = 20;
  for (int j = 0; j < count; ++j) {
    expect(client.set('key$j', encodeUtf8('val$j')), completion(isTrue));
  }

  List<String> keys = new List();
  for (int j = 0; j < count; ++j) {
    keys.add('key$j');
  }

  Stream s1 = client.getsAll(keys);
  Future<List<GetResult>> f1 = s1.toList();

  f1.then((List<GetResult> grs) {
    int j = 0;
    grs.forEach((GetResult gr) {
      expect(gr.key, equals('key$j'));
      expect(decodeUtf8(gr.data), equals('val$j'));
      expect(gr.cas, isNotNull);
      ++j;
    });
  });

  expect(f1, completes);
}

final String BEER_VALUE =
'{"name":"Wrath","abv":8.2,"ibu":0.0,"srm":0.0,"upc":0,"type":"beer",'
'"brewery_id":"midnight_sun_brewing_co","updated":"2010-07-22 20:00:20",'
'"description":"WRATH Belgian-style Double IPA is fiercely bitter with '
'notes of spice and earth. Its fury slowly and purposefully unfurls on '
'the tongue, relentlessly bringing on more and more enraged flavor with '
'each sip. \\r\\n\\r\\nWrath wreaks havoc on your taste buds. Anything you '
'drink after this may as well be water.","style":"Other Belgian-Style Ales",'
'"category":"Belgian and French Ale"}';
//get multiple key
//void testGetBearWithGetAll(CouchClient client) {
//  Stream s1 = client.getAll(["midnight_sun_brewing_co-wrath"]);
//  Future<List<GetResult>> f1 = s1.toList();
//
//  f1.then((List<GetResult> grs) {
//    int j = 0;
//    grs.forEach((GetResult gr) {
//      expect(gr.key, equals("midnight_sun_brewing_co-wrath"));
////      print('value:${decodeUtf8(gr.data)}');
//      expect(decodeUtf8(gr.data), equals(BEER_VALUE));
//      expect(gr.cas, isNull);
//      ++j;
//    });
//  });
//
//  expect(f1, completes);
//}

//void testGetBeerWithGet(CouchClient client) {
//  Future f1 = client.get("midnight_sun_brewing_co-wrath");
//  f1.then((v) {
//    expect(decodeUtf8(v.data), equals(BEER_VALUE));
//    expect(v.cas, isNull);
//  });
//  expect(f1, completes);
//}

//get a key
void testGetKey0(CouchClient client) {
  Future f1 = client.get('key0');
  f1.then((v) {
    expect(decodeUtf8(v.data), equals('val0'));
    expect(v.cas, isNull);
  });
  expect(f1, completes);
}


void main() {
  setupLogger();

  group('CouchRetrieveTest:', () {
    CouchClient client;
    setUp(() => cc.prepareCouchClient().then((c) => client = c));
    tearDown(() => client.close());
    test('TestGet1', () => testGet1(client));
    test('TestGet2', () => testGet2(client));
    test('TestGetAll', () => testGetAll(client));
    test('TestGets1', () => testGets1(client));
    test('TestGets2', () => testGets2(client));
    test('TestGetsAll', () => testGetsAll(client));
    test('TestGetKey0', () => testGetKey0(client));
//    test('TestGetBearWithGet', () => testGetBeerWithGet(client));
//    test('TestGetBearWithGetAll', () => testGetBearWithGetAll(client));
  });

  print("ABC.hashCode: ${'ABC'.hashCode}");
  var abc = 'AB'+'C';
  print("abc.hashCode: ${abc.hashCode}");

}

