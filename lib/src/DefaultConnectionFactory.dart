//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Default implementation of ConnectionFactory.
 *
 * This implementation creates connections with 'Redistribute' FailureMode.
 */
class DefaultConnectionFactory implements ConnectionFactory {
  HashAlgorithm _hashAlg;
  final FailureMode _failureMode;
  final AuthDescriptor _authDescriptor;

  DefaultConnectionFactory([
      HashAlgorithm hashAlg,
      FailureMode failureMode = FailureMode.Redistribute])
      : _failureMode = failureMode,
        _authDescriptor = new AuthDescriptor(["PLAIN"], null, null) {
    _hashAlg = hashAlg == null ? NATIVE_HASH : hashAlg;
  }

  //@Override
  MemcachedNode createMemcachedNode(SocketAddress saddr) {
    final OPFactory opf = opFactory;
    if (opf is TextOPFactory)
      return new TextMemcachedNodeImpl(saddr);
    else if (opf is BinaryOPFactory)
      return new BinaryMemcachedNodeImpl(saddr, authDescriptor.bucket, authDescriptor.password);
    else
      throw new StateError("Unhandled OPFactory Type: $opf");
  }

  //@Override
  Future<MemcachedConnection> createConnection(List<SocketAddress> saddrs) {
    List<MemcachedNode> nodes = createNodes(saddrs);
    return createLocator(nodes)
      .then((locator)
          => new MemcachedConnection(locator, this, opFactory, failureMode))
      .catchError((err) => 'MemcachedConnection:\n$err');
  }

  List<MemcachedNode> createNodes(List<SocketAddress> saddrs) {
    List<MemcachedNode> nodes = new List();

    for (SocketAddress saddr in saddrs)
      nodes.add(createMemcachedNode(saddr));

    return nodes;
  }

  //@Override
  Future<NodeLocator> createLocator(List<MemcachedNode> nodes)
  => new Future.immediate(new ArrayModNodeLocator(nodes, hashAlgorithm));

  //@Override
  OPFactory get opFactory
  => new TextOPFactory();

  //@Override
  int get opTimeout
  => 2500;

  //@Override
  FailureMode get failureMode
  => _failureMode;

  //@Override
//TODO:
//  Transcoder get transcoder
//  => new SerializingTranscoder();

  /**
   * The HashAlgorithm used in the connections built by
   * this connection factory(for hashing the key).
   */
  HashAlgorithm get hashAlgorithm
  => _hashAlg;

  /**
   * The maximum number of milliseconds to wait between reconnection attempts
   * used in the connections built by this connection factory.
   */
  int get maxReconnectDelay
  => 30;

  /**
   * The authentication descriptor associated with the connections built by
   * this connection factory.
   */
  AuthDescriptor get authDescriptor
  => _authDescriptor;
}
