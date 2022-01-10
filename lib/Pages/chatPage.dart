import 'dart:io';

import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final List<TakenCameraMedia> listShareMedia;
  const ChatPage({Key? key, required this.listShareMedia}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.listShareMedia.length,
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.width / 2,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
                color: widget.listShareMedia.reversed.toList()[index].isSelected
                    ? Colors.amber
                    : Colors.grey.withOpacity(0.5),
                width: 2),
            image: DecorationImage(
              image: FileImage(
                File(widget.listShareMedia.reversed.toList()[index].filePath),
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: widget.listShareMedia.reversed.toList()[index].fileType ==
                  FileType.video
              ? VideoItem(
                  url: widget.listShareMedia.reversed.toList()[index].filePath)
              : Container(),
        );
      },
    );
  }
}
