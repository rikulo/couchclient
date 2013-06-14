//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 14, 2013  05:23:51 PM
// Author: hernichen

part of couchclient;

/**
 * The enum of different Couchbase Bucket type.
 */
class BucketType extends Enum {
  /**
   * Specifies the bucket work in Memcached server.
   */
  static const MEMCACHED = const BucketType(0x00, 'memcached');

  /**
   * Specifies the bucket work in Couchbase server.
   */
  static const COUCHBASE = const BucketType(0x01, 'membase');

  final String name;
  const BucketType(int ordinal, this.name)
      : super(ordinal);
}
