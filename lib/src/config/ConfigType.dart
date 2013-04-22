//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:15:19 PM
// Author: hernichen

part of couchclient;

class ConfigType extends Enum {
  /**
   * Memcache bucket type.
   */
  static const MEMCACHE = const ConfigType(0);

  /**
   * Couchbase bucket type.
   */
  static const COUCHBASE = const ConfigType(1);

  const ConfigType(int ordinal)
      : super(ordinal);
}

