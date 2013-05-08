//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

/**
 * Connection to a cluster of Couchbase server nodes.
 */
class CouchbaseConnection extends MemcachedConnection {
  final CouchbaseConnectionFactory _connFactory;

  Logger _logger;
  List<MemcachedNode> _nodesToShutdown;

  CouchbaseConnection(
      NodeLocator locator,
      CouchbaseConnectionFactory connFactory,
      OPFactory opFactory,
      FailureMode failureMode)
      : _connFactory = connFactory,
        _nodesToShutdown = new List(),
        super(locator, connFactory, opFactory, failureMode) {

        _logger = initLogger('couchclient.spi', this);
      }

  void reconfigure(Bucket bucket) {
    // get a new collection of addresses from the received config
    List<String> servers = bucket.config.servers;
    Set<SocketAddress> newServerAddresses = new HashSet();
    List<SocketAddress> newServers = new List();
    for (String server in servers) {
      int finalColon = server.lastIndexOf(':');
      if (finalColon < 1)
        throw new ArgumentError('Invalid server "$server" in vbucket\'s server list');

      String hostPart = server.substring(0, finalColon);
      String portNum = server.substring(finalColon + 1);

      SocketAddress address =
          new SocketAddress(hostPart, int.parse(portNum));

      // add parsed address to our collections
      newServerAddresses.add(address);
      newServers.add(address);
    }

    // split current nodes to "odd nodes" and "stay nodes"
    List<MemcachedNode> oddNodes = new List();
    List<MemcachedNode> stayNodes = new List();
    List<SocketAddress> stayServers = new List();
    for (MemcachedNode current in locator.allNodes) {
      if (newServerAddresses.contains(current.socketAddress)) {
        stayNodes.add(current);
        stayServers.add(current.socketAddress);
      } else {
        oddNodes.add(current);
      }
    }

    // prepare a collection of addresses for new nodes
    newServers.removeWhere((e) => stayServers.contains(e));

    // create a collection of new nodes
    List<MemcachedNode> newNodes = _connFactory.createNodes(newServers);

    // merge stay nodes with new nodes
    List<MemcachedNode> mergedNodes = new List();
    mergedNodes.addAll(stayNodes);
    mergedNodes.addAll(newNodes);

    for(MemcachedNode keepingNode in mergedNodes) {
      _logger.fine("Node ${keepingNode.socketAddress} "
          "will stay in cluster config after reconfiguration.");
    }

    // call update locator with new nodes list and vbucket config
    if (locator is VbucketNodeLocator) {
      VbucketNodeLocator locator0 = locator;
      locator0.updateLocatorWithConfig(mergedNodes, bucket.config);
    } else {
      locator.updateLocator(mergedNodes);
    }
//TODO(20130418, henrichen) : not supporting Throttling yet
//    if(enableThrottling) {
//      for(MemcachedNode node in newNodes) {
//        throttleManager.setThrottler(node.socketAddress);
//      }
//      for(MemcachedNode node in oddNodes) {
//        throttleManager.removeThrottler(node.socketAddress);
//      }
//    }

    // schedule shutdown for the oddNodes
    for(MemcachedNode shutDownNode in oddNodes) {
      _logger.info("Scheduling Node ${shutDownNode.socketAddress} for shutdown.");
    }
    _nodesToShutdown.addAll(oddNodes);
  }

  /**
   * Add an operation to the given connection.
   *
   * + [key] - the key the operation is operating upon
   * + [o] - the operation
   */
  //@Override
  void addOP(String key, OP o) {
    MemcachedNode placeIn = null;
    MemcachedNode primary = locator.getPrimary(key);
    if (primary.isActive || failureMode == FailureMode.Retry) {
      placeIn = primary;
    } else if (failureMode == FailureMode.Cancel) {
      o.cancel();
    } else {
      // Look for another node in sequence that is ready.
      for (Iterator<MemcachedNode> i = locator.getSequence(key);
          placeIn == null && i.moveNext();) {
        MemcachedNode n = i.current;
        if (n.isActive) {
          placeIn = n;
        }
      }
      // If we didn't find an active node, queue it in the primary node
      // and wait for it to come back online.
      if (placeIn == null) {
        placeIn = primary;
        _logger.warning(
            "Node expected to receive data is inactive. This could be due to "
            "a failure within the cluster. Will check for updated "
            "configuration. Key without a configured node is: $key");
        _connFactory.checkConfigUpdate();
      }
    }

    assert(o.isCancelled || placeIn != null);
    if (placeIn != null) {
      // add the vbucketIndex to the operation
      if (locator is VbucketNodeLocator) {
        VbucketNodeLocator vlocator = locator;
        if (o is VbucketAwareOP) {
          VbucketAwareOP vo = o;
          Map<String, int> vbucketMap = new HashMap();
          vbucketMap[key] = vlocator.getVbucketIndex(key);
          vo.setVbucketID(vbucketMap);
          if (!vo.notMyVbucketNodes.isEmpty) {
            MemcachedNode alternative =
                vlocator.getAlternative(key, vo.notMyVbucketNodes);
            if (alternative != null) {
              placeIn = alternative;
            }
          }
        }
      }
//TODO(20130418, henrichen) : not supporting Throttling yet
//      if(enableThrottling) {
//        throttleManager.getThrottler(
//            (InetSocketAddress)placeIn.getSocketAddress()).throttle();
//      }
      addOPToNode(placeIn, o);
    } else {
      assert(o.isCancelled);
    }
  }

  //@Override
  void addMultiKeyOPToNode(List<String> keys, MemcachedNode node, OP op) {
    if (locator is VbucketNodeLocator && op is VbucketAwareOP) {
      final VbucketNodeLocator vlocator = locator;
      Map<String, int> vbucketMap = new HashMap();
      for (String key in keys) {
        vbucketMap[key] = vlocator.getVbucketIndex(key);
      }
      final VbucketAwareOP vop= op;
      vop.setVbucketID(vbucketMap);
    }
    addOPToNode(node, op);
  }
}


