import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/api/apis.dart';
import 'package:welcome_app/helper/dialogs.dart';
import 'package:welcome_app/main.dart';
import 'package:welcome_app/screens/homescreen.dart';




class LoginScreen extends StatefulWidget {
  final Interpreter interpreter;
  

  const LoginScreen({super.key, required this.interpreter});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500) ,() {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user != null){
        print('\nUser: ${user.user}');
        print('\nUseradditionalInfo: ${user.additionalUserInfo}');

        if(await APIS.userExists()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(interpreter: widget.interpreter,)));
        }
        else{
          await APIS.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(interpreter: widget.interpreter,)));
          });
        }
        
      }  
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
  try{

    //To check if user is connected to internet or not 
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIS.auth.signInWithCredential(credential);
  }
  catch(e){
    print('\n_signInWithGoogle: ${e}');
  }

  Dialogs.showSnackBar(context, 'Something went wrong! (Check Internet)');

  return null;
} 
  
  @override
  Widget build(BuildContext context) {
    //mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Emospeak'),
      ),

      body: Stack(children: [AnimatedPositioned(
        top: mq.height * .15, 
        width:mq.width * .5,  
        right: _isAnimate? mq.width * .25 : - mq.width * .25,
        duration: Duration(milliseconds: 1000),
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
        child: ElevatedButton.icon(onPressed: (){
         _handleGoogleBtnClick();
        }, 
        icon: Image.asset('images/google.png', height: mq.height * .03), label: RichText(text: TextSpan(children: [
          TextSpan(text: 'Sign In with'),
          TextSpan(text: ' Google', style: TextStyle(fontWeight: FontWeight.w600))
        ],
        style: TextStyle(fontSize: 16))),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent.shade700,
          shape: StadiumBorder()
        ), )
        )
        ],)

    );
  }
}