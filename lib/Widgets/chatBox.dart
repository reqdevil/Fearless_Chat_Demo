import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AnimationController controller;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Global.borderRadius),
          boxShadow: const [
            BoxShadow(offset: Offset(0, 3), blurRadius: 5, color: Colors.grey)
          ],
        ),
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(Global.borderRadius),
        //   color: Colors.white,
        // ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
