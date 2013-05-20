//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  04"08:05 PM
// Author: hernichen

part of couchclient;

/**
 * Work with [BucketMonitor] to handle Bucket configuration changes.
 */
class BucketUpdateResponseHandler {
  String lastResponse;
  StringBuffer _partialResponse;
  BucketMonitor _monitor;
  Logger _logger;

  BucketUpdateResponseHandler() {
    _logger = initLogger('couchclient.config', this);
  }

  void messageReceived(String curChunk) {
    _logger.finest("curChunk:$curChunk");
    if (this._partialResponse == null) {
      this._partialResponse = new StringBuffer();
    }
    /*
     * Server sends four new lines in a chunk as a sentinal between
     * responses.
     */
    int j = curChunk.indexOf("\n\n\n\n");
    if (j >= 0) { //end of a chunk
      String tail = curChunk.substring(0, j);
      _partialResponse.write(tail);
      lastResponse = _partialResponse.toString();
      _partialResponse = new StringBuffer();
      _partialResponse.write(curChunk.substring(j+4));
      _logger.finer("End of Chunk, Response length is: ${lastResponse.length}");
      if (_monitor != null)
        _monitor.replaceConfig();
    } else {
      _logger.finer("Chunk length is: ${curChunk.length}");
      _partialResponse.write(curChunk);
    }
  }

  void setBucketMonitor(BucketMonitor newMonitor) {
    this._monitor = newMonitor;
  }

  /*
   * @todo we need to investigate why the exception occurs, and if there is a
   * better solution to the problem than just shutting down the connection. For
   * now just invalidate the BucketMonitor, and we will recreate the connection.
   */
  void exceptionCaught(Object err) {
    _logger.warning("Exception occurred: $err");
    if (_monitor != null)
      _monitor.replaceConfig();
  }

  //TODO: the monitor has been disconnected; might need to do something?
  void disconnect() {
    _logger.finest("disconnect!");
  }
}
