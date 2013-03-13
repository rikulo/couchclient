//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:09:05 PM
// Author: hernichen

part of rikulo_memcached;

/**
 * Holds information about a spatial view that can be queried in
 * Couchbase Server.
 */
class SpatialView extends AbstractView {

  SpatialView(String bucketName, String designDocName, String viewName)
      : super(bucketName, designDocName, viewName);

  /**
   * Will always return true, because Spatial Views need to have a map
   * function.
   *
   * @return true.
   */
  //@override
  bool get hasMap
  => true;

  /**
   * Will always return false, because Spatial Views can't have reduce
   * functions.
   *
   * @return false.
   */
  //@override
  bool get hasReduce
  => false;

  //@override
  String get uri
  => "/$bucketName/_design/$designDocName/_spatial/$viewName";
}

