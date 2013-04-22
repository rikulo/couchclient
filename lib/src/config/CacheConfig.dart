//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 05, 2013  06:50:16 PM
// Author: hernichen

part of couchclient;

class CacheConfig implements Config {
  final int serversCount;

  List<String> servers;

  List<Vbucket> vbuckets;

  CacheConfig(this.serversCount);

  int get replicasCount {
    throw new StateError("TODO: refctor this");
  }

  int get vbucketsCount {
    throw new StateError("TODO: refctor this");
  }

  String getServer(int serverIndex) {
    if (serverIndex > servers.length - 1) {
      throw new ArgumentError(
          "Server index is out of bounds, index = $serverIndex"
          ", servers count = ${servers.length}");
    }
    return servers[serverIndex];
  }

  int getVbucketByKey(String key) {
    throw new StateError("TODO: refctor this");
  }

  int getMaster(int vbucketIndex) {
    throw new StateError("TODO: refctor this");
  }

  int getReplica(int vbucketIndex, int replicaIndex) {
    throw new StateError("TODO: refctor this");
  }

  int foundIncorrectMaster(int vbucketIndex, int wrongServer) {
    throw new StateError("TODO: refctor this");
  }

  HashAlgorithm get hashAlgorithm {
    throw new UnsupportedError("HashAlgorithm not supported for cache buckets");
  }

  ConfigDifference compareTo(Config config) {
    ConfigDifference diff = new ConfigDifference();

    // Compute the added and removed servers
    // diff.setServersAdded(new
    // ArrayList<String>(CollectionUtils.subtract(config.getServers(),
    // this.getServers())));
    // diff.setServersRemoved(new
    // ArrayList<String>(CollectionUtils.subtract(this.getServers(),
    // config.getServers())));

    // Verify the servers are equal in their positions
    if (this.serversCount == config.serversCount) {
      diff.sequenceChanged = false;
      for (int i = 0; i < this.serversCount; i++) {
        if (this.servers[i] != config.servers[i]) {
          diff.sequenceChanged = true;
          break;
        }
      }
    } else {
      // Just say yes
      diff.sequenceChanged = true;
    }

    // Count the number of vbucket differences
    if (this.vbucketsCount == config.vbucketsCount) {
      int vbucketsChanges = 0;
      for (int i = 0; i < this.vbucketsCount; i++) {
        vbucketsChanges += (this.getMaster(i) == config.getMaster(i)) ? 0 : 1;
      }
      diff.vbucketsChanges = vbucketsChanges;
    } else {
      diff.vbucketsChanges = -1;
    }

    return diff;
  }

  ConfigType get configType => ConfigType.MEMCACHE;

  List<Uri> get couchServers {
    throw new UnsupportedError("No couch port for cache buckets");
  }
}