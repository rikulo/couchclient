//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * Modified exception when observe documents.
 */
class ObservedModifiedException {
  final message;

  ObservedModifiedException([this.message]);

  String toString() {
    if (message == null) return "ObservedModifiedException";
    return "ObservedModifiedException: $message";
  }

}