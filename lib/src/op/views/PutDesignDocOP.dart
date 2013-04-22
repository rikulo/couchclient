//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, Mar 07, 2013  02:35:43 PM
// Author: hernichen

part of couchclient;

class PutDesignDocOP extends PutHttpOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future
  => _cmpl.future;

  final String designDocName;

  PutDesignDocOP(String bucketName, this.designDocName, String value)
      : _cmpl = new Completer(),
        super(value) {

    _cmd = Uri.parse('/$bucketName/_design/$designDocName');
  }

  void processResponse(String base) {
    print("PutDesignDocOP: base->[$base]");
    Map jo = json.parse(base);
    bool ok = jo['ok'];
    _cmpl.complete(ok != null && ok);
  }
}


