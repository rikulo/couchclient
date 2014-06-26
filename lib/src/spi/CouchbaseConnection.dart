//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

/**
 * Connection to a cluster of Couchbase server nodes.
 */
class CouchbaseConnection extends MemcachedConnection
implements Reconfigurable {
  final CouchbaseConnectionFactory _connFactory;

  Logger _logger;

  CouchbaseConnection(
      NodeLocator locator,
      CouchbaseConnectionFactory connFactory,
      OPFactory opFactory,
      FailureMode failureMode)
      : _connFactory = connFactory,
        super(locator, connFactory, opFactory, failureMode) {

        _logger = initLogger('couchclient.spi', this);
      }

  //--Reconfigurable--//
  bool _reconfiguring = false;
  @override
  Future reconfigure(Bucket bucket) {
    if (_reconfiguring)
      return new Future.value();

    List<MemcachedNode> oddNodes = new List();
    List<MemcachedNode> stayNodes = new List();
    return new Future.sync(() {
      _reconfiguring = true;
      final newSaddrs =
          new HashSet<SocketAddress>.from(
              HttpUtil.parseSocketAddressesFromStrings(bucket.config.servers));
      //_logger.finest("newSaddrs:$newSaddrs");
      // split current nodes to "shutdown" nodes and "stay" nodes
      for (MemcachedNode current in locator.allNodes) {
        if (newSaddrs.remove(current.socketAddress)) {
          stayNodes.add(current);
        } else {
          oddNodes.add(current);
        }
      }

      // create a collection of new nodes
      return _connFactory.createNodes(newSaddrs);
    })
    .then((List<MemcachedNode> newNodes) {
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
//TODO(20130418, henrichen) : not supporting Throttling yet
//      if(enableThrottling) {
//        for(MemcachedNode node in newNodes) {
//          throttleManager.setThrottler(node.socketAddress);
//        }
//        for(MemcachedNode node in oddNodes) {
//          throttleManager.removeThrottler(node.socketAddress);
//        }
//      }

      // schedule shutdown for the oddNodes
      if (_logger.isLoggable(Level.INFO)) {
        for(MemcachedNode node in oddNodes) {
          _logger.info("Scheduling Node ${node.socketAddress} for shutdown.");
        }
      }
      nodesToShutdown.addAll(oddNodes);
    })
    .whenComplete(() {
      _reconfiguring = false;
    });
  }

  /**
   * Locate the server node to add an operation into.
   *
   * + [key] - the key the operation is operating upon
   * + [o] - the operation
   */
  @override
  MemcachedNode locateNode(String key, OP o) {
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

    return placeIn;
  }

  @override
  void addSingleKeyOPToNode(String key, MemcachedNode placeIn, OP o) {
    assert(o.isCancelled || placeIn != null);
    if (placeIn != null) {
      // add the vbucketIndex to the operation
      if (locator is VbucketNodeLocator) {
        VbucketNodeLocator vlocator = locator;
        if (o is VbucketAwareOP) {
          VbucketAwareOP vo = o as VbucketAwareOP;
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

  @override
  void addMultiKeyOPToNode(List<String> keys, MemcachedNode node, OP op) {
    if (locator is VbucketNodeLocator && op is VbucketAwareOP) {
      final VbucketNodeLocator vlocator = locator;
      Map<String, int> vbucketMap = new HashMap();
      for (String key in keys) {
        vbucketMap[key] = vlocator.getVbucketIndex(key);
      }
      final VbucketAwareOP vop= op as VbucketAwareOP;
      vop.setVbucketID(vbucketMap);
    }
    addOPToNode(node, op);
  }
}
