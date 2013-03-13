//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

/**
 * A result row retrieved from View.
 */
class ViewRowWithDocs extends ViewRow {
  final String _id;
  final String _key;
  final String _value;
  final dynamic _doc;

  ViewRowWithDocs(String id, String key, String value, dynamic doc)
      : this._id = ViewRow._valid(id),
        this._key = ViewRow._valid(key),
        this._value = ViewRow._valid(value),
        this._doc = doc;

  String get id
  => _id;

  String get key
  => _key;

  String get value
  => _value;

  get doc
  => _doc;

  String toString()
  => "id:$_id, key:$_key, value:$_value, doc:$_doc";
}

