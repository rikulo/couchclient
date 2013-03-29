//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:33:48 PM
// Author: henrichen
library couchbase_test_util;

import 'dart:async';
import 'dart:utf';
import 'dart:uri';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:rikulo_memcached/memcached.dart';

CouchbaseConnectionFactory _fact
= new CouchbaseConnectionFactory(
    [Uri.parse("http://localhost:8091/pools")],
    'beer-sample', '');

Future<CouchClient> prepareCouchClient()
=> CouchClient.connect(_fact);
