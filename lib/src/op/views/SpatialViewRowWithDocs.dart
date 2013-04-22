//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * A result row retrieved from View.
 */
class SpatialViewRowWithDocs extends ViewRow {
  final String _id;
  final String _bbox;
  final String _geometry;
  final String _value;
  final dynamic _doc;

  SpatialViewRowWithDocs(String id, String bbox, String geometry, String value, dynamic doc)
      : this._id = _valid(id),
        this._bbox = _valid(bbox),
        this._geometry = _valid(geometry),
        this._value = _valid(value),
        this._doc = doc;

  String get id
  => _id;

  String get bbox
  => _bbox;

  String get geometry
  => _geometry;

  String get value
  => _value;

  get doc
  => _doc;

  String toString()
  => "id:$_id, bbox:$_bbox, geometry:$_geometry, value:$_value, doc:$_doc";
}

