import '../../packages/memcached_client/memcached_client.dart';
import '../../packages/logging/logging.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert' show UTF8;

class Connect {
  Logger _logger;
  int seq = 0;
  StreamController _ctrl = new StreamController();
  Socket _socket;
  List<int> _pbuf;
  Connect(String host, int port) {
    _pbuf = new List();
    _logger = initLogger("memcached.test", this);

    Socket.connect(host, port)
    .then((Socket socket) {
      _socket = socket;
      _socket.listen(
        (List<int> data) {
          if (data == null || data.length <= 0) //no data
            return;
          _pbuf.addAll(data);
          processResponse();
        },
        onError: (err) => _logger.warning("Socket response:$err"),
        onDone: () => _logger.finest("Socket closed!")
      );
    });
  }

  void processResponse() {
    ++seq;
    _ctrl.add("$seq - value1");
    _ctrl.add("$seq - value2");
    if (UTF8.decode(_pbuf).endsWith("END\r\n")) {
      print("Close StreamController!");
      _ctrl.close();
    }
  }

  Stream get stream
  => _ctrl.stream;

  void start() {
    _processLoop();
  }

  void _processLoop() {
    new Future.delayed(new Duration())
    .then((_) {
        //_logger.finest("_processLoop...");
      if (_socket == null) {
        //_logger.finest("Wait socket to be connected.");
        _processLoop();
      } else {
        //_logger.finest("Write 'get key0 key0' to socket.");
        _socket.write("get key0 key1\r\n");
      }
    })
    .catchError((err) => _logger.warning("_processLoop:\n$err"));
  }
}

void main() {
  setupLogger();
  Connect conn = new Connect("localhost", 11211);
  conn.start();
  Stream stream = conn.stream;
  stream.listen(
    (data) => print("data -> $data"),
    onError: (err) => print("err -> $err"),
    onDone: () => print("done")
  );
}


