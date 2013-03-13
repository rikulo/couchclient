//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  11:41:31 AM
// Author: hernichen

part of rikulo_memcached;

class DesignDoc {
  /**
   * The name of the design document
   */
  final String name;

  /**
   * The language of the views
   */
  final String language;

  /**
   * Associated views to this design document.
   */
  final List<ViewDesign> views;

  /**
   * Associated spatial views to this design docuemnt.
   */
  final List<SpatialViewDesign> spatialViews;

  DesignDoc(this.name, {this.language : 'javascript', List<ViewDesign> views,
            List<SpatialViewDesign> spatialViews})
      : this.views = views == null ? new List() : views,
        this.spatialViews = spatialViews == null ? new List() : spatialViews;

  void addView(ViewDesign view) {
    this.views.add(view);
  }

  void addSpatialView(SpatialViewDesign spatialView) {
    this.spatialViews.add(spatialView);
  }

  String toJson() {
    if (views.isEmpty && spatialViews.isEmpty)
      throw new StateError("A design document needs a view");
    if (name.isEmpty)
      throw new StateError("A design document needs a name");
    Map<String, dynamic> jo = new LinkedHashMap();
    jo['language'] = language;

    Map<String, Map> viewsjo = new LinkedHashMap();
    jo['views'] = viewsjo;
    for (ViewDesign view in views) {
      Map<String, dynamic> viewjo = new LinkedHashMap();
      viewjo['map'] = view.map;
      if (!view.reduce.isEmpty) {
        viewjo['reduce'] = view.reduce;
      }
      viewsjo[view.name] = viewjo;
    }

    if (!spatialViews.isEmpty) {
      Map<String, String> spatialViewsjo = new LinkedHashMap();
      jo['spatial'] = spatialViewsjo;
      for (SpatialViewDesign spatialView in spatialViews) {
        Map<String, dynamic> viewjo = new LinkedHashMap();
        spatialViewsjo[spatialView.name] = spatialView.map;
      }
    }

    return json.stringify(jo);
  }
}
