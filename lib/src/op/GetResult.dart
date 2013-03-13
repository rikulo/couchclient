part of rikulo_memcached;

/** Represent a result after execute get command */
class GetResult {
  final String key;
  final int flags;
  final int cas;
  final List<int> data;

  GetResult(this.key, this.flags, this.cas, this.data);

  String toString()
  => '$key : $data, flags:$flags, cas:$cas';
}
