import 'dart:async';

void f1(int seq) {
  f.then((_) => print("then f1-$seq"));
}

void f2(int seq) {
  f.then((_) => print("then f2-$seq"));
}

Future f;

void main() {
  Completer cmpl = new Completer();
  f = cmpl.future;
//  f2(30);
  f1(0);
  f1(1);
  f1(2);
  f1(3);
  f1(4);
  cmpl.complete(null);
  f1(5);
  f2(20);
}
