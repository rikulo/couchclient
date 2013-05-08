//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:19:30 PM
// Author: hernichen

part of couchclient;

/**
 * The SpatialViewDesign object represents a SpatialView to be stored and
 * retrieved from the Couchbase cluster.
 */
class SpatialViewDesign {
  /**
   * The name of the view.
   */
  final String name;

  /**
   * The map function of the view.
   */
  final String map;

  /**
   * Create a SpatialViewDesign with a name and map function.
   *
   * + [name] - the name of the view.
   * + [map] - the map function(in JavaScript script) of the view.
   */
  SpatialViewDesign(this.name, this.map);
}
