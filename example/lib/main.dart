import 'package:flutter/material.dart';
import 'example_screen.dart';

void main() {
  runApp(const FlutterAlExample());
}

class FlutterAlExample extends StatelessWidget {
  const FlutterAlExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleScreen(),
    );
  }
}
