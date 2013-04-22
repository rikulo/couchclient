//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:31:09 PM
// Author: hernichen

part of couchclient;

/**
 * Bucket configuration.
 */
class Bucket {
  String name; //Bucket name
  Config config; //configuration
  Uri streamingUri; //bucket's streaming uri
  bool isNotUpdating;
  List<Node> nodes;
  Logger _logger;

  Bucket(this.name, this.config, this.streamingUri, this.nodes)
      : isNotUpdating = false {

    _logger = initLogger('couchbase.config', this);
  }

  int get hashCode {
    int result = name.hashCode;
    result = 31 * result + config.hashCode;
    result = 31 * result + nodes.hashCode;
    return result;
  }

  void setIsNotUpdating() {
    isNotUpdating = true;
    _logger.finest("Marking bucket as not updating,"
        " disconnected from config stream");
  }
}

