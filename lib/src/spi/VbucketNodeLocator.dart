//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

/**
 * Locating a node by hash value.
 */
class VbucketNodeLocator implements NodeLocator {
  Logger _logger;
  _TotalConfig _fullConfig;

  VbucketNodeLocator(List<MemcachedNode> nodes, Config joinConfig) {
    _logger = initLogger('couchclient.spi', this);
    Map<String, MemcachedNode> nodesMap = _initNodesMap(joinConfig, nodes);
    _fullConfig = new _TotalConfig(joinConfig, nodesMap);
  }

  @override
  MemcachedNode getPrimary(String key) {
    Config config = _fullConfig.config;
    Map<String, MemcachedNode> nodesMap = _fullConfig.nodesMap;
    int vbucket = config.getVbucketByKey(key);
    int serverIndex = config.getMaster(vbucket);

    if (serverIndex == -1) {
      throw new StateError("The key $key pointed to vbucket $vbucket, "
          "for which no server is responsible in the cluster map. This "
          "can be an indication that either no replica is defined for a "
          "failed server or more nodes have been failed over than replicas "
          "defined.");
    }

    String server = config.getServer(serverIndex);

    //choose appropriate MemcachedNode per the Config
    MemcachedNode pNode = nodesMap[server];
    if (pNode == null) {
      _logger.config('The node locator does not have a primary for key "$key". '
          'Wanted vbucket $vbucket which should be on server "$server"');
      _logger.config('List of nodes has ${nodesMap.length} entries:');
      for (String server in nodesMap.keys)
        _logger.config('MemcachedNode for $server is ${nodesMap[server]}.');
      for (MemcachedNode node in nodesMap.values)
        _logger.config('$node');
    }

    assert (pNode != null);
    return pNode;
  }

  @override
  Iterator<MemcachedNode> getSequence(String key) => new _VbucketNodeIterator();

  @override
  Iterable<MemcachedNode> get allNodes => _fullConfig.nodesMap.values;

  @override
  void updateLocator(List<MemcachedNode> nodes) {
    throw new UnsupportedError("Must be updated with a config");
  }

  void updateLocatorWithConfig(List<MemcachedNode> nodes, Config newConfig) {
    Config current = _fullConfig.config;
    ConfigDifference diff = current.compareTo(newConfig);

    if (diff.sequenceChanged
        || diff.vbucketsChanges > 0
        || current.couchServers.length != newConfig.couchServers.length) {
      //_logger.finest("Updating configuration, received updated configuration "
      //    "with significant changes.");
      Map<String, MemcachedNode> nodesMap = _initNodesMap(newConfig, nodes);
      _fullConfig = new _TotalConfig(newConfig, nodesMap);
    } //else
      //_logger.finest("Received updated configuration with insignificant "
      //    "changes.");
  }

  /**
   * Returns a vbucket index per the given key.
   */
  int getVbucketIndex(String key) => _fullConfig.config.getVbucketByKey(key);

  /**
   * Returns the server per the server index.
   */
  MemcachedNode getServerByIndex(int index) {
    final Config config = _fullConfig.config;
    final Map<String, MemcachedNode> nodesMap = _fullConfig.nodesMap;
    // choose appropriate MemcachedNode according to config data
    return nodesMap[config.getServer(index)];
  }

  /**
   * Returns the node that is not contained in the specified list of the FAILD
   * nodes.
   */
  MemcachedNode getAlternative(String key, List<MemcachedNode> excludedVbucketNodes) {
    Map<String, MemcachedNode> nodesMap = new HashMap.from(_fullConfig.nodesMap);
    List<MemcachedNode> nodes = nodesMap.values;
    nodes.removeWhere((e) => excludedVbucketNodes.contains(e));
    if (nodes.isEmpty)
      return null;
    else
      return nodes.first;
  }

  Map<String, MemcachedNode> _initNodesMap(
      Config newConfig, List<MemcachedNode> nodes) {
    Map<String, MemcachedNode> nodesMap = new HashMap();
    for (String server in newConfig.servers) {
      nodesMap[server] = null;
    }

    for (MemcachedNode node in nodes) {
      SocketAddress addr = node.socketAddress;
      String uri = addr.toUri();

      if (nodesMap.containsKey(uri)) {
        nodesMap[uri] = node;
        //_logger.finest('Node "$node" added with address "$uri"');
      }
    }

    for (String server in nodesMap.keys) {
      if (nodesMap[server] == null) {
        _logger.config('Server list from Config and Nodes are out of sync. Causing "$server" to be removed');
        nodesMap.remove(server);
      }
    }

    return nodesMap;
  }
}

class _VbucketNodeIterator implements Iterator<MemcachedNode> {
  @override
  MemcachedNode get current => null;

  @override
  bool moveNext() => false;
}

class _TotalConfig {
  Config config;
  Map<String, MemcachedNode> nodesMap;

  _TotalConfig(this.config, this.nodesMap);
}

