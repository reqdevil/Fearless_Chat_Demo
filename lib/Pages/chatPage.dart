import 'dart:io';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:fearless_chat_demo/Widgets/audioBubble.dart';
import 'package:fearless_chat_demo/Widgets/recordButton.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

class ChatPage extends StatefulWidget {
  List<TakenCameraMedia>? listShareMedia;
  String? userId;
  ChatPage({Key? key, this.listShareMedia, this.userId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

List<IconData> icons = const [
  Icons.image,
  Icons.camera,
  Icons.upload,
  Icons.folder,
  Icons.gif
];

late Map<String, dynamic> _friend;
List<Map<String, dynamic>> _messages = [];

final ScrollController _controller = ScrollController();
FocusNode? _focusNode;
TextEditingController? _textEditingController;
late double _textEditorWidth;

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textEditorWidth = 308;
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    _textEditingController!.addListener(_onTextChange);

    _friend = friendsList
        .where((element) => element['usrId'] == widget.userId!)
        .first;

    _messages = Global.getMessages()
        .where((element) => element['usrId'] == widget.userId)
        .toList();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollDown();
    });
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController!.removeListener(_onTextChange);
    _textEditingController!.dispose();
    _focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Global.mainColor, //change your color here
        ),
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 5),
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: NetworkImage(_friend['imgUrl']),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _friend['username'],
                      style: Theme.of(context).textTheme.subtitle1,
                      overflow: TextOverflow.clip,
                    ),
                    Text(
                      _friend['isOnline'] ? "Online" : "Offline",
                      style: Theme.of(context).textTheme.subtitle1!.apply(
                            color: Global.mainColor,
                          ),
                    )
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
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
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Container(
                  child: _messages[index]['status'] == MessageType.received
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 20.0,
                              backgroundImage: NetworkImage(
                                  _messages[index]['contactImgUrl']),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _messages[index]['contactName'],
                                  //  messages[index].userName,
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _messages[index]['message'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .apply(
                                              color: Colors.black87,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          _messages[index]['time'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .apply(color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                                    color: Global.mainColor,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _messages[index]['message'] != ""
                                          ? Text(_messages[index]['message'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .apply(
                                                    color: Colors.white,
                                                  ))
                                          : const SizedBox(),
                                      getVoiceMedia(index, context),
                                      getGridMedia(index, context),
                                      // : const SizedBox(),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          _messages[index]['time'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .apply(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
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
            padding: EdgeInsets.all(Global.defaultPadding),
            // margin: const EdgeInsets.only(left: 10, right: 5),
            height: 71,
            // width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: _textEditorWidth + 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Global.borderRadius),
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 3),
                          blurRadius: 5,
                          color: Colors.grey)
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Global.mainColor,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Global.borderRadius),
                              ),
                              builder: (context) {
                                return Container(
                                  padding:
                                      const EdgeInsets.all(Global.borderRadius),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight:
                                          Radius.circular(Global.borderRadius),
                                      topLeft:
                                          Radius.circular(Global.borderRadius),
                                    ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            minimumSize: const Size(35, 35),
                                            padding: const EdgeInsets.all(0),
                                            primary:
                                                Colors.grey.withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(
                                            Icons.close,
                                            color: Global.mainColor,
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
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                color: Colors.grey[200],
                                                border: Border.all(
                                                    color: Global.mainColor,
                                                    width: 2),
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  icons[i],
                                                  color: Global.mainColor,
                                                  size: 50,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  if (i == 0) {
                                                    getImageFromGallery();
                                                  } else if (i == 1) {
                                                    showGeneralDialog(
                                                        context: context,
                                                        useRootNavigator: true,
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    400),
                                                        pageBuilder: (context,
                                                            animation,
                                                            secondaryAnimation) {
                                                          return StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    sfsetState) {
                                                              return const CameraPage();
                                                            },
                                                          );
                                                        }).then((value) {
                                                      setState(() {
                                                        List<String> lst =
                                                            (value as List<
                                                                    TakenCameraMedia>)
                                                                .map((e) =>
                                                                    e.filePath)
                                                                .toList();
                                                        Global.messages.add(
                                                          {
                                                            'usrId':
                                                                widget.userId,
                                                            'status':
                                                                MessageType
                                                                    .sent,
                                                            'message':
                                                                _textEditingController!
                                                                    .text,
                                                            'time': DateFormat(
                                                                    'dd.MM.yyyy – kk:mm')
                                                                .format(DateTime
                                                                    .now()),
                                                            'hasShareMedia':
                                                                true,
                                                            'filePaths': lst
                                                          },
                                                        );
                                                        _messages = Global
                                                                .getMessages()
                                                            .where((element) =>
                                                                element[
                                                                    'usrId'] ==
                                                                widget.userId)
                                                            .toList();

                                                        scrollDown();
                                                      });
                                                    });
                                                  } else if (i == 2) {}
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                      Expanded(
                        child: TextField(
                          autofocus: false,
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          onSubmitted: (value) {},
                          decoration: const InputDecoration(
                              hintText: "Type Something...",
                              border: InputBorder.none),
                        ),
                      ),
                      Visibility(
                        visible: _textEditingController!.text.isNotEmpty,
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: IconButton(
                            icon: Icon(
                              Icons.send_rounded,
                              color: Global.mainColor,
                            ),
                            onPressed: () async {
                              setState(() {
                                Global.messages.add(
                                  {
                                    'usrId': widget.userId,
                                    'status': MessageType.sent,
                                    'message': _textEditingController!.text,
                                    'time': DateFormat('dd.MM.yyyy – kk:mm')
                                        .format(DateTime.now()),
                                    'hasShareMedia': false,
                                    'filePaths': []
                                  },
                                );
                                _messages = Global.getMessages()
                                    .where((element) =>
                                        element['usrId'] == widget.userId)
                                    .toList();
                                scrollDown();
                                _textEditingController!.clear();
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Visibility(
                  visible: _textEditingController!.text.isEmpty,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: RecordButton(
                      controller: controller,
                    ),
                  ),
                ),
                // const SizedBox(width: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getVoiceMedia(int index, BuildContext context) {
    Widget widget = const SizedBox();
    var messages = Global.getMessages();
    if (index > messages.length) {
      return widget;
    }
    var t = List<String>.from(messages[index]['filePaths']);
    if (t.isNotEmpty) {
      (t.forEach((item) {
        if (item.contains('.m4a')) {
          widget = Align(
            alignment: Alignment.topLeft,
            child: AudioBubble(
              filepath: item,
              // key:
              //     ValueKey(AudioState.files.last),
            ),
          );
        }
      }));
    }
    return widget;
  }

  String? voice(int index) {
    String? voicePath = null;

    var messages = Global.getMessages();
    if (index > messages.length - 1) {
      return null;
    }
    // bool existed = false;
    var t = List<String>.from(messages[index]['filePaths']);
    if (t.isNotEmpty) {
      (t.forEach((item) {
        if (item.contains('.m4a')) {
          // existed = true;
          voicePath = item;
        }
      }));
    }

    // bool result = messages[index]['hasShareMedia'] && existed == true;
    return voicePath;
  }

  Widget getGridMedia(int index, BuildContext context) {
    List<String> mediaPathList = [];
    Widget widget = const SizedBox();
    var messages = Global.getMessages();
    if (index > messages.length) {
      return widget;
    }
    var t = List<String>.from(messages[index]['filePaths']);
    if (t.isNotEmpty) {
      (t.forEach((item) {
        if (item.contains('.mp4') ||
            item.contains('.mov') ||
            item.contains('.jpg')) {
          mediaPathList.add(item);
        }
      }));
    }
    if (mediaPathList.isNotEmpty) {
      widget = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
        itemCount: mediaPathList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 3
                  : 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          childAspectRatio: (1 / 1),
        ),
        itemBuilder: (context, i) {
          return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.white, width: 1),
                  image: DecorationImage(
                    image: FileImage(
                      File(mediaPathList[i]),
                    ),
                    fit: BoxFit.cover,
                  )),
              child: mediaPathList[i].contains('.mov') ||
                      mediaPathList[i].contains('.mp4')
                  ? VideoItem(url: mediaPathList[i])
                  : const SizedBox());
        },
      );
    }
    return widget;
  }

  Future showOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.image,
                color: Global.mainColor,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(color: Global.mainColor),
              ),
              onTap: () {
                Navigator.of(context).pop();
                getImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: Global.mainColor,
              ),
              title: Text(
                'Camera',
                style: TextStyle(color: Global.mainColor),
              ),
              onTap: () {
                Navigator.of(context).pop();
                getImageFromCamera();
              },
            ),
          ],
        );
      },
    );
  }

  List<File> _imagesFromGallery = [];
  final picker = ImagePicker();

//Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    var pickedImageList = await picker.pickMultiImage(imageQuality: 100);

    if (pickedImageList != null) {
      List<String> lst = pickedImageList.map((e) => e.path).toList();
      setState(() {
        Global.messages.add(
          {
            'usrId': widget.userId,
            'status': MessageType.sent,
            'message': "",
            'time': DateFormat('dd.MM.yyyy – kk:mm').format(DateTime.now()),
            'hasShareMedia': true,
            'filePaths': lst
          },
        );
        _messages = Global.getMessages()
            .where((element) => element['usrId'] == widget.userId)
            .toList();
      });

      scrollDown();
    }
  }

  File? _image;
//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    var pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  ListView getListMedia() {
    return ListView.builder(
      itemCount: widget.listShareMedia!.length,
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
                color:
                    widget.listShareMedia!.reversed.toList()[index].isSelected
                        ? Colors.amber
                        : Colors.grey.withOpacity(0.5),
                width: 2),
            image: DecorationImage(
              image: FileImage(
                File(widget.listShareMedia!.reversed.toList()[index].filePath),
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: widget.listShareMedia!.reversed.toList()[index].fileType ==
                  FileType.video
              ? VideoItem(
                  url: widget.listShareMedia!.reversed.toList()[index].filePath)
              : Container(),
        );
      },
    );
  }

  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 250), () {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  void _onTextChange() {
    if (_textEditingController!.text.isNotEmpty) {
      setState(() {
        _textEditorWidth = MediaQuery.of(context).size.width - 40;
      });
    } else if (_textEditingController!.text.isEmpty) {
      setState(() {
        _textEditorWidth = MediaQuery.of(context).size.width -
            MediaQuery.of(context).size.width / 4;
      });
    }
  }
}
