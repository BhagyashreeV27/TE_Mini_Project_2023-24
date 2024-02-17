// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:ui';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/screens/splash_screen.dart';
import 'firebase_options.dart';

//global  object for media querries
late Size mq;

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((value) async {
    _initialize_firebase();
  

  // Call the downloadModel function

    // print("before");
    
    // print("after");
    runApp(const MyApp());
  });
  
}


class MyApp extends StatelessWidget {
 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeFirebaseAndDownloadModel(),
      builder: (context,snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while loading the model
        } else if (snapshot.hasError) {
          return Text('Error loading model: ${snapshot.error}');
        } else {
          return MaterialApp(
        // MaterialColor myColor = Color.fromARGB(255, 46, 45, 45),????   https://stackoverflow.com/questions/67930143/the-argument-type-color-cant-be-assigned-to-the-parameter-type-materialcolo
        debugShowCheckedModeBanner : false,
         theme: ThemeData(primarySwatch: Colors.teal,
         
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal.withOpacity(0.8),
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20)
          ),
        ),
        
        home:  SplashScreen(interpreter: snapshot.data!),
        
      );
        }
      }
    );    
  }
  
  
}

Future<Interpreter> downloadAndLoadModel() async {
  try {
    // Download the model
    final customModel =
        await FirebaseModelDownloader.instance.getModel(
      "lstm_ed",
      FirebaseModelDownloadType.localModel,
      FirebaseModelDownloadConditions(
        iosAllowsCellularAccess: true,
        iosAllowsBackgroundDownloading: false,
        androidChargingRequired: false,
        androidWifiRequired: false,
        androidDeviceIdleRequired: false,
      ),
    );
    final localModelPath = customModel.file;

    // Load the model directly and return the interpreter instance
    final interpreter = Interpreter.fromFile(localModelPath);
     interpreter.allocateTensors(); // Allocate memory for input and output tensors
    return interpreter;
  } catch (e) {
    print('Error downloading and loading model: $e');
    throw e; // Rethrow the error to handle it elsewhere if needed
  }
}




_initialize_firebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

}

Future<Interpreter> initializeFirebaseAndDownloadModel() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Download and load the model
      final interpreter = await downloadAndLoadModel();
      log('checked initialization of firebase ');

      return interpreter;

    } catch (e) {
      throw Exception('Error initializing Firebase and downloading model: $e');
    }
}
