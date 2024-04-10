// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:welcome_app/api/apis.dart';
import 'package:welcome_app/helper/dialogs.dart';
import 'package:welcome_app/main.dart';
import 'package:welcome_app/models/chat_user.dart';
import 'package:welcome_app/screens/auth/login_screen.dart';
import 'package:welcome_app/screens/profile_screen.dart';
import 'package:welcome_app/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  final Interpreter interpreter;
  const HomeScreen({super.key, required this.interpreter});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // _MyHomeScreenState() {
  //   /// Init Alan AI button with project key from Alan AI Studio
  //   AlanVoice.addButton(
  //     "9076428026bfc681c157a65e533fbf202e956eca572e1d8b807a3e2338fdd0dc/stage",

  //     buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);

  //   /// Handle commands from Alan AI Studio
  //   AlanVoice.onCommand.add((command) {
  //     debugPrint("got new command ${command.toString()}");
  //   });
  // }

  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIS.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      //fix WillPopScope later
      // ignore: deprecated_member_use 
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }

        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearching ? TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Name,Email, ...'
              ),
              autofocus: true,
              style: TextStyle(fontSize:17, letterSpacing: 0.5),
              onChanged: (val){
                _searchList.clear();
        
                for(var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState((){
                    // ignore: unnecessary_statements
                    _searchList;
                  });
                }
              },
            ) : Text('Emospeak'),
            actions: [
              IconButton(onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIS.me, interpreter: widget.interpreter,
                                )));
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          // log("I came here");
        
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await APIS.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for logout
                    //Navigator.pop(context);
                    //for not showing  homescreen
                    Navigator.pop(context);
                    //for ne login
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => LoginScreen(interpreter: widget.interpreter ,)));
                  });
                });
              },
              child: Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder<Object>(
              stream: APIS.getAllUsers(),
              builder: (context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
        
                  //if data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
        
                    _list = data
                            ?.map<ChatUser>((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
        
                    if (_list.isNotEmpty) {
                      return ListView.builder(
                          itemCount: _isSearching ? _searchList.length : _list.length,
                          padding: EdgeInsets.only(top: mq.height * .01),
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index], interpreter: widget.interpreter);
                            // return Text('Name: ${list[index]}');
                          });
                    } else {
                      return const Center(
                          child: Text('No Connections Found',
                              style: TextStyle(fontSize: 20)));
                    }
                }
              }),
        ),
      ),
    );
  }
}
