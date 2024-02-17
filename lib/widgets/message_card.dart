import 'package:flutter/material.dart';
import 'package:welcome_app/api/apis.dart';
import 'package:welcome_app/main.dart';
import 'package:welcome_app/models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIS.user.uid == widget.message.fromid
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Text(widget.message.msg,
                style: TextStyle(fontSize: 15, color: Colors.black87)),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(widget.message.sent, style: TextStyle(fontSize: 13, color: Colors.black54),),
        ),
        
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),

            Icon(Icons.done_all_rounded, color: Colors.blue, size: 13),

            SizedBox(width: 2),

            Text(widget.message.read + '12:00 AM', style: TextStyle(fontSize: 13, color: Colors.black54),),
          ],
        ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: Text(widget.message.msg,
                style: TextStyle(fontSize: 15, color: Colors.black87)),
          ),
        ),
        
      ],
    );
  }
}
