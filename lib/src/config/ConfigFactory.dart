//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 05, 2013  06:16:22 PM
// Author: hernichen

part of couchclient;

class ConfigFactory {
  Config parse(String data) {
    Map jo = json.parse(data);
  }

  Config parseJson(Map jo) =>
      !jo.containsKey('vBucketServerMap') ?
          parseCacheJson(jo) : parseEpJson(jo);

  Config parseCacheJson(Map jo) {
    List<String> nodes = jo['nodes'];
    if (nodes.length <= 0)
      throw new StateError('Empty nodes list.');
    int serversCount = nodes.length;
    CacheConfig config = new CacheConfig(serversCount);
    populateServersFromNodes(config, nodes);
    return config;
  }

  Config parseEpJson(Map jo) {
    Map vbMap = jo['vBucketServerMap'];
    String algorithm = vbMap['hashAlgorithm'];
    HashAlgorithm hashAlgorithm = lookupHashAlgorithm(algorithm);
    if (hashAlgorithm == null)
      throw new StateError("Unhandled hash algorithm type: $hashAlgorithm");
    int replicasCount = vbMap['numReplicas'];
    if (replicasCount > Vbucket.MAX_REPLICAS)
      throw new StateError("Expected number <= ${Vbucket.MAX_REPLICAS} for replicas");
    List servers = vbMap['serverList'];
    if (servers.length <= 0)
      throw new StateError("Empty servers list.");
    int serversCount = servers.length;
    List vbuckets = vbMap['vBucketMap'];
    int vbucketsCount = vbuckets.length;
    if (vbucketsCount == 0 || (vbucketsCount & (vbucketsCount - 1)) != 0)
      throw new StateError("Number of buckets must be a power of two, > 0 and <= ${Vbucket.MAX_BUCKETS}");
    List<String> pServers = populateServers(servers);
    List<Vbucket> pVbuckets = populateVbuckets(vbuckets);
    List<Uri> couchServers = populateCouchServers(jo['nodes']);
    Config config = new DefaultConfig(hashAlgorithm, serversCount,
        replicasCount, vbucketsCount, pServers, pVbuckets,
        couchServers);

    return config;
  }

  List<Uri> populateCouchServers(List nodes) {
    List<Uri> nodeNames = new List();
    for (Map node in nodes) {
      if (node.containsKey('couchApiBase')) {
        nodeNames.add(Uri.parse(node['couchApiBase']));
      }
    }
    return nodeNames;
  }

  List<String> populateServers(List servers) {
    List<String> serverNames = new List();
    for (String name in servers) {
      serverNames.add(name);
    }
    return serverNames;
  }

  void populateServersFromNodes(CacheConfig config, List nodes) {
    List<String> serverNames = new List();
    for (Map node in nodes) {
      String webHostPort = node["hostname"];
      List<String> splitHostPort = webHostPort.split(":");
      Map portsList = node["ports"];
      int port = portsList["direct"];
      serverNames.add("${splitHostPort[0]}:$port");
    }
    config.servers = serverNames;
  }

  List<Vbucket> populateVbuckets(List vbucketsJO) {
    List<Vbucket> vbuckets = new List();
    for (List rows in vbucketsJO) {
      int master = rows[0];
      List<int> replicas = new List(Vbucket.MAX_REPLICAS);
      for (int j = 1; j < rows.length; ++j) {
        replicas[j - 1] = rows[j];
      }
      vbuckets.add(new Vbucket(master, replicas));
    }
    return vbuckets;
  }
}

