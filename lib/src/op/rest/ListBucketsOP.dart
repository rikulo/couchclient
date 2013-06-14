//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Jun 13, 2013  02:10:35 PM
// Author: hernichen

part of couchclient;

/**
 * List Bucket names on couchbase(via Restful interface);
 * see https://coderwall.com/p/lg_sbw
 */
class ListBucketsOP extends GetHttpOP {
  final Completer<List<String>> _cmpl; //completer to complete the future of this operation

  Future<List<String>> get future
  => _cmpl.future;

  ListBucketsOP([int msecs])
      : _cmpl = new Completer() {

    _cmd = Uri.parse('/pools/default/buckets/');
  }

  void processResponse(String base) {
    List<String> names = new List();
    if (base != null && base.trim() != '') {
      List jo = json.parse(base);
      for (Map<String, String> bucketjo in jo) {
        final name = bucketjo['name'];
        if (name != null)
          names.add(name);
      }
    }
    _cmpl.complete(names);
  }
}


