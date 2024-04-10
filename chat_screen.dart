import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/api/apis.dart';
import 'package:welcome_app/helper/inference.dart';
import 'package:welcome_app/main.dart';
import 'package:welcome_app/models/chat_user.dart';
import 'package:welcome_app/models/message.dart';
import 'package:welcome_app/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  final Interpreter interpreter;

  ChatScreen({Key? key, required this.user, required this.interpreter});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SpeechToText speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  late ScrollController _scrollController;
  String _recognizedText = '';
  String latestMessage = '';
  bool _shouldScrollToBottom = true;
  bool _isTyping = false;
  List<Message> _list = [];
  late TextEditingController _textController;
  
  bool _isListening = false;
  
  bool _showEmoji =  false; // Declare TextEditingController

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(); // Initialize TextEditingController
    _initializeSpeechToText();
    _scrollController = ScrollController();
    initializeTts();
  }

  void initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
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

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose(); // Dispose TextEditingController
    super.dispose();
  }

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
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: APIS.getAllMessages(widget.user),
                builder: (context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(child: CircularProgressIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                          ?.map<Message>((e) => Message.fromJson(e.data()))
                          .toList() ?? [];

                      if (!_isTyping && _shouldScrollToBottom && _list.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: _list.length,
                        padding: EdgeInsets.only(top: 8),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          latestMessage =
                              _list.isNotEmpty ? _list[index].msg : '';
                          return MessageCard(message: _list[index]);
                        },
                      );
                    default:
                      return SizedBox();
                  }
                },
              ),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _appBar() {
    return InkWell(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black),
          ),
          // Other app bar widgets...
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * .01,
        horizontal: MediaQuery.of(context).size.width * .025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      // Handle speech to text
                    },
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  ),
                  Expanded(
                    child: _recognizedText.isNotEmpty
                        ? Text(_recognizedText)
                        : TextField(
                            controller: _textController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Type Something...',
                              hintStyle: TextStyle(
                                  color: Colors.blueAccent),
                              border: InputBorder.none,
                            ),
                          onChanged: (value) {
                              setState(() {
                                _isTyping = value.isNotEmpty;
                              });
                            },
                          ),
                  ),
                  


                  IconButton(
                      onPressed: () {
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon:
                          Icon(Icons.emoji_emotions, color: Colors.blueAccent)),

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
    performInference(widget.interpreter, latestMessage);
    List<List<double>> userX = preprocessUserInput(latestMessage);

    // Print the results
    print("User Input: $latestMessage");
  },
  minWidth: 0,
  shape: CircleBorder(),
  color: Colors.green,
  padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
  child:Text(
        'TTS', // Add your desired text here
        style: TextStyle(color: Colors.white), // Adjust text color as needed
      ),
),

MaterialButton(
  onPressed: () {
    if (_textController.text.isNotEmpty) {
      APIS.sendMessage(widget.user, _textController.text);
      setState(() {
        _textController.clear(); // Clear the text input field
      });
    } else if (_recognizedText.isNotEmpty) {
      APIS.sendMessage(widget.user, _recognizedText);
      setState(() {
        _recognizedText = ''; // Clear the recognized text
      });
    }
  },

  // Rest of your button properties...

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
  try {
    // Preprocess the input data
    List<List<double>> userX = preprocessUserInput(input);

    // Define the shape of the output tensor
    var outputShape = [1, 2]; // Adjust this according to your model's output shape

    // Initialize the output tensor
    var output = List.filled(outputShape.reduce((a, b) => a * b), 0).reshape(outputShape);

    // Run the inference
    interpreter.run(userX, output);

    // Print or handle the result of the inference
    print('Output tensor: ${output.toString()}');
  } catch (e) {
    print('Error during inference: $e');
  }
}








