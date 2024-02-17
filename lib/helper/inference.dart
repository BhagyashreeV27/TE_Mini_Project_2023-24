import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/helper/load_model.dart';


String modelFilePath = 'assets/lstm_ed';

 
 

// Function to preprocess the user input
List<List<double>> preprocessUserInput(String userInput) {
  // Preprocess the user input text
  List<double> userInputSequence = preprocessData(userInput);

  // Pad or truncate the sequence to match the model's input length
  // Assuming userInputSequence is a List<dynamic>
List<double> processedSequence = List<double>.from(userInputSequence.take(66));
int remainingLength = 66 - userInputSequence.length;
if (remainingLength > 0) {
  processedSequence.addAll(List<double>.filled(remainingLength, 0));
}


  // Convert the input to a list of lists (required format for TFLite input)
  List<List<double>> userX = [processedSequence];

  return userX;
}

// Function to preprocess the input text (similar to preprocess_data function in Python)
List<double> preprocessData(String userInput) {
  // Tokenize the input text (you may need to implement this based on your model requirements)
  List<String> tokens = userInput.split(' ');

  // Encode the tokens into numerical values (you may need to implement this based on your model requirements)
  List<double> encodedInput = encodeInput(tokens);

  return encodedInput;
}

// Function to encode input tokens (similar to encode_input function in Python)
List<double> encodeInput(List<String> tokens) {
  // Initialize a list to store encoded values
  List<double> encodedInput = [];

  // Iterate through each token in the list of tokens
  for (String token in tokens) {
    // Check if the token exists in the word index
    // if (wordIndex2.containsKey(token)) {
    // //   // Get the index of the token from the word index
    // //   int index = wordIndex2[token];
    // //   // Append the index to the encoded input list
    // //   encodedInput.add(index.toDouble());
    // } else {
      // If the token is not found in the word index, append 0 as an unknown token
      encodedInput.add(0);
    // }
  }

  // Return the encoded input
  return encodedInput;
}


// Function to make the prediction using the TFLite model
Future<int> makePrediction(List<List<double>> userX)  async{
  // Load and initialize the TFLite interpreter (you should have already done this)

  // Perform inference using the TFLite interpreter
  var output = List.filled(1 * 2, 0).reshape([1, 2]);
   File modelFile =   await writeAssetToFile(modelFilePath);
  final interpreter = Interpreter.fromFile(modelFile);
  interpreter.allocateTensors();
  // interpreter.run(userX, output);

  // Decode the output to obtain the predicted emotion label
  int predictedLabel = output[0].indexOf(output[0].reduce((value, element) => value > element ? value : element));

  return predictedLabel;
}

// Example usage
void main() {
  String userInput = "Goodness gracious, that's quite the shock!";
  List<List<double>> userX = preprocessUserInput(userInput);
  Future<int> predictedLabel = makePrediction(userX);

  // Print the results
  print("User Input: $userInput");
  print("Predicted Emotion Label: $predictedLabel");
}
