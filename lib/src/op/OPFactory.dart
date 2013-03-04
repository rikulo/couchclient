part of rikulo_memcached;

abstract class OPFactory {
  DeleteOP newDeleteOP(String key, [int msecs = _TIMEOUT]);

  GetOP newGetOP(OPType type, List<String> keys, [int msecs = _TIMEOUT]);

  MutateOP newMutateOP(OPType type, String key, int value, [int msecs = _TIMEOUT]);

  StoreOP newStoreOP(OPType type, String key, int flags, int exp, List<int> doc,
                     [int cas, int msecs = _TIMEOUT]);

  TouchOP newTouchOP(String key, int exp, [int msecs = _TIMEOUT]);

  VersionOP newVersionOP([int msecs = _TIMEOUT]);
}
