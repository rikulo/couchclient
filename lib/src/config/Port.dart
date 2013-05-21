//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:31:09 PM
// Author: hernichen

part of couchclient;

class Port extends Enum {
  static const Port direct = const Port('direct', 0);

  static const Port proxy = const Port('proxy', 1);

  static List<Port> values = [Port.direct, Port.proxy];

  final String name;
  const Port(this.name, int ordinal)
      : super(ordinal);

  String toString() => "$name($ordinal)";
}

