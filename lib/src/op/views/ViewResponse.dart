//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

abstract class ViewResponse {
  final List<ViewRow> rows;
  final List<ViewRowError> errors;

  ViewResponse(this.rows, this.errors);

  Map<String, dynamic> get map {
    throw new UnsupportedError("This view doesn't contain"
        "documents");
  }
}

