//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:16:43 PM
// Author: hernichen

part of couchclient;

/**
 * Vbucket.
 */
class Vbucket {
  static const MAX_REPLICAS = 4;
  static const MAX_BUCKETS = 65536;
  int master;
  List<int> replicas;
  Vbucket(int m, List<int> r)
      : this.master = m,
        replicas = new List.from(r);
}

