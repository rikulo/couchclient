//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 14, 2013  03:43:19 PM
// Author: hernichen

part of couchclient;

class RestClientImpl implements RestClient {
  final CouchbaseConnectionFactory _connFactory;
  RestConnection _restConn;
  Logger _logger;

  RestClientImpl(CouchbaseConnectionFactory connFactory)
      : _connFactory = connFactory {

    final List<SocketAddress> uaddrs =
        HttpUtil.parseSocketAddressesFromUris(_connFactory.configProvider.baseList);
    _restConn = _connFactory.createRestConnection(uaddrs);
    _logger = initLogger('couchclient', this);
  }

  Future<List<DesignDoc>> listDesignDocs() {
    ListDesignDocsOP op = new ListDesignDocsOP(_connFactory.bucketName);
    _handleRestOperation(op);
    return op.future;
  }

  Future<List<String>> listBucketNames() {
    ListBucketsOP op = new ListBucketsOP();
    _handleRestOperation(op);
    return op.future;
  }

  void _handleRestOperation(HttpOP op) {
    _restConn.addOP(op);
  }
}
