//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of rikulo_memcached;

abstract class BinaryOP extends OP {
  List<int> _cmd; //command in a byte array
  final int _msecs; //TODO: timeout before giving up(in milliseconds)
  OPState state; //null is state 0
  int seq;

  List<int> get cmd
  => _cmd;

  BinaryOP([int msecs = _TIMEOUT])
      : _msecs = msecs;

  int _opCode;
  int _keylen;
  int _extralen;
  int _dataType;
  int _status;
  int _vbucket;
  int _bodylen = _HANDLE_CMD; //== total body length
  int _opaque;
  int _cas;

  //Callback listen to onData of the Socket Steam; will call
  //handleCommand() and handleData() to handle command/data.
  void processResponse(ByteBuffer pbuf) {
    print("pbuf:$pbuf");
    while(true) {
      //handle response header
      if (_bodylen == _HANDLE_CMD) {
        if (pbuf.length < 24) { //not enough header for processing
          break;
        } else {
          _bodylen = handleCommand(pbuf.getRange(0, 24));
          pbuf.removeRange(0, 24);
print("after handleCommand:_bodylen:$_bodylen");
        }
      }

      //handle data
      if (_bodylen >= 0) {
        if (pbuf.length < _bodylen) { //not enough data for processing
          break;
        } else {
          List<int> aLine = pbuf.getRange(0, _bodylen);
          pbuf.removeRange(0, _bodylen);
          _bodylen = handleData(aLine);
print("after handleData:_bodylen:$_bodylen, aline:$aLine");
        }
      }

      //check if complete
      if (_bodylen == _HANDLE_COMPLETE) { //complete, reset parser
        _bodylen = _HANDLE_CMD;
        pbuf.clear();
        print("OPState.COMPLETE: $this\n");
        this.state = OPState.COMPLETE;
        break;
      }
    }
  }

  int handleCommand(List<int> aLine) {
    _opCode = bytesToInt8(aLine, 1);
    _keylen = bytesToInt16(aLine, 2);
    _extralen = bytesToInt8(aLine, 4);
    _dataType = bytesToInt8(aLine, 5);
    _status = bytesToInt16(aLine, 6);
    _bodylen = bytesToInt32(aLine, 8);
    _opaque = bytesToInt32(aLine, 12);
    _cas = bytesToInt64(aLine, 16);

    return _bodylen;
  }
}

//Big-Endian for socket transfer
Uint8List int8ToBytes(int val) {
  if (val >= 128 || val < -128)
    throw new ArgumentError("Integer exceeds 8 bits(-128 ~ 127)");
  final Uint8List bytes = new Uint8List(1);
  bytes[0] = val & 0xff;
  return bytes;
}

int bytesToInt8(List<int> bytes, int start)
=> bytes[start + 0] & 0xff;

//Big-Endian for socket transfer
Uint8List int16ToBytes(int val) {
  if (val >= 32768 || val < -32768)
    throw new ArgumentError("Integer exceeds 16 bits(-32768 ~ 32767)");
  final Uint8List bytes = new Uint8List(2);
  bytes[1] = val & 0xff;
  bytes[0] = (val >> 8) & 0xff;
  return bytes;
}

int bytesToInt16(List<int> bytes, int start)
=> ((bytes[start + 0] & 0xff) << 8) | (bytes[start + 1] & 0xff);

//Big-endian for socket transfer
Uint8List int32ToBytes(int val) {
  if (val >= 2147483648 || val < -2147483648)
    throw new ArgumentError("Integer exceeds 32 bits(-2147483648 ~ 2147483647)");
  final Uint8List bytes = new Uint8List(4);
  bytes[3] = val & 0xff;
  bytes[2] = (val >> 8) & 0xff;
  bytes[1] = (val >> 16) & 0xff;
  bytes[0] = (val >> 24) & 0xff;
  return bytes;
}

int bytesToInt32(List<int> bytes, int start)
=> ((bytes[start + 0] & 0xff) << 24) | ((bytes[start + 1] & 0xff) << 16)
     | ((bytes[start + 2] & 0xff) << 8) | (bytes[start + 3] & 0xff);

Uint8List int64ToBytes(int val) {
  if (val >= 9223372036854775808 || val < -9223372036854775808)
    throw new ArgumentError("Integer exceeds 64 bits(-9223372036854775808 ~ 9223372036854775807)");
  final Uint8List bytes = new Uint8List(8);
  bytes[7] = val & 0xff;
  bytes[6] = (val >> 8) & 0xff;
  bytes[5] = (val >> 16) & 0xff;
  bytes[4] = (val >> 24) & 0xff;
  bytes[3] = (val >> 32) & 0xff;
  bytes[2] = (val >> 40) & 0xff;
  bytes[1] = (val >> 48) & 0xff;
  bytes[0] = (val >> 56) & 0xff;
  return bytes;
}

int bytesToInt64(List<int> bytes, int start)
=> ((bytes[start + 0] & 0xff) << 56) | ((bytes[start + 1] & 0xff) << 48)
     | ((bytes[start + 2] & 0xff) << 40) | ((bytes[start + 3] & 0xff) << 32)
     | ((bytes[start + 4] & 0xff) << 24) | ((bytes[start + 5] & 0xff) << 16)
     | ((bytes[start + 6] & 0xff) << 8) | (bytes[start + 7] & 0xff);

const _MAGIC_REQ = 0x80; //request magic byte for binary packet of this version
const _MAGIC_RES = 0x81; //response magic byte for binary packet of this version

void copyList(List<int> src, int srci, List<int> dst, int dsti, int len) {
  for (int j = 0; j < len; ++j)
    dst[dsti + j] = src[srci + j];
}