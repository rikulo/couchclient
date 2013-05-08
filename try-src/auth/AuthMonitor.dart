//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 15, 2013  03:35:02 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Manage and authenticate a new connection.
 */
class AuthMonitor {
  Map<dynamic, AuthFuture<bool>> nodeMap;

  AuthMonitor()
      : nodeMap = new HashMap();

  void authConnection(MemcachedConnection conn, OperationFactory opFact, AuthDescriptor authDescriptor, MemcachedNode node) {
    interruptOldAuth(node);
    Future<bool> newSaslAuthenticator =
        authSasl(conn, opFact, authDescriptor, node);
    nodeMap[node, newSaslAuthenticator]
  }
}


