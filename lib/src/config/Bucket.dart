//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:31:09 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Bucket configuration.
 */
class Bucket {
  String name; //Bucket name
  Config config; //configuration
  Uri streamingUri; //bucket's streaming uri
  bool isNotUpdating;
  List<Node> nodes;

  Bucket(this.name, this.config, this.streamingUri, this.nodes)
      : isNotUpdating = false;
}

