//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Apr 12, 2013  03:45:41 PM
// Author: hernichen

part of couchclient;

/**
 * ReplicateTo codes for a Observe operation.
 */
class ReplicateTo extends Enum {
  /**
   * Replicate to at least zero nodes.
   */
  static const ReplicateTo ZERO = const ReplicateTo(0);
  /**
   * Replicate to at least one node.
   */
  static const ReplicateTo ONE = const ReplicateTo(1);
  /**
   * Replicate to at least two nodes.
   */
  static const ReplicateTo TWO = const ReplicateTo(2);
  /**
   * Replicate to at least three nodes.
   */
  static const ReplicateTo THREE = const ReplicateTo(3);

  const ReplicateTo(int val)
      : super(val);

  int get value
  => ordinal;
}
