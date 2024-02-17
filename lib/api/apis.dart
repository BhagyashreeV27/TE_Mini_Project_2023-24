import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:welcome_app/models/chat_user.dart';
import 'dart:developer';

import 'package:welcome_app/models/message.dart';

class APIS {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;

  //for storing self info
  static  late ChatUser me;



  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for getting self info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if(user.exists){
        me = ChatUser.fromJson(user.data()!);
        log('MY DATA : ${user.data()}');
      }else{
        await createUser().then((value) => getSelfInfo());
      }
      
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        image: user.photoURL.toString(),
        about: "Hey, Im using EmoSpeak",
        createdAt: time,
        lastActive: time,
        isOnline: false,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for getting all users from database

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
     await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about});
  }

  //*****Chat screen related apis ****

  //chats(collection) --> conversation_id (doc) --> messages(collection) -- message(doc)

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode ? '${user.uid}_$id' : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .snapshots();
  }


  //for sending messages 
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {

    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(toid: chatUser.id, msg: msg, fromid: user.uid, read: '', type: Type.text, sent: time);

    final ref =  firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages');

    await ref.doc(time).set(message.toJson());

  }

  





}

