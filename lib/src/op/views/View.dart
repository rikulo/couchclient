//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:09:05 PM
// Author: hernichen

part of couchclient;

class View extends AbstractView {
  final bool _map;
  final bool _reduce;

  View(String bucketName, String designDocName, String viewName, bool map, bool reduce)
      : this._map = map,
        this._reduce = reduce,
        super(bucketName, designDocName, viewName);

  //@override
  bool get hasMap
  => _map;

  //@override
  bool get hasReduce
  => _reduce;

  //@override
  String get uri
  => "/$bucketName/_design/$designDocName/_view/$viewName";
}

