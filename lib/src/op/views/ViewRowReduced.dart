//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

/**
 * A result row retrieved from View.
 */
class ViewRowReduced extends ViewRow {
  final String _key;
  final String _value;

  ViewRowReduced(String key, String value)
      : _key = ViewRow._valid(key),
        _value = ViewRow._valid(value);

  String get key
  => _key;

  String get value
  => _value;

  String toString()
  => "key:$_key, value:$_value";

}

