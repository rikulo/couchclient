//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Connection to a cluster of Couchbase server nodes.
 */
class CouchbaseConnection extends MemcachedConnection {
  final CouchbaseConnectionFactory _connFactory;

  CouchbaseConnection(
      NodeLocator locator,
      CouchbaseConnectionFactory connFactory,
      OPFactory opFactory,
      FailureMode failureMode)
      : _connFactory = connFactory,
        super(locator, connFactory, opFactory, failureMode);

}

