part of rikulo_memcached;

abstract class OP {
  List<int> get cmd;
  OPState get state;
  void set state(OPState state);
  int get seq;
  void set seq(int s);

  //handle a command line; return the size of the data block
  //return _HANDLE_COMPLETE to complete the operation
  //return _HANDLE_CMD to continue another command line
  //return >= 0 the data block size to read data block
  int handleCommand(List<int> respcmd);

  //handle data block
  //return _HANDLE_COMPLETE to complete the operation
  //return _HANDLE_CMD to continue another command line
  //return >= 0 the data block size to read data block
  int handleData(List<int> data);

  //Callback listen to onData of the Socket Steam; will call
  //handleCommand() and handleData() to handle data.
  void processResponse(ByteBuffer pbuf);
}

abstract class DeleteOP extends OP {
  Future<bool> get future;
}

abstract class GetOP extends OP {
  Stream<GetResult> get stream;
}

abstract class MutateOP extends OP {
  Future<int> get future;
}

abstract class StoreOP extends OP {
  Future<bool> get future;
}

abstract class TouchOP extends OP {
  Future<bool> get future;
}

abstract class VersionOP extends OP  {
  Future<String> get future;
}

/** Base operation implementation */
final _SPACE = encodeUtf8(' ').first;
final _CRLF = encodeUtf8('\r\n');
final _CR = encodeUtf8('\r').first;
final _LF = encodeUtf8('\n').first;

/** Result of handle operation command */
const int _HANDLE_COMPLETE = -3;
const int _HANDLE_CMD = -2;

/**
 * timeout time for a socket operation; default: 3 minutes
 */
const _TIMEOUT = 180000;
