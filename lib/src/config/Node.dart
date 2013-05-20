//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:36:10 PM
// Author: hernichen

part of couchclient;

class Node {
  final Status status;
  final String hostname;
  final Map<Port, int> ports;

  Node(this.status, this.hostname, this.ports);

  @override
  int get hashCode {
    int h = status != null ? status.hashCode : 0;
    h = 31 * h + hostname.hashCode;
    h = 31 * h + mapHashCode(ports);
    return h;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! Node) return false;

    return this.hostname == other.hostname
        && this.status == other.status
        && mapEquals(this.ports, other.ports);
  }

  @override
  String toString() => "host:$hostname, status:$status, ports:$ports";
}

