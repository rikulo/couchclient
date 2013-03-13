//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 04, 2013  05:22:30 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * A colletion of [Bucket]s.
 */
class Pool {
  final String name; //pool name
  final Uri uri; //pool uri
  final Uri streamingUri; //pool's streaming uri
  Uri bucketsUri; //buckets related to this pool
  Map<String, Bucket> _currentBuckets;

  Pool(this.name, this.uri, this.streamingUri);

  Map<String, Bucket> get currentBuckets {
    if (_currentBuckets == null) {
      throw new StateError("Buckets were never populated.");
    }
    return _currentBuckets;
  }

  void replaceBuckets(Map<String, Bucket> replacing) {
    _currentBuckets = new HashMap.from(replacing);
  }

  bool hasBucket(String bucketName)
  => currentBuckets.containsKey(bucketName);
}

