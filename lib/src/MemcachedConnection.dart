//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Connection to a cluster of memcached server nodes.
 */
class MemcachedConnection {
  final NodeLocator locator;
  final ConnectionFactory _connFactory;
  final OPFactory _opFactory;
  final FailureMode _failureMode;

  Logger _logger;
  bool _closing = false;

  MemcachedConnection(NodeLocator locator, ConnectionFactory connFactory,
      OPFactory opFactory, FailureMode failureMode)
      : locator = locator,
        _connFactory = connFactory,
        _opFactory = opFactory,
        _failureMode = failureMode {

    _logger = initLogger('memcached', this);
  }

  void addOP(String key, OP op) {
    validateKey(key, _opFactory is BinaryOPFactory);
    _checkState();
    MemcachedNode placeIn = null;
    MemcachedNode primary = locator.getPrimary(key);
    if (primary.isActive || _failureMode == FailureMode.Retry) {
      placeIn = primary;
    } else if (_failureMode == FailureMode.Cancel) {
      op.cancel();
    } else {
      // Look for another node in sequence that is ready.
      Iterator<MemcachedNode> i = locator.getSequence(key);
      while (placeIn == null && i.moveNext()) {
        MemcachedNode node = i.current;
        if (node.isActive)
          placeIn = node;
      }
      // If we didn't find an active node, queue it in the primary node
      // and wait for it to come back online.
      if (placeIn == null) {
        placeIn = primary;
        _logger.warning(
            "Could not redistribute "
            "to another node, retrying primary node for $key.");
      }
    }

    if (placeIn != null) {
      placeIn.addOP(op);
    }
  }

  void prependOPToNode(MemcachedNode node, OP op) {
    _checkState();
    node.prependOP(op);
  }

  void addOPToNode(MemcachedNode node, OP op) {
    _checkState();
    node.addOP(op);
  }

  Future<Map<SocketAddress, dynamic>> broadcastOP(FutureOP newOP(), List<MemcachedNode> nodes) {
    if (_closing )
      throw new StateError("Shutting down the connection");
    List<Future> futures = new List();
    Map<SocketAddress, dynamic> results = new HashMap();
    for(MemcachedNode node in nodes) {
      FutureOP op = newOP();
      addOPToNode(node, op);
      op.future
        .then((rv) => results[node.socketAddress] = rv)
        .catchError((err) => _logger.warning("OP:$op, $err"));

      futures.add(op.future);
    }
    return Future.wait(futures)
      .then((_) => results)
      .catchError((err) => _logger.warning("broadcastOP: $err"));
  }

  void close() {
    _closing = true;
    for (MemcachedNode node in locator.allNodes) {
      node.close();
    }
  }

  void _checkState() {
    if (_closing)
      throw new StateError("Connection is closing");
  }

}
