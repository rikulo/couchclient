//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

/**
 * Client to Couchbase RESTful interface.
 */
abstract class RestClient {
  /**
   * Retrieve all DesignDocs.
   */
  Future<List<DesignDoc>> getDesignDocs();
}
