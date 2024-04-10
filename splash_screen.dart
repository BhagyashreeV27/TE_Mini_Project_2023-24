import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/api/apis.dart';
import 'package:welcome_app/main.dart';
import 'package:welcome_app/screens/auth/login_screen.dart';
import 'dart:developer';

import 'package:welcome_app/screens/homescreen.dart';

class SplashScreen extends StatefulWidget {
  final Interpreter interpreter;
  const SplashScreen({super.key, required this.interpreter});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000) ,() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      log('Changed UI');
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));
      log('Status bar changed');
      if(APIS.auth.currentUser != null){
        log('\n User: ${APIS.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(interpreter: widget.interpreter,)));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(interpreter: widget.interpreter,)));
      }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Emospeak'),
      ),

      body: Stack(children: [Positioned(
        top: mq.height * .15, 
        width:mq.width * .5,  
        right:  mq.width * .25 ,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox.fromSize(
                size: Size.fromRadius(100), // Image radius
                child: Image.asset('images/emoSpeakLogo (1).png', fit: BoxFit.cover),
            ),
        )),
        Positioned(
        bottom: mq.height * .15, 
        width:mq.width * .9,  
        left: mq.width * .05,
        height: mq.height * .07,
        child: Text('Connect without Barriers', style: TextStyle(fontSize: 16, letterSpacing: .5), textAlign: TextAlign.center
      )
        )
        ],)

    );
  }
}