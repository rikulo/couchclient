//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:05:11 PM
// Author: hernichen

part of couchclient;

/**
 * The base class for Views and Spatial Views.
 *
 * This class acts as a base class for both map/reduce views and spatial
 */
abstract class ViewBase {
  final String viewName;
  final String designDocName;
  final String bucketName;

  ViewBase(this.bucketName, this.designDocName, this.viewName);

  /**
   * Checks if the view has a "map" method defined.
   *
   * @return true if it has a "map" method defined, false otherwise.
   */
  bool get hasMap;

  /**
   * Checks if the view has a "reduce" method defined.
   *
   * @return true if it has a "reduce" method defined, false otherwise.
   */
  bool get hasReduce;

  /**
   * Returns the URI/String representation of the View.
   *
   * @return the URI path of the View to query against the cluster.
   */
  String get uri;
}
