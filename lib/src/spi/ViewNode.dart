part of couchclient;

class ViewNode {
  final SocketAddress socketAddress;
  final int _opTimeout;
  final HttpOPChannel _opChannel;

  Logger _logger;
  bool _closing = false;

  ViewNode(SocketAddress saddr, int opTimeout, AuthDescriptor authDescriptor)
      : socketAddress = saddr,
        _opTimeout = opTimeout,
        _opChannel = new HttpOPChannel(saddr, authDescriptor) {
    _logger = initLogger('couchclient.spi', this);
  }

  int get opTimeout => _opTimeout;

  /**
   * True if this node is active; i.e. it is connected and
   * able to process requests.
   */
  bool get isActive => opChannel.isConnected && opChannel.isAuthenticated;

  /**
   * Prepend an HttpOP at the beginning of the operation queue.
   */
  void prependOP(HttpOP op) {
    opChannel.prependOP(op);
  }

  /**
   * Add an HttpOP at the end of the operation queue.
   */
  void addOP(HttpOP op) {
    opChannel.addOP(op);
  }

  /**
   * close the connection to this node.
   */
  void close() {
    _closing = true;
    opChannel.close();
  }

  /**
   * Returns whether this node is closing.
   */
  bool isClosing() => _closing;

  /**
   * Returns an OPChannel for socket accessing.
   */
  HttpOPChannel get opChannel => _opChannel;
}
