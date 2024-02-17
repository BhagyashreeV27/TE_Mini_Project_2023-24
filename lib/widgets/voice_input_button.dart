import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class VoiceInputButton extends StatefulWidget {
  final Function(String) onTextRecognized;

  const VoiceInputButton({Key? key, required this.onTextRecognized})
      : super(key: key);

  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  // ignore: unused_field
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              widget.onTextRecognized(result.recognizedWords);
            } else {
              setState(() {
                _recognizedText = result.recognizedWords;
              });
            }
          },
        );
        setState(() {
          _isListening = true;
        });
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _recognizedText = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isListening ? Icon(Icons.mic) : Icon(Icons.mic_none),
      onPressed: () {
        if (_isListening) {
          _stopListening();
        } else {
          _startListening();
        }
      },
    );
  }
}
