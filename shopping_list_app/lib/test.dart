import 'dart:async';

bool b = true;

void main() {
  print("hello");

  var z;
  new Future(() => 42)
      .then((value) => {z = value})
      .whenComplete(() => {b = false});

  idle();

  print(z);
}

Future<void> idle() async {
  while (b) {
    print("idle");
  }
}
