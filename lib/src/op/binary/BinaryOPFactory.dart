//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  03:53:34 PM
// Author: hernichen

part of rikulo_memcached;

class BinaryOPFactory implements OPFactory {
  DeleteOP newDeleteOP(String key, [int msecs = _TIMEOUT])
  => new BinaryDeleteOP(key, msecs);

  GetOP newGetOP(OPType type, List<String> keys, [int msecs = _TIMEOUT])
  => new BinaryGetOP(type, keys, msecs);

  MutateOP newMutateOP(OPType type, String key, int value, [int msecs = _TIMEOUT])
  => new BinaryMutateOP(type, key, value, msecs);

  StoreOP newStoreOP(OPType type, String key, int flags, int exp, List<int> doc,
                     [int cas, int msecs = _TIMEOUT])
  => new BinaryStoreOP(type, key, flags, exp, doc, cas, msecs);

  TouchOP newTouchOP(String key, int exp, [int msecs = _TIMEOUT])
  => new BinaryTouchOP(key, exp, msecs);

  VersionOP newVersionOP([int msecs = _TIMEOUT])
  => new BinaryVersionOP(msecs);
}

