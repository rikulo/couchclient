//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:40:31 PM
// Author: hernichen

part of couchclient;

class Status extends Enum {
  static const Status healthy = const Status('healthy', 0);
  static const Status unhealthy = const Status('unhealthy', 1);
  static const Status warmup = const Status('warmup', 2);

  static Map _statusMap;

  final String name;
  const Status(String name, int ordinal)
      : this.name = name,
        super(ordinal);

  static Status valueOf(String name) {
    if (_statusMap == null) {
      _statusMap = new HashMap();
      _statusMap['healthy'] = Status.healthy;
      _statusMap['unhealthy'] = Status.unhealthy;
      _statusMap['warmup'] = Status.warmup;
    }
    return _statusMap[name];
  }
}

