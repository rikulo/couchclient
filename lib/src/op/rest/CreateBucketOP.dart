//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Jun 13, 2013  05:11:10 PM
// Author: hernichen

part of couchclient;

/**
 * Create a Bucket on couchbase(via Restful interface);
 * see https://coderwall.com/p/lg_sbw
 */
class CreateBucketOP extends PostHttpOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future
  => _cmpl.future;

  /**
   * Create a Bucket.
   * + [type] - BucketType.
   */
  CreateBucketOP(BucketType type, String name, int memorySizeMB,
      AuthType authType, int replicas, int port, String password,
      bool flushEnabled, [int msecs])
      : _cmpl = new Completer() {

    _cmd = Uri.parse('/pools/default/buckets');
    StringBuffer sb = new StringBuffer();
    sb..write("name=")..write(name);
    sb..write("&ramQuotaMB=")..write(memorySizeMB);
    sb..write("&authType=")..write(authType.name);
    sb..write("&replicaNumber=")..write(replicas);
    sb..write("&bucketType=")..write(type.name);
    sb..write("&proxyPort=")..write(port);
    if (authType == AuthType.SASL) {
      sb..write("&saslPassword=")..write(password);
    }
    if(flushEnabled) {
      sb..write("&flushEnabled=1");
    }
    this.value = sb.toString();
  }

  void processResponse(HttpResult result) {
    _cmpl.complete(result.status == HttpStatus.ACCEPTED);
  }
}


