//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 08, 2013  10:36:35 AM
// Author: hernichen

part of couchclient;

class ViewResponseNoDocs extends ViewResponse {
  ViewResponseNoDocs(List<ViewRow> rows, List<ViewRowError> errors)
      : super(rows, errors);
}

