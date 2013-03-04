part of rikulo_memcached;

/** a Get Operation */
class TextGetOP extends TextOP implements GetOP {
  final StreamController<GetResult> _streamCtrl;

  Stream<GetResult> get stream
  => _streamCtrl.stream;

  TextGetOP(OPType type, List<String> keys, [int msecs = _TIMEOUT])
      : _streamCtrl = new StreamController(),
        super(msecs) {
    _cmd = _prepareGetCommand(type, keys);
  }

  //temporary storage
  String _key;
  int _flags;
  int _cas;
  bool _hasValue = false;

  int handleTextCommand(String line) {
    int result = _handleCommand0(line);
    if (result == _HANDLE_COMPLETE)
      _streamCtrl.close();
    return result;
  }

  int _handleCommand0(String line) {
    print("GetOpCommand: $this, [${line}]");
    if ("END" == line) {
      return _HANDLE_COMPLETE; //complete
    } else if (line.startsWith("VALUE ")) {
      List<String> items = line.split(' ');
      _key = items[1];
      _flags = int.parse(items[2]);
      int size = int.parse(items[3]);
      _cas = items.length > 4 ? int.parse(items[4]) : null;
      return size;
    } else {
      OPStatus status = TextOPStatus.valueOfError(line);
      if (status != null) { //some error occur!
        _streamCtrl.signalError(status);
        return _HANDLE_COMPLETE; //complete
      }

      //TODO: unknown protocol, try to read thru!
      _streamCtrl.signalError(new OPStatus(OPStatus.INTERAL_ERROR.code, "PROTOCOL_ERROR 'Unknown get result format:[$line]'"));
      return _HANDLE_CMD;
    }
  }

  //Override
  int handleData(List<int> buf) {
    _streamCtrl.add(new GetResult(_key, _flags, _cas, buf));
    return _HANDLE_CMD; //handle next line of command
  }

  /** Prepare a multi get command.
   */
  List<int> _prepareGetCommand(OPType type, List<String> keys) {
    List<int> cmd = new List();

    cmd.addAll(encodeUtf8(type.name));
    for(String key in keys) {
      cmd..add(_SPACE)
         ..addAll(encodeUtf8(key));
    }
    cmd.addAll(_CRLF);

    print("_prepareGetCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString()
  => "GetOP: $seq";
}
