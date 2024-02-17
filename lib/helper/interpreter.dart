import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class InterpreterProvider extends StatelessWidget {
  final Widget child;
  final Interpreter interpreter;
  

  InterpreterProvider({required this.child, required this.interpreter});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      
      value: interpreter,
      child: child,
    );
  }

}
