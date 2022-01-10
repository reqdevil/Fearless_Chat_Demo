import 'dart:io';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Utils/TransitionHelpers.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  List<TakenCameraMedia>? listShareMedia;
  String? userId;
  ChatPage({Key? key, this.listShareMedia, this.userId}) : super(key: key);

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
late Map<String, dynamic> _friend;
List<Map<String, dynamic>> _messages = [];
late String formattedDate;
final ImagePicker _picker = ImagePicker();
final ScrollController _controller = ScrollController();
FocusNode? _focusNode;
TextEditingController? _textEditingController;
late double _textEditorWidth;

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    _textEditorWidth = 325.0;
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    _focusNode!.addListener(_onFocusChange);

    _friend = friendsList
        .where((element) => element['usrId'] == widget.userId!)
        .first;
    DateTime now = DateTime.now();
    formattedDate = DateFormat('dd.MM.yyyy – kk:mm').format(now);
    _messages =
        messages.where((element) => element['usrId'] == widget.userId).toList();
    // messages = [
    //   Message(1, 'userName', 'message', formattedDate, false,
    //       MessageType.received, true, 3, true),
    //   Message(1, 'userName', 'message', formattedDate, true,
    //       MessageType.received, false, 3, true)
    // ];
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollDown();
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode!.removeListener(_onFocusChange);
    _focusNode!.dispose();
    super.dispose();
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
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(_friend['imgUrl']),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 15),
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
                        color: Global().purple,
                      ),
                )
              ],
            ),
            const SizedBox(width: 20),
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
                                    color: Global().purple,
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
                                      Text(
                                        _messages[index]['message'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .apply(
                                              color: Colors.white,
                                            ),
                                      ),
                                      widget.listShareMedia != null &&
                                              _messages[index]['hasShareMedia']
                                          ? GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 0,
                                                  top: 0,
                                                  bottom: 0),
                                              itemCount:
                                                  widget.listShareMedia!.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    MediaQuery.of(context)
                                                                .orientation ==
                                                            Orientation
                                                                .landscape
                                                        ? 3
                                                        : 2,
                                                crossAxisSpacing: 4,
                                                mainAxisSpacing: 4,
                                                childAspectRatio: (1 / 1),
                                              ),
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  // width: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width /
                                                  //     2,
                                                  // height: MediaQuery.of(context)
                                                  //         .size
                                                  //         .width /
                                                  //     2,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 2),
                                                    image: DecorationImage(
                                                      image: FileImage(
                                                        File(widget
                                                            .listShareMedia!
                                                            .reversed
                                                            .toList()[index]
                                                            .filePath),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  child: widget.listShareMedia!
                                                              .reversed
                                                              .toList()[index]
                                                              .fileType ==
                                                          FileType.video
                                                      ? VideoItem(
                                                          url: widget
                                                              .listShareMedia!
                                                              .reversed
                                                              .toList()[index]
                                                              .filePath)
                                                      : Container(),
                                                );
                                              },
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          _messages[index]['time'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
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
            margin: const EdgeInsets.all(15.0),
            height: 45,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: Global().purple, shape: BoxShape.circle),
                    child: InkWell(
                      child: const Icon(
                        Icons.keyboard_voice,
                        color: Colors.white,
                      ),
                      onLongPress: () {},
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Expanded(
                    child: Container(
                      width: _textEditorWidth,
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
                              autofocus: false,
                              controller: _textEditingController,
                              focusNode: _focusNode,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onSubmitted: (value) {
                                setState(() {
                                  _messages.add(
                                    {
                                      'usrId': '2',
                                      'status': MessageType.sent,
                                      'message': value,
                                      'time': formattedDate,
                                      'hasShareMedia': true
                                    },
                                  );
                                  scrollDown();
                                });
                              },
                              decoration: const InputDecoration(
                                  hintText: "Type Something...",
                                  border: InputBorder.none),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_camera),
                            onPressed: () async {
                              await navigatePageBottom(
                                  context: context,
                                  page: const CameraPage(),
                                  rootNavigator: true);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () {
                              setState(() {
                                _showBottom = true;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // const SizedBox(width: 15),
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
                                  border: Border.all(
                                      color: Global().purple, width: 2),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    icons[i],
                                    color: Global().purple,
                                  ),
                                  onPressed: () {
                                    if (i == 0) {
                                      showOptions();
                                    } else if (i == 1) {
                                    } else if (i == 2) {}
                                  },
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

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  File? _image;
  final picker = ImagePicker();

//Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

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
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      curve: Curves.linear,
      duration: const Duration(milliseconds: 450),
    );
  }

  void _onFocusChange() {
    if (_focusNode!.hasFocus) {
      setState(() {
        _textEditorWidth = 450;
      });
    }
  }
}
