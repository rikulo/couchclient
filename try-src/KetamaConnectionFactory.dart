//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * ConnectionFactory instance that sets up a ketama compatible connection.
 *
 * This implementation uses both the `KetamaNodeLocator` and the
 * `HashAlgorithm.KETAMA_HASH` to provide consistent node hashing.
 *
 * See [RJ's blog post]<http://www.last.fm/user/RJ/journal/2007/04/10/392555/>.
 */
class KetamaConnectionFactory extends DefaultConnectionFactory {
  KetamaConnectionFactory()
      : super(HashAlgorithm.KETAMA_HASH);

  Future<NodeLocator> createLocator(List<MemcachedNode> nodes)
  => new Future.immediate(new KetamaNodeLocator(nodes, hashAlgorithm));
}
