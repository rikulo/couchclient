part of rikulo_memcached;

/**
 * An operation that will return a [Future].
 */
abstract class FutureOP<T> extends OP {
  Future<T> get future;
}
