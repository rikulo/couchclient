//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * Holds the error information of a ViewRow.
 */
class ViewRowError {
  final String from;
  final String reason;

  ViewRowError(this.from, this.reason);
}