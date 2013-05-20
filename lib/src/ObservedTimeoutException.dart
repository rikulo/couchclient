//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * Timout exception when observe documents.
 */
class ObservedTimeoutException {
  final message;

  ObservedTimeoutException([this.message]);

  String toString() {
    if (message == null) return "ObservedTimeoutException";
    return "ObservedTimeoutException: $message";
  }
}