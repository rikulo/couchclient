//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Couchbase client implementation of MemcachedConnection that handles
 * Reconfigurable.
 */
//TODO: reconfiguration
class CouchbaseMemcachedConnection extends MemcachedConnection {
  CouchbaseMemcachedConnection(
      NodeLocator locator,
      ConnectionFactory connFactory,
      OPFactory opFactory,
      FailureMode failureMode)
      : super(locator, connFactory, opFactory, failureMode);
}

