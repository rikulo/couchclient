//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 21, 2013  02:19:34 PM
// Author: hernichen

part of couchclient;

/**
 * Client to a Couchbase cluster servers.
 *
 *     Future<CouchClient> future = CouchClient.connect(
 *       [Uri.parse("http://localhost:8091/pools")], "default", "");
 *
 *     // Store a value
 *     future
 *      .then((c) => c.set("someKey", someObject))
 *      .then((ok) => print("done"))
 *      .catchError((err) => print("$err");
 *
 *     // Retrieve a value.
 *     future
 *      .then((c) => c.get("someKey"))
 *      .then((myObject) => print("$myObject"))
 *      .catchError((err) => print("$err");
 */
abstract class CouchClient implements MemcachedClient, Reconfigurable {
  /**
   * Get document as a GetResult of the provided key and lock its write
   * access for the specified [locktime] in seconds. The
   * maximum lock time is 30 seconds; any number more than 30 or less than zero
   * would be deemed as 30 seconds.
   * This API returns GetResult if succeed; otherwise, throw OPStatus.NOT_FOUND
   * or other error status.
   */
  Future<GetResult> getAndLock(String key, int locktime);

  /**
   * Unlock document associated with the specified key.
   */
  Future<bool> unlock(String key, int cas);

  /**
   * Create a DesignDoc and add into Couchbase; asynchronously return true
   * if succeed.
   */
  Future<bool> addDesignDoc(DesignDoc doc);

  /**
   * Delete the named DesignDoc.
   */
  Future<bool> deleteDesignDoc(String docName);

  /**
   * Retrieve the named DesignDoc.
   */
  Future<DesignDoc> getDesignDoc(String docName);

  /**
   * Retrieve the named View in the named DesignDoc.
   */
  Future<View> getView(String docName, String viewName);

  /**
   * Retrieve the named SpatialView in the named DesignDoc.
   */
  Future<SpatialView> getSpatialView(String docName, String viewName);

  /**
   * query data from the couchbase with the spcified View(can be [View] or
   * [SpatialView]) and query condition.
   */
  Future<ViewResponse> query(ViewBase view, Query query);

  /**
   * Returns the statistic information of a give key.
   */
  Future<Map<String, String>> keyStats(String key);

  /**
   * Observe a document with the specified key and check its persistency and
   * replicas status in the cluster.
   *
   * + [key] - key of the document
   * + [cas] - expected version of the observed document; null to ignore it. If
   *   specified and the document has been updated, ObserverStatus.MODIFIED
   *   would be returned in ObserveResult.status field.
   */
  Future<Map<SocketAddress, ObserveResult>> observe(String key, [int cas]);

  /**
   * Poll and observe a key with the given cas and persist settings.
   *
   * Based on the given [persistTo], [replicateTo], [isDelete] settings, it
   * observes the key and raises an exception if a timeout has been reached.
   * This method is normally used to make sure that a value is stored/deleted
   * to the status you want it in the cluster.
   *
   * If [persistTo] is not specified, it will default to PersistTo.ZERO and if
   * [replicateTo] is not specified, it will default to ReplicateTo.ZERO. This
   * is the default behavior and is the same as not observing at all.
   *
   * + [key] - the key to observe.
   * + [cas] - (optional) CAS version for the key; default: null to ignore cas check.
   * + [persistTo] - (optional) persistence setting; default: [PersistTo.ZERO].
   * + [replicateTo] - (optional) replication setting; default: [ReplicateTo.ZERO].
   * + [isDelete] - (optional) if the key is to be deleted; default: false.
   */
  Future<bool> observePoll(String key, {
    int cas,
    PersistTo persistTo: PersistTo.ZERO,
    ReplicateTo replicateTo: ReplicateTo.ZERO,
    bool isDelete: false});

  /**
   * Create a new client connectting to the specified Couchbase bucket per
   * the given initial server list in the cluster; this method returns a
   * [Future] that will complete with either a [CouchClient] once connected or
   * an error if the server-lookup or connection failed.
   *
   * + [baseList] - the Uri list of one or more servers from the cluster
   * + [bucket] - the bucket name in the cluster you want to connect.
   * + [password] - the password of the bucket
   */
  static Future<CouchClient> connect(
      List<Uri> baseList, String bucket, String password) {
    return new Future.sync(() {
      final factory = new CouchbaseConnectionFactory(baseList, bucket, password);
      return CouchClientImpl.connect(factory);
    });
  }
}
