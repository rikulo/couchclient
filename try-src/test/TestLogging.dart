import '../../packages/logging/logging.dart';

class MyClass {
  Logger _logger;
  MyClass() {
    _logger = new Logger('a.b.${this.runtimeType}');
  }

  test1() {
    _logger.finest('log MyClass');
  }
}

class MyClass2 {
  Logger _logger;
  MyClass2() {
    _logger = new Logger('a.${this.runtimeType}');
  }

  test1() {
    _logger.finest('log MyClass2');
  }
}

void main() {
  initLogger("a", Level.ALL);

  MyClass c1 = new MyClass();
  c1.test1();
  MyClass2 c2 = new MyClass2();
  c2.test1();
}

void initLogger([String loggerName = '', Level lv = Level.ALL]) {
  hierarchicalLoggingEnabled = true;
  Logger root = new Logger(loggerName);
  root.level = lv;
  root.onRecord.listen((LogRecord r) {
    print('${r.sequenceNumber} ${r.time} ${r.loggerName} ${r.level}: ${r.message}');
  });
}