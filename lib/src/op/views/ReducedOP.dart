//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Mar 12, 2013  02:19:43 PM
// Author: hernichen

part of couchclient;

class ReducedOP extends DocsOP {
  ReducedOP(AbstractView view, Query query, [int msecs])
      : super(view, query, msecs);

  void processResponse(String base) {
    print("ReducedOP:base->[$base]");
    Map jo = json.parse(base);
    List<ViewRow> viewRows = new List();
    List<ViewRowError> errors = new List();
    if (jo.containsKey('rows')) {
      List<Map> rows = jo['rows'];
      for (Map row in rows) {
        String value = _makeString(row['value']);
        String key = _makeString(row['key']);
        viewRows.add(new ViewRowReduced(key, value));
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
    _cmpl.complete(new ViewResponseReduced(viewRows, errors));
  }
}
