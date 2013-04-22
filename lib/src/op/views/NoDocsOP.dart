//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Mar 12, 2013  02:19:43 PM
// Author: hernichen

part of couchclient;

class NoDocsOP extends DocsOP {
  NoDocsOP(AbstractView view, Query query, [int msecs])
      : super(view, query, msecs);

  void processResponse(String base) {
//    print("NoDocsOP:base->[$base]");
    Map jo = json.parse(base);
    List<ViewRow> viewRows = new List();
    List<ViewRowError> errors = new List();
    if (jo.containsKey('rows')) {
      List<Map> rows = jo['rows'];
      for (Map row in rows) {
        String id = _makeString(row['id']);
        String value = _makeString(row['value']);
        if (row.containsKey('bbox')) {
          String bbox = _makeString(row['bbox']);
          String geometry = _makeString(row['geometry']);
          viewRows.add(new SpatialViewRowNoDocs(id, bbox, geometry, value));
        } else {
          String key = _makeString(row['key']);
          viewRows.add(new ViewRowNoDocs(id, key, value));
        }
      }
    }
    if (jo.containsKey('debug_info')) {
      print('Debug View $view.uri: base');
    }
    if (jo.containsKey("errors")) {
      List<Map> errs = jo['errors'];
      for (Map err in errs) {
        String from = _makeString(err['from']);
        String reason = _makeString(err['reason']);
        errors.add(new ViewRowError(from, reason));
      }
    }
    _cmpl.complete(new ViewResponseNoDocs(viewRows, errors));
  }
}
