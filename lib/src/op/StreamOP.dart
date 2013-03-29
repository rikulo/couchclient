part of rikulo_memcached;

/**
 * An operation that will return a [Stream].
 */
abstract class StreamOP<T> extends OP {
  Stream<T> get stream;
}


