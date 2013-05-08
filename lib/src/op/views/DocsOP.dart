//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Mar 12, 2013  02:19:43 PM
// Author: hernichen

part of couchclient;

abstract class DocsOP extends GetHttpOP {
  final Completer<ViewResponse> _cmpl; //completer to complete the future of this operation
  final ViewBase view;

  Future<ViewResponse> get future
  => _cmpl.future;

  DocsOP(this.view, Query query, [int msecs])
      : _cmpl = new Completer() {
    String viewUri = view.uri;
    String queryToRun = query.toString();
    _cmd = Uri.parse('${view.uri}${query.toString()}');
  }

  /**
   * If a String, then return itself; otherwise, json.stringify it.
   */
  String _makeString(dynamic val)
  => val is String ? val : json.stringify(val);
}
