//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 14, 2013  02:38:19 PM
// Author: hernichen

part of couchclient;

class RestNode extends ViewNode {
  RestNode(SocketAddress saddr, int opTimeout, AuthDescriptor authDescriptor)
      : super(saddr, opTimeout, authDescriptor);
}
