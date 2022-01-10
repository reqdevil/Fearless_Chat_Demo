import 'dart:io';

import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Models/message.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final List<TakenCameraMedia> listShareMedia;
  const ChatPage({Key? key, required this.listShareMedia}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

bool _showBottom = false;
List<IconData> icons = const [
  Icons.image,
  Icons.camera,
  Icons.upload,
  Icons.folder,
  Icons.gif
];
List<Message> messages = [];

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    messages = [
      Message(
          'userName',
          'message',
          DateTime.now().hour.toString() +
              ":" +
              DateTime.now().minute.toString(),
          MessageType.camedMessage),
      Message(
          'userName',
          'message',
          DateTime.now().hour.toString() +
              ":" +
              DateTime.now().minute.toString(),
          MessageType.camedMessage)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.grey[700], //change your color here
        ),
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Armağan Çelik",
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.clip,
                ),
                Text(
                  "Online",
                  style: Theme.of(context).textTheme.subtitle1!.apply(
                        color: Colors.green,
                      ),
                )
              ],
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(35, 35),
                padding: const EdgeInsets.all(0),
                primary: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {},
              child: Icon(
                Icons.phone,
                color: Colors.grey[800],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(35, 35),
                padding: const EdgeInsets.all(0),
                primary: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {},
              child: Icon(
                Icons.videocam_sharp,
                color: Colors.grey[800],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: const Size(35, 35),
                padding: const EdgeInsets.all(0),
                primary: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {},
              child: Icon(
                Icons.more_vert_rounded,
                color: Colors.grey[800],
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(15),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  child: messages[index].messagetype == MessageType.camedMessage
                      ? Row(
                          children: [
                            const CircleAvatar(
                              radius: 20.0,
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150'),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  messages[index].userName,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              .6),
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                      bottomRight: Radius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    messages[index].message,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .apply(
                                          color: Colors.black87,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                            const SizedBox(width: 15),
                            Text(
                              messages[index].time,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .apply(color: Colors.grey),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              messages[index].time,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .apply(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              .6),
                                  padding: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green[300],
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    messages[index].message,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .apply(
                                          color: Colors.black87,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(15.0),
            height: 61,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35.0),
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            color: Colors.grey)
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                            icon: const Icon(Icons.face), onPressed: () {}),
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) {
                              setState(() {
                                messages.add(Message(
                                    'Armağan Çelik',
                                    value,
                                    DateTime.now().hour.toString() +
                                        ':' +
                                        DateTime.now().minute.toString(),
                                    MessageType.sendedMessage));
                              });
                            },
                            decoration: const InputDecoration(
                                hintText: "Type Something...",
                                border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_camera),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  child: InkWell(
                    child: const Icon(
                      Icons.keyboard_voice,
                      color: Colors.white,
                    ),
                    onLongPress: () {
                      setState(() {
                        _showBottom = true;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          _showBottom
              ? Positioned(
                  bottom: 90,
                  left: 25,
                  right: 25,
                  child: Container(
                    padding: const EdgeInsets.all(25.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(0, 5),
                            blurRadius: 15.0,
                            color: Colors.grey)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              minimumSize: const Size(35, 35),
                              padding: const EdgeInsets.all(0),
                              primary: Colors.grey.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showBottom = false;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.grey[800],
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        GridView.count(
                          mainAxisSpacing: 21.0,
                          crossAxisSpacing: 21.0,
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          children: List.generate(
                            icons.length,
                            (i) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey[200],
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    icons[i],
                                    color: Colors.green,
                                  ),
                                  onPressed: () {},
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  ListView getListMedia() {
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
