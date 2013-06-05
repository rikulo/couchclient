//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:33:48 PM
// Author: henrichen
library couchbase_test_util;

import 'dart:async';
import 'dart:utf';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:couchclient/couchclient.dart';

Future<CouchClient> prepareCouchClient()
=> CouchClient.connect(
    [Uri.parse("http://127.0.0.1:8091/pools")], 'beer-sample', '');
