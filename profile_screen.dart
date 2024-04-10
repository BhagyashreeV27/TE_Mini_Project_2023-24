// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
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

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  final Interpreter interpreter;

  const ProfileScreen({super.key, required this.user, required this.interpreter});


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  List<ChatUser> list = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Profile Screen'),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: list[0], interpreter: widget.interpreter,
                                )));
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await APIS.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for logout
                    Navigator.pop(context);
                    //for not showing  homescreen
                    Navigator.pop(context);
                    //for ne login
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen(interpreter: widget.interpreter,)));
                  });
                });
              },
              icon: Icon(Icons.add_comment_rounded),
              label: Text('Logout'),
              backgroundColor: Colors.redAccent,
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(width: mq.width, height: mq.height * .03),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.fill,
                            imageUrl: widget.user.image,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                              elevation: 1,
                              onPressed: () {
                                _showBottomSheet(context);
                              },
                              shape: CircleBorder(),
                              color: Colors.white,
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                              )),
                        )
                      ],
                    ),
                    SizedBox(height: mq.height * .03),
                    Text(
                      widget.user.email,
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    SizedBox(height: mq.height * .05),
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIS.me.name = val ?? ' ',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          hintText: 'eg. Tripal Singh',
                          label: Text('Name')),
                    ),
                    SizedBox(height: mq.height * .05),
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIS.me.about = val ?? ' ',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          hintText: 'eg. Available',
                          label: Text('about')),
                    ),
                    SizedBox(height: mq.height * .05),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            minimumSize: Size(mq.width * .5, mq.height * .06)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIS.updateUserInfo().then((value) {
                              Dialogs.showSnackBar(
                                  context, 'Profile Updated Successfully');
                            });
                            log('inside validator');
                          }
                        },
                        icon: const Icon(Icons.edit, size: 28),
                        label: const Text('SAVE'))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          children: [
            Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),

            SizedBox(height: mq.height * .02),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(mq.width * 0.3, mq.height * .15)
                  ),

                  onPressed: () {},
                  child: Image.asset('images/add_image.png')),
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: Size(mq.width * 0.3, mq.height * .15)
                  ),

                  onPressed: () {},
                  child: Image.asset('images/camera.png'))
              ],
            )
          ],
        );
      });
}
