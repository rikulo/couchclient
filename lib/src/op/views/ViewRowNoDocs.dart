//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

/**
 * A result row retrieved from View.
 */
class ViewRowNoDocs extends ViewRow {
  final String _id;
  final String _key;
  final String _value;

  ViewRowNoDocs(String id, String key, String value)
      : _id = ViewRow._valid(id),
        _key = ViewRow._valid(key),
        _value = ViewRow._valid(value);

  String get id
  => _id;

  String get key
  => _key;

  String get value
  => _value;

  String toString()
  => "id:$_id, key:$_key, value:$_value";
}

