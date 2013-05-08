//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  09:47:04 PM
// Author: henrichen

import 'dart:async';
import 'dart:uri';
import 'dart:utf';
import 'package:unittest/unittest.dart';
import 'package:couchclient/couchclient.dart';

//test getBucketConfig
void testGetBucketConfig(ConfigProvider provider) {
  expect(provider.getBucketConfig('default'), completion(isNotNull));
}

void testServers(ConfigProvider provider, String bucketname) {
  Future<Bucket> f = provider.getBucketConfig(bucketname);
  f.then((Bucket bucket) {
    print("[$bucketname].config.servers------>${bucket.config.servers}");
    print("[$bucketname].config.couchServers------>${bucket.config.couchServers}");
  });
  expect(f, completes);
}

String REST_USER = 'Administrator';
String REST_PWD = '123456';//'password';
String DEFAULT_BUCKET_NAME = 'default';

void main() {
  group('ConfigProviderTest:', () {
    ConfigProvider provider;
    List<Uri> baseList = new List();
    String base = 'http://127.0.0.1:8091/pools';
    Uri baseUri = Uri.parse(base);
    baseList.add(baseUri);
    setUp(() => provider = new ConfigProvider(baseList, REST_USER, REST_PWD));
    test('TestBucketConfig', () => testGetBucketConfig(provider));
    test('TestServers0', () => testServers(provider, 'default'));
    test('TestServers1', () => testServers(provider, 'beer-sample'));
  });
}


