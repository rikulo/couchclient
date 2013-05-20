//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

/**
 * Couchbase client implementation of MemcachedConnection that handles
 * Reconfigurable.
 */
//TODO: reconfiguration
class CouchbaseMemcachedConnection extends MemcachedConnection
implements Reconfigurable{
  CouchbaseMemcachedConnection(
      NodeLocator locator,
      ConnectionFactory connFactory,
      OPFactory opFactory,
      FailureMode failureMode)
      : super(locator, connFactory, opFactory, failureMode);

  //--Reconfigurable--//
  bool _reconfiguring = false;

  void reconfigure(Bucket bucket) {
    if (_reconfiguring) return;
    try {
      // get a new collection of addresses from the received config
      final newSaddrs =
          new HashSet<SocketAddress>.from(
              HttpUtil.parseSocketAddressesFromUris(bucket.config.couchServers));

      // split current nodes to "shutdown" nodes and "stay" nodes
      List<MemcachedNode> oddNodes = new List();
      List<MemcachedNode> stayNodes = new List();
      for (MemcachedNode current in locator.allNodes) {
        if (newSaddrs.remove(current.socketAddress)) {
          stayNodes.add(current);
        } else {
          oddNodes.add(current);
        }
      }

      // create a collection of new nodes
      List<MemcachedNode> newNodes = _connFactory.createNodes(newSaddrs);

      // merge stay nodes with new nodes
      stayNodes.addAll(newNodes);

      if (_logger.isLoggable(Level.FINE)) {
        for(MemcachedNode keepingNode in stayNodes) {
          _logger.fine("Node ${keepingNode.socketAddress} "
              "will stay in cluster config after reconfiguration.");
        }
      }

      // call update locator with new nodes list and vbucket config
      if (locator is VbucketNodeLocator) {
        VbucketNodeLocator vlocator = locator;
        vlocator.updateLocatorWithConfig(stayNodes, bucket.config);
      } else {
        locator.updateLocator(stayNodes);
      }

      // schedule shutdown for the oddNodes
      if (_logger.isLoggable(Level.INFO)) {
        for(MemcachedNode node in oddNodes) {
          _logger.info("Scheduling Node ${node.socketAddress} for shutdown.");
        }
      }
      nodesToShutdown.addAll(oddNodes);
    } finally {
      _reconfiguring = false;
    }
  }
}

