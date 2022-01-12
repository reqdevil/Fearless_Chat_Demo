import 'dart:io';
import 'package:fearless_chat_demo/Utils/audioState.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:fearless_chat_demo/Widgets/audioBubble.dart';
import 'package:flutter/material.dart';

class AudioList extends StatefulWidget {
  const AudioList({Key? key}) : super(key: key);

  @override
  State<AudioList> createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  List<FileSystemEntity> data = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      padding: const EdgeInsets.symmetric(vertical: 15),
      key: Global.audioListKey,
      itemBuilder: (context, index, animation) {
        return FadeTransition(
          opacity: animation,
          child: AudioBubble(
            filepath: AudioState.files[index],
            
            key: ValueKey(AudioState.files[index]),
          ),
        );
      },
    );
  }

  Future<List<FileSystemEntity>> fetchAudioFiles() async {
    String dirPath = Global.documentPath;
    List<FileSystemEntity> file = Directory(dirPath).listSync();
    file.removeWhere((element) => !element.path.endsWith("m4a"));
    file = file.reversed.toList();
    return file;
  }
}
