//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:55:10 PM
// Author: hernichen

part of rikulo_memcached;

class ConfigDifference {
  List<String> serversAdded;

  List<String> serversRemoved;

  int vbucketsChanges;

  bool sequenceChanged;
}

