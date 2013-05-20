//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * Exception when observe documents.
 */
class ObservedException {
  final message;

  ObservedException([this.message]);

  String toString() {
    if (message == null) return "ObservedException";
    return "ObservedException: $message";
  }
}