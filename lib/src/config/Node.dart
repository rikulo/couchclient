//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:36:10 PM
// Author: hernichen

part of couchclient;

class Node {
  final Status status;
  final String hostname;
  final Map<Port, int> ports;

  Node(this.status, this.hostname, this.ports);
}

