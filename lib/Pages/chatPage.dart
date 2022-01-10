import 'dart:io';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
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
late String formattedDate;
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
    _textEditingController!.addListener(_onTextChange);

    _friend = friendsList
        .where((element) => element['usrId'] == widget.userId!)
        .first;
    DateTime now = DateTime.now();
    formattedDate = DateFormat('dd.MM.yyyy – kk:mm').format(now);
    _messages =
        messages.where((element) => element['usrId'] == widget.userId).toList();

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
          color: Global().mainColor, //change your color here
        ),
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(_friend['imgUrl']),
              backgroundColor: Colors.transparent,
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
                        color: Global().mainColor,
                      ),
                )
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
                                    color: Global().mainColor,
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
                                      _messages[index]['hasShareMedia'] &&
                                              (_messages[index]['filePaths']
                                                      as List<String>)
                                                  .isNotEmpty
                                          ? getGridMedia(index, context)
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
            margin: const EdgeInsets.symmetric(horizontal: 15),
            height: 71,
            // width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                        color: Global().mainColor, shape: BoxShape.circle),
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
                  child: Container(
                    width: _textEditorWidth - 35,
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
                      children: [
                        IconButton(
                            icon: const Icon(Icons.face), onPressed: () {}),
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
                          visible: _textEditingController!.text.isEmpty,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_camera),
                                onPressed: () async {
                                  showGeneralDialog(
                                      context: context,
                                      useRootNavigator: true,
                                      transitionDuration:
                                          const Duration(milliseconds: 400),
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter sfsetState) {
                                            return const CameraPage();
                                          },
                                        );
                                      }).then((value) {
                                    setState(() {
                                      List<String> lst =
                                          (value as List<TakenCameraMedia>)
                                              .map((e) => e.filePath)
                                              .toList();
                                      _messages.add(
                                        {
                                          'usrId': '2',
                                          'status': MessageType.sent,
                                          'message':
                                              _textEditingController!.text,
                                          'time': formattedDate,
                                          'hasShareMedia': true,
                                          'filePaths': lst
                                        },
                                      );
                                      scrollDown();
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    builder: (context) {
                                      return Container(
                                        padding: const EdgeInsets.all(25.0),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
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
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  minimumSize:
                                                      const Size(35, 35),
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  primary: Colors.grey
                                                      .withOpacity(0.3),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      color: Colors.grey[200],
                                                      border: Border.all(
                                                          color: Global()
                                                              .mainColor,
                                                          width: 2),
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        icons[i],
                                                        color:
                                                            Global().mainColor,
                                                        size: 50,
                                                      ),
                                                      onPressed: () {
                                                        if (i == 0) {
                                                          Navigator.pop(
                                                              context);
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
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: _textEditingController!.text.isNotEmpty,
                          child: Transform.rotate(
                            angle: -math.pi / 4,
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded),
                              onPressed: () async {
                                setState(() {
                                  _messages.add(
                                    {
                                      'usrId': '2',
                                      'status': MessageType.sent,
                                      'message': _textEditingController!.text,
                                      'time': formattedDate,
                                      'hasShareMedia': false,
                                      'filePaths': []
                                    },
                                  );
                                  scrollDown();
                                });
                              },
                            ),
                          ),
                        )
                      ],
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

  Widget getGridMedia(int index, BuildContext context) {
    Widget widget = const SizedBox();

    widget = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
      itemCount: _messages[index]['filePaths'].length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 2,
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
                    File(_messages[index]['filePaths'][i].toString()),
                  ),
                  fit: BoxFit.cover,
                )),
            child: _messages[index]['filePaths'][i]
                        .toString()
                        .contains('.mov') ||
                    _messages[index]['filePaths'][i].toString().contains('.mp4')
                ? VideoItem(url: _messages[index]['filePaths'][i].toString())
                : const SizedBox());
      },
    );

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
                color: Global().mainColor,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(color: Global().mainColor),
              ),
              onTap: () {
                Navigator.of(context).pop();
                getImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: Global().mainColor,
              ),
              title: Text(
                'Camera',
                style: TextStyle(color: Global().mainColor),
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
        _messages.add(
          {
            'usrId': '2',
            'status': MessageType.sent,
            'message': "",
            'time': formattedDate,
            'hasShareMedia': true,
            'filePaths': lst
          },
        );
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
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 450),
      );
    });
  }

  void _onTextChange() {
    if (_textEditingController!.text.isNotEmpty) {
      setState(() {
        _textEditorWidth = 450;
      });
    } else if (_textEditingController!.text.isEmpty) {
      setState(() {
        _textEditorWidth = 325.0;
      });
    }
  }
}
