import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tflite_flutter/tflite_flutter.dart';

class InterpreterProvider extends StatelessWidget {
  final Widget child;
  final Interpreter interpreter;
  

  const InterpreterProvider({ super.key, required this.child, required this.interpreter});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      
      value: interpreter,
      child: child,
    );
  }

}


void main() {
  Interpreter interpreter;
  
  // Path to the model file
  String modelFilePath = '/images/lstm_ed.tflite';
  // Read the contents of the file
  File modelFile = File(modelFilePath);
  // print(modelFile.existsSync());
  print(File(modelFilePath).existsSync());
  // if (!modelFile.existsSync()) {
  //   print('Model file does not exist or cannot be accessed.');
  //   return;
  // }

   interpreter = Interpreter.fromFile(modelFile);
  interpreter.allocateTensors();

  try {
    // Read the file contents as bytes
    List<int> bytes = modelFile.readAsBytesSync();

    // Print the number of bytes read
    print('Read ${bytes.length} bytes from the model file.');

    // Optionally, you can parse or process the contents of the file here
  } catch (e) {
    print('Error reading model file: $e');
  }
   String input = "It is a beautiful day ";
   var output;
  // Preprocess the input data if necessary
  // For text-based models, tokenization and encoding may be required
  
  // Run inference
   interpreter.run(input,output); // Pass the preprocessed input to the interpreter
  
  // Postprocess the output if needed
  // For emotion detection, you might parse the output to get the detected emotion
  
  // Print or handle the result of the inference
  print('Detected emotion: ${output.toString()}');
}





