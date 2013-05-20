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

    _logger = initLogger('couchclient.config', this);
  }

  void setIsNotUpdating() {
    isNotUpdating = true;
    _logger.finest("Marking bucket as not updating,"
        " disconnected from config stream");
  }

  @override
  String toString() => "$name: $config, $nodes";

  @override
  int get hashCode {
    int h = name.hashCode;
    h = 31 * h + config.hashCode;
    h = 31 * h + listHashCode(nodes);
    return h & 0xffffffff;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! Bucket) return false;
    return this.name == other.name
        && this.config == other.config
        && listEquals(this.nodes, other.nodes);
  }
}

