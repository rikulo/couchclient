//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Mar 06, 2013  04"08:05 PM
// Author: hernichen

part of couchclient;

/**
 * Interface to monitor configuration updates.
 */
abstract class Reconfigurable {
  /**
   * Called on configuration updates.
   */
  void reconfigure(Bucket bucket);
}
