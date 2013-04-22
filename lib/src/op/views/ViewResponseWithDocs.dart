//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

class ViewResponseWithDocs extends ViewResponse {
  Map<String, dynamic> _map;

  ViewResponseWithDocs(List<ViewRow> rows, List<ViewRowError> errors
      , [Map<String, dynamic> map])
      : this._map = map,
        super(rows, errors);

  Map<String, dynamic> get map {
    if (_map ==  null) {
      _map = new HashMap();

      for(ViewRow row in rows)
        map[row.id] = row.doc;
    }
    return _map;
  }
}

