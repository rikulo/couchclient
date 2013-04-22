//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Apr 12, 2013  03:41:22 PM
// Author: hernichen

part of couchclient;

/**
 * PersistTo codes for a Observe operation.
 */
class PersistTo extends Enum {

  /**
   * Don't wait for persistence on any nodes.
   */
  static const PersistTo ZERO = const PersistTo(0);
  /**
   * Persist to the Master. ONE implies MASTER.
   */
  static const PersistTo MASTER = const PersistTo(1);
  /**
   * ONE implies MASTER.
   */
  static const PersistTo ONE = const PersistTo(1);
  /**
   * Persist to at least two nodes including Master.
   */
  static const PersistTo TWO = const PersistTo(2);
  /**
   * Persist to at least three nodes including Master.
   */
  static const PersistTo THREE = const PersistTo(3);
  /**
   * Persist to at least four nodes including Master.
   */
  static const PersistTo FOUR = const PersistTo(4);

  const PersistTo(int val)
      : super(val);

  int get value
  => ordinal;
}
