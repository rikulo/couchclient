//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Mar 04, 2013  05:10:31 PM
// Author: hernichen

part of rikulo_memcached;

abstract class Config {
  HashAlgorithm get hashAlgorithm;

  int get vbucketsCount;

  int get serversCount;

  int get replicasCount;

  List<String> get servers;

  List<Vbucket> get vbuckets;

  List<Uri> get couchServers;

  ConfigType get configType;

  int getVbucketByKey(String key);

  int getMaster(int vbucketIndex);

  int getReplica(int vbucketIndex, int replicaIndex);

  int foundIncorrectMaster(int vbucketIndex, int wrongServer);

  ConfigDifference compareTo(Config config);
}
