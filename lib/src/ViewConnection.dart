part of rikulo_memcached;

class ViewConnection {
  final CouchbaseConnectionFactory _connFactory;

  Logger _logger;
  List<ViewNode> couchNodes;

  ViewConnection(
      List<SocketAddress> saddrs,
      CouchbaseConnectionFactory connFactory)
      : _connFactory = connFactory {

    _logger = initLogger('couchbase', this);
    _logger.finest('saddrs:$saddrs');
    couchNodes = createViewNodes(saddrs);
  }

  List<ViewNode> createViewNodes(List<SocketAddress> saddrs) {
    List<ViewNode> nodes = new List();
    for (SocketAddress saddr in saddrs)
      nodes.add(_connFactory.createViewNode(saddr));
    return nodes;
  }

  void addOP(HttpOP op) {
    if (couchNodes.isEmpty) {
      _logger.severe("No server connection. Cancel op.");
      op.cancel();
    } else {
      int retries = 0;
      do {
        if (retries > couchNodes.length) {
          _logger.severe("Tried all server connections. None is open. Cancel op: $op.");
          op.cancel();
          break;
        }
        ViewNode node = _nextNode();
        if (node.isClosing()) {
          ++retries;
          continue;
        }
        if (retries > 0) {
          _logger.finest('Retrying view operation "$op" on node: ${node.socketAddress}');
        }
        node.addOP(op);
        break;
      } while(true);
    }
  }

  int _nexti = 0;
  ViewNode _nextNode() {
    _nexti = (++_nexti) % couchNodes.length;
    return couchNodes[_nexti];
  }
}

