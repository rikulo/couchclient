part of couchclient;

class ViewConnection implements Reconfigurable {
  final CouchbaseConnectionFactory _connFactory;

  Logger _logger;
  List<ViewNode> couchNodes;

  ViewConnection(
      List<SocketAddress> saddrs,
      CouchbaseConnectionFactory connFactory)
      : _connFactory = connFactory {

    _logger = initLogger('couchclient.spi', this);
    //_logger.finest('saddrs:$saddrs');
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
        //if (retries > 0) {
        //  _logger.finest('Retrying view operation "$op" on node: ${node.socketAddress}');
        //}
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

  //--Reconfigurable--//
  bool _reconfiguring = false;
  /**
   * Reconfigures the connected ViewNodes.
   *
   * Whenever reconfiguration event heppens, new ViewNodes may need to be added
   * or old ones need to be removed from the current configuration. This method
   * takes care that those operations are performed in the correct order.
   */
  @override
  Future reconfigure(Bucket bucket) {
    if (_reconfiguring)
      return new Future.value();

    return new Future.sync(() {
      _reconfiguring = true;

      final newSaddrs =
          new HashSet<SocketAddress>.from(
              HttpUtil.parseSocketAddressesFromUris(bucket.config.couchServers));

      //split current nodes into "odd" nodes and "stay" nodes
      List<ViewNode> oddNodes = new List();
      List<ViewNode> stayNodes = new List();

      for (ViewNode node in couchNodes) {
        if (newSaddrs.remove(node.socketAddress)) {
          stayNodes.add(node);
        } else {
          oddNodes.add(node);
        }
      }

      //create new nodes and merge into one set of nodes
      List<ViewNode> newNodes = createViewNodes(new List.from(newSaddrs));
      stayNodes.addAll(newNodes);

      couchNodes = stayNodes;

      //shutdown "odd" nodes
      for (ViewNode node in oddNodes) {
        node.close();
      }
    })
    .whenComplete(() {
      _reconfiguring = false;
    });
  }
}
