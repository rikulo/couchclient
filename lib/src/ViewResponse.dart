//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * Holds the response of a queried view.
 */
abstract class ViewResponse {
  /**
   * Returns queried rows.
   */
  final Iterable<ViewRow> rows;

  /**
   * Returns queried row errors if any.
   */
  final Iterable<ViewRowError> errors;

  ViewResponse(this.rows, this.errors);

  /**
   * Returns the mapped document of the keys.
   */
  Map<String, dynamic> get map {
    throw new UnsupportedError("This view doesn't contain"
        "documents");
  }

  /**
   * Returns the length of the queried rows.
   */
  int get length => rows.length;
}

