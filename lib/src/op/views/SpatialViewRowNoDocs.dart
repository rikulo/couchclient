//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

/**
 * A result row retrieved from View.
 */
class SpatialViewRowNoDocs extends ViewRow {
  final String _id;
  final String _bbox;
  final String _geometry;
  final String _value;

  SpatialViewRowNoDocs(String id, String bbox, String geometry, String value)
      : this._id = ViewRow._valid(id),
        this._bbox = ViewRow._valid(bbox),
        this._geometry = ViewRow._valid(geometry),
        this._value = ViewRow._valid(value);

  String get id
  => _id;

  String get bbox
  => _bbox;

  String get geometry
  => _geometry;

  String get value
  => _value;

  String toString()
  => "id:$_id, bbox:$_bbox, geometry:$_geometry, value:$_value";
}

