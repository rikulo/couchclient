//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of rikulo_memcached;

class GetSpatialViewOP extends GetHttpOP {
  final Completer<SpatialView> _cmpl; //completer to complete the future of this operation

  Future<SpatialView> get future
  => _cmpl.future;

  final String bucketName;
  final String designDocName;
  final String viewName;

  GetSpatialViewOP(this.bucketName, this.designDocName, this.viewName, [int msecs])
      : _cmpl = new Completer(),
        super(msecs) {
    _cmd = Uri.parse('/$bucketName/_design/$designDocName');
  }

  void processResponse(String base) {
    print("GetSpatialViewOP:base->[$base]");
    Map jo = json.parse(base);
    Map<String, Map> viewsjo = jo['spatial'];
    if (viewsjo != null) {
      for(String name in viewsjo.keys) {
        if (viewName == name) {
          Map<String, String> mapjo = viewsjo[name];
          SpatialView view = new SpatialView(bucketName, designDocName, viewName);
          _cmpl.complete(view);
          return;
        }
      }
    }
    _cmpl.complete(null);
  }
}


