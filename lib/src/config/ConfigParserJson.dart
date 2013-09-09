//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 05, 2013  04:22:31 PM
// Author: hernichen

part of couchclient;

class ConfigParserJson {
  static const String NAME_ATTR = "name";
  static const String URI_ATTR = "uri";
  static const String STREAMING_URI_ATTR = "streamingUri";

  Logger _logger;

  ConfigParserJson() {
    _logger = initLogger('couchclient.config', this);
  }

  //TODO: catch error
  Map<String, Pool> parseBase(String base) {
    Map<String, Pool> parsedBase = new HashMap();
    Map baseJO = JSON.decode(base);
    List<Map> poolsJA = baseJO['pools'];
    for (Map poolJO in poolsJA) {
      String name = poolJO[NAME_ATTR];
      if (name == null || name.trim().isEmpty)
        throw new StateError("Pool's name is missing.");
      String uri = poolJO[URI_ATTR];
      if (uri == null || uri.trim().isEmpty)
        throw new StateError("Pool's uri is missing.");
      String streamingUri = poolJO[STREAMING_URI_ATTR];
      Pool pool = new Pool(name, Uri.parse(uri), Uri.parse(streamingUri));
      parsedBase[name] = pool;
    }
    return parsedBase;
  }

  //TODO: catch error
  void loadPool(Pool pool, String spool) {
    Map poolJO = JSON.decode(spool);
    Map poolBucketsJO = poolJO['buckets'];
    Uri bucketsUri = Uri.parse(poolBucketsJO['uri']);
    pool.bucketsUri = bucketsUri;
  }

  //TODO: catch error
  Map<String, Bucket> parseBuckets(String buckets) {
    Map<String, Bucket> bucketsMap = new HashMap();
    List bucketsJA = JSON.decode(buckets);
    for (Map bucketJO in bucketsJA) {
      Bucket bucket = parseBucket(bucketJO);
      bucketsMap[bucket.name] = bucket;
    }
    return bucketsMap;
  }

  //TODO: catch error
  Bucket parseBucket(Map bucketJO) {
    String bucketname = bucketJO['name'];
    String streamingUri = bucketJO['streamingUri'];
    ConfigFactory cf = new ConfigFactory();
    Config config = cf.parseJson(bucketJO);
    List<Node> nodes = new List();
    List nodesJA = bucketJO['nodes'];
    for (Map nodeJO in nodesJA) {
      String statusValue = nodeJO['status'];
      Status status = Status.valueOf(statusValue);
      String hostname = nodeJO['hostname'];
      Map portsJO = nodeJO['ports'];
      Map<Port, int> ports = new HashMap();
      for (Port port in Port.values) {
        int portValue = portsJO[port.name];
        if (portValue == null)
          continue;
        ports[port] = portValue;
      }
      Node node = new Node(status, hostname, ports);
      nodes.add(node);
    }
    _logger.finest("streamingUri->$streamingUri");
    return new Bucket(bucketname, config, Uri.parse(streamingUri), nodes);
  }
}

