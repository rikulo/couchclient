//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

/**
 * A result row retrieved from View.
 */
abstract class ViewRow {
  String get id {
    throw new UnsupportedError("This views result doesn't contain "
        "document id");
  }

  String get value;

  String get key {
    throw new UnsupportedError("This views result doesn't contain "
        "key");
  }

  String get bbox {
    throw new UnsupportedError("This views result doesn't contain "
        "Bounding Box information");
  }

  String get geometry {
    throw new UnsupportedError("This view result doesn't contain "
        "Geometry information");
  }

  dynamic get doc {
    throw new UnsupportedError("This view result doesn't contain "
        "documents");
  }

  static String _valid(String f)
  => f != null && 'null' == f ? null : f;
}

