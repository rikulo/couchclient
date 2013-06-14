//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Jun 13, 2013  02:10:35 PM
// Author: hernichen

part of couchclient;

/**
 * List design documents on couchbase(via Restful interface);
 * see https://coderwall.com/p/lg_sbw
 */
class ListDesignDocsOP extends GetHttpOP {
  final Completer<List<DesignDoc>> _cmpl; //completer to complete the future of this operation

  Future<List<DesignDoc>> get future
  => _cmpl.future;

  ListDesignDocsOP(String bucketName, [int msecs])
      : _cmpl = new Completer() {

    _cmd = Uri.parse('/pools/default/buckets/$bucketName/ddocs');
  }

  void processResponse(String base) {
    Map jo = json.parse(base);
    if (jo.containsKey('error')) {
      _cmpl.complete(null);
      return;
    }
    List<Map<String, Map>> ddocsjo = jo['rows'];
    List<DesignDoc> ddocs = new List();
    for (Map<String, Map> ddocjo in ddocsjo) {
      final docjo = ddocjo['doc'];
      //var ctrljo = ddocjo["controllers"];
      final metajo = docjo['meta'];
      final qid = metajo['id'];
      final int j = qid.lastIndexOf('/');
      final id = qid.substring(j+1);
      final jsonjo = docjo['json'];
      ddocs.add(_newDesignDoc(id, jsonjo));
    }
    _cmpl.complete(ddocs);
  }
}


