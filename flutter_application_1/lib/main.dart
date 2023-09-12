import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(child: TextToSpeech()),
              
        )
    );
  }
}

class TextToSpeech extends StatelessWidget {

  TextToSpeech({super.key});

  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textEditingController = TextEditingController();
   
  speak() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1); //0.5 to 1.5
    await flutterTts.speak(textEditingController.text);
  }

  @override
  Widget build(BuildContext context){
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: textEditingController,
            ),
            ElevatedButton(
              child: const Text("Start Text To Speech"),
              onPressed: () => speak(),
            )
          ],
        )
        )
    );
  }
}

