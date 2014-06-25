//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 14, 2013  02:38:19 PM
// Author: hernichen

part of couchclient;

class RestConnection {
  final CouchbaseConnectionFactory _connFactory;

  Logger _logger;
  List<RestNode> couchNodes;

  RestConnection(
      List<SocketAddress> saddrs,
      CouchbaseConnectionFactory connFactory)
      : _connFactory = connFactory {

    _logger = initLogger('couchclient.spi', this);
    //_logger.finest('saddrs:$saddrs');
    couchNodes = createRestNodes(saddrs);
  }

  List<RestNode> createRestNodes(List<SocketAddress> saddrs) {
    List<RestNode> nodes = new List();
    for (SocketAddress saddr in saddrs)
      nodes.add(_connFactory.createRestNode(saddr));
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
        RestNode node = _nextNode();
        if (node.isClosing()) {
          ++retries;
          continue;
        }
        if (retries > 0) {
          //_logger.finest('Retrying rest operation "$op" on node: ${node.socketAddress}');
        }
        node.addOP(op);
        break;
      } while(true);
    }
  }

  int _nexti = 0;
  RestNode _nextNode() {
    _nexti = (++_nexti) % couchNodes.length;
    return couchNodes[_nexti];
  }
}

