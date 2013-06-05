//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  04"08:05 PM
// Author: hernichen

part of couchclient;

/**
 * The BucketMonitor will open an HTTP comet stream to monitor for changes to
 * the list of nodes. If the list of nodes changes, it will notify observers.
 */
class BucketMonitor extends Observable {

  final Uri cometStreamUri;
  final String httpUser;
  final String httpPass;

  Logger _logger;

  Bucket bucket;
  HttpClient channel;
  ConfigParserJson configParser;
  String host;
  int port;
  BucketUpdateResponseHandler handler;

  /**
   * The specification version which this client meets. This will be included in
   * requests to the server.
   */
  static const String CLIENT_SPEC_VER = "1.0";

  /**
   * Monitor a Bucket status.
   */
  BucketMonitor(this.cometStreamUri, this.bucket, this.httpUser,
      this.httpPass, ConfigParserJson configParser) {
    _logger = initLogger('couchclient.config', this);
    if (cometStreamUri == null) {
      throw new ArgumentError("cometStreamUri cannot be NULL");
    }
    String scheme = cometStreamUri.scheme == null ?
        "http" : cometStreamUri.scheme;
    if (scheme != "http") {
      // an SslHandler is needed in the pipeline
      throw new UnsupportedError("Only http is supported.");
    }

    this.configParser = configParser;
    this.host = cometStreamUri.host;
    this.port = cometStreamUri.port == -1 ? 80 : cometStreamUri.port;

    //TODO(20130514, henrichen): prepare a loop to monitor the uri
  }

  /**
   * Take any action required when the monitor appears to be disconnected.
   */
  void notifyDisconnected() {
    this.bucket.setIsNotUpdating();
    setChanged();
    _logger.fine("Marked bucket ${bucket.name}"
       " as not updating.  Notifying observers.");
    _logger.finer("There appear to be ${countObservers}"
       " observers waiting for notification");
    notifyObservers(this.bucket);
  }

  // Connect to comet server and wait response
  void _cometConnect() {
    channel = new HttpClient();
    prepareRequest(cometStreamUri, host)
    .then((HttpClientRequest req) {
      return req.close();
    })
    .then((HttpClientResponse resp) {
      _logger.finest("Start bucket monitor host:$host, uri:$cometStreamUri");
      resp.listen((bytes) {
          if (handler == null) { //handle response
            handler = new BucketUpdateResponseHandler();
            handler.setBucketMonitor(this);
          }
          //when receive a full pack of information, will check bucketToMonitor
          handler.messageReceived(decodeUtf8(bytes));
        },
        onDone : () {
          notifyDisconnected();
          if (handler != null)
            handler.disconnect(); //done read response
          if (channel != null) {
            channel.close();
            channel = null;
          }
        },
        onError: (err) { //fail to read response
          notifyDisconnected();
          if (handler != null)
            handler.exceptionCaught(err);
          if (channel != null) {
            channel.close();
            channel = null;
          }
        }
      );
    });
  }

  void startMonitor() {
    if (channel != null) { //already started
      _logger.warning("Bucket monitor is already started.");
      return;
    }
    //connect to the comet push server
    _cometConnect();
  }

  Future<HttpClientRequest> prepareRequest(Uri uri, String h) {
    // Send the HTTP request.
    Future<HttpClientRequest> reqf = HttpUtil.prepareHttpGet(channel, null, uri);
    return reqf.then((HttpClientRequest req) {
      HttpHeaders headers = req.headers;
      headers.host = h;
      headers.persistentConnection = true;
      if (httpUser != null) {
        String basicAuthHeader =
          HttpUtil.buildAuthHeader(httpUser, httpPass);
        headers.set(HttpHeaders.AUTHORIZATION, basicAuthHeader);
      }
      headers.set(HttpHeaders.CONNECTION, "close");
      headers.set(HttpHeaders.CACHE_CONTROL, "no-cache");
      headers.set(HttpHeaders.ACCEPT, "application/json");
      headers.set(HttpHeaders.USER_AGENT, "Couchbase Dart Client");
      headers.set("X-memcachekv-Store-Client-Specification-Version", CLIENT_SPEC_VER);
      headers.contentType = new ContentType("application", "json", charset: "utf-8");
      return req;
    });
  }

  /**
   * Update the config if it has changed and notify our observers.
   *
   * @param bucketToMonitor the bucketToMonitor to set
   */
  void setBucket(Bucket newBucket) {
    _logger.finest("setBucket: bucket:${this.bucket.hashCode}, "
      "newBucket:${newBucket.hashCode}, equals:${bucket == newBucket}");
    if (this.bucket == null || this.bucket != newBucket) {
      this.bucket = newBucket;
      setChanged();
      notifyObservers(this.bucket);
    }
  }

  /**
   * Shut down this monitor in a graceful way.
   */
  void shutdown([int timeout = -1]) {
    deleteObservers();
    if (channel != null) {
      channel.close();
    }
  }

  /**
   * Replace the previously received configuration with the current one.
   */
  void replaceConfig() {
    String response = handler.lastResponse;
    _logger.finest("lastResponse:$response");
    Bucket updatedBucket = this.configParser.parseBucket(json.parse(response));
    setBucket(updatedBucket);
  }
}
