//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Feb 26, 2013  11:09:34 AM
// Author: hernichen

part of rikulo_memcached;

abstract class TextOP extends OP {
  List<int> _cmd; //command in a byte array
  final int _msecs; //TODO: timeout before giving up(in milliseconds)
  OPState _state; //null is state 0
  int seq;

  List<int> get cmd
  => _cmd;

  OPState get state
  => _state;

  void set state(OPState s) {
    _state = s;
  }

  int _crj = -2, //CR code position
      _size = _HANDLE_CMD; //the data block size to read data block

  TextOP([int msecs = _TIMEOUT])
      : _msecs = msecs;

  //Callback listen to onData of the Socket Steam; will call
  //handleCommand() and handleData() to handle command/data.
  void processResponse(ByteBuffer pbuf) {
    int bl = 0;
    int el = _size >= 0 ? _size : -2; //expected end of line

    int end = pbuf.length;

    //parse lines in buf
    for(int j = pbuf.offset; j < end; ++j) {
      if (pbuf[j] == _CR)
        _crj = j;
      else if (pbuf[j] == _LF
          && (_crj + 1) == j
          && (el < 0 || j == el + 1)) { //find the end of line "\r\n"
        _crj = -2; //reset _crj
        el = j - 1; //without ending CRLF

        //process a line
        List<int> aLine = pbuf.getRange(bl, el - bl);
        _size = _size >= 0 ?
            handleData(aLine) : //handle data block
            handleCommand(aLine); //handle command line

        //prepare next line
        if (_size == _HANDLE_COMPLETE) {
          break;
        } else {
          bl = el + 2;
          el = _size == _HANDLE_CMD ? -2 : bl + _size;
        }
      }
    }

    //chop buf if necessary
    if (_size == _HANDLE_COMPLETE) { //complete, reset parser
      _crj = -2;
      _size = _HANDLE_CMD;
      pbuf.clear();
      print("OPState.COMPLETE: $this\n");
      this.state = OPState.COMPLETE;
    } else
      pbuf.removeRange(0, bl);
  }

  int handleCommand(List<int> aLine)
  => handleTextCommand(decodeUtf8(aLine));

  int handleTextCommand(String aLine);
}
