// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/api/apis.dart';
import 'package:welcome_app/helper/inference.dart';
import 'package:welcome_app/helper/load_model.dart';

import 'package:welcome_app/main.dart';
import 'package:welcome_app/models/chat_user.dart';
import 'package:welcome_app/models/message.dart';
import 'package:welcome_app/widgets/message_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:core';



class ChatScreen extends StatefulWidget {
  final ChatUser user;
  final Interpreter interpreter;

  ChatScreen({super.key, required this.user, required this.interpreter});
  

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SpeechToText speechToText = SpeechToText();


  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
    initializeTts();
  }

  
  final FlutterTts flutterTts = FlutterTts();
  void initializeTts() async {
  await flutterTts.setLanguage("en-US"); // Set desired language (optional)
  await flutterTts.setSpeechRate(1.0);   // Set speech rate (optional)
  await flutterTts.setVolume(1.0);       // Set volume (optional)
}

  String normalizeTextForTTS(String text) {
  // Remove any unwanted characters or symbols
  text = text.replaceAll(RegExp(r'[^\w\s]'), '');

  // Define a separate function to handle number normalization
  String replaceNumbers(Match match) {
    String? matchedText = match.group(0);
    if (matchedText != null) {
      switch (matchedText) {
        case '0':
          return 'zero';
        case '1':
          return 'one';
        case '2':
          return 'two';
        // Add more cases for other numbers as needed
        default:
          return matchedText;
      }
    } else {
      return ''; // Handle null case as needed
    }
  }

  // Normalize any numbers to words (optional)
  text = text.replaceAllMapped(RegExp(r'\d+'), replaceNumbers);

  // Additional normalization steps as needed

  return text;
}



  Future<void> _initializeSpeechToText() async {
    bool available = await speechToText.initialize();
    if (available) {
      print('Speech to text initialized successfully');
    } else {
      print('Failed to initialize speech to text');
      // Handle initialization failure
    }
  }


  var text = "";
  bool _isListening = false;
  String _recognizedText = '';
  String latestMessage = " ";




  // void _startListening() {
  //   // Implement the logic to start listening for voice input
  //   setState(() {
  //     _isListening = true;
  //   });
  // }

  // void _stopListening() {
  //   // Implement the logic to stop listening for voice input
  //   setState(() {
  //     _isListening = false;
  //   });
  // }

  // void _handleVoiceInput(String text) {
  //   // Handle the recognized text, e.g., send it as a message
  //   if (text.isNotEmpty) {
  //     APIS.sendMessage(widget.user, text);
  //   }
  // }
  //for storing all messages

  List<Message> _list = [];

  //for handling messages text changes
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 234, 248, 255),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
          backgroundColor: Colors.white,
        ),
        body: Column(children: [
          Expanded(
            child: StreamBuilder(
                stream: APIS.getAllMessages(widget.user),
                builder: (context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(child: SizedBox());

                    //if data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;

                      _list = data
                              ?.map<Message>((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];

                      

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                               latestMessage = _list.isNotEmpty ? _list[index].msg : '';
                              return MessageCard(
                                message: _list[index],
                              );
                            });
                      } else {
                        return const Center(
                            child: Text('Say Hi! 👋',
                                style: TextStyle(fontSize: 20)));
                      }
                  }
                }),
          ),
          _chatInput()
        ]),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      child: Row(children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black)),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            width: mq.height * .055,
            height: mq.height * .055,
            imageUrl: widget.user.image,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                CircleAvatar(child: Icon(CupertinoIcons.person)),
          ),
        ),
        SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.name,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2),
            Text(
              'Last Seen Not Available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            )
          ],
        )
      ]),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // VoiceInputButton(
                  //     onTextRecognized: (text) {
                  //       // Handle recognized text as needed
                  //       setState(() {
                  //         _recognizedText = text;
                  //       });
                  //     },
                  //   ),

                  // ),

                  FloatingActionButton(
                      onPressed: () {},
                      child: AvatarGlow(
                          // endRadius: 75.0,
                          // animate: _isListening,
                          // duration: Duration(milliseconds: 2000),
                          // repeat: true,
                          // repeatPauseDuration: Duration(milliseconds: 100),
                          // showTwoGlows: true,
                          child: GestureDetector(
                              onTapDown: (details) async {
                                if (!_isListening) {
                                  setState(() {
                                    _isListening = true;
                                    print("here is stt");

                                    try {
                                      speechToText.listen(
                                        onResult: (result) {
                                          setState(() {
                                            _recognizedText =
                                                result.recognizedWords;
                                          });
                                        },
                                      );
                                    } catch (e) {
                                      print(
                                          'Error starting speech recognition: $e');
                                      // Handle speech recognition error
                                    }
                                  });
                                }
                              },
                              onTapUp: (details) {
                                setState(() {
                                  _isListening = false;
                                });
                                speechToText.stop();
                              },
                              child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none)))),

                  Expanded(
                    child: _recognizedText.isNotEmpty
                        ? Text(_recognizedText) // Display the recognized text
                        : TextField(
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Type Something...',
                              hintStyle: TextStyle(color: Colors.blueAccent),
                              border: InputBorder.none,
                            ),
                          ),
                  ),
                  // IconButton(
                  //     onPressed: () {},
                  //     icon:
                  //         Icon(Icons.emoji_emotions, color: Colors.blueAccent)),

                  //  IconButton(
                  //     onPressed: () {
                  //       // Toggle voice input
                  //       if (_isListening) {
                  //         _stopListening();
                  //       } else {
                  //         _startListening();
                  //       }
                  //     },
                  //     icon: Icon(
                  //       _isListening ? Icons.mic_off : Icons.mic,
                  //       color: Colors.blueAccent,
                  //     ),
                  //   ),

                  SizedBox(width: mq.width * .02)
                ],
              ),
            ),
          ),

           MaterialButton(
            onPressed: () async {
              // Get the latest received message
               latestMessage = _list.isNotEmpty
                  ? _list.last.msg
                  : 'No messages received';

              // Speak the latest received message
              await flutterTts.speak(latestMessage);
              performInference(widget.interpreter,latestMessage);
  List<List<double>> userX = preprocessUserInput(latestMessage);
  Future<int> predictedLabel = makePrediction(userX);

  // Print the results
  print("User Input: $latestMessage");
  print("Predicted Emotion Label: $predictedLabel");

            },
            minWidth: 0,
            shape: CircleBorder(),
            color: Colors.green,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            child: Icon(
              Icons.star,
              color: Colors.green,
              size: 28,
            ),
          ),
          MaterialButton(
              onPressed: () {
                 if (_textController.text.isNotEmpty) {
                  APIS.sendMessage(widget.user, _textController.text);
                  _textController.text = '';
                }
              },
            minWidth: 0,
            shape: CircleBorder(),
            color: Colors.green,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
  String getLatestMessage() {
    return latestMessage;
  }
}

Future<void> performInference(Interpreter interpreter, String input) async {

  List<double> inputTokens = preprocessData(input);
  // List<List<double>> input_2 = preprocessUserInput(preprocessData(input));
  
  String modelFilePath = 'assets/lstm_ed';
// final modelFilePath = path.join('lib', 'screens', 'lstm_ed.tflite');
  // await loadModelData();
 
  File modelFile =  await writeAssetToFile(modelFilePath);
  print(File(modelFilePath).existsSync());
  final interpreter = Interpreter.fromFile(modelFile);
  interpreter.allocateTensors();
  // Define the shape and data type of the output tensor (replace with your model's output shape and type)
  var outputShape = [1, 2]; // Example: [batch_size, num_classes]
  var outputType = TensorType.float32; // Example: float32

// Initialize the output tensor based on the shape and type
var output = List.filled(outputShape.reduce((a, b) => a * b), 0).reshape(outputShape);

// Print the initialized output tensor (optional)
print(output);


   interpreter.run(input,output); // Pass the preprocessed input to the interpreter
  
  // Postprocess the output if needed
  // For emotion detection, you might parse the output to get the detected emotion
  
  // Print or handle the result of the inference
  print('Detected emotion: ${output.toString()}');
}






