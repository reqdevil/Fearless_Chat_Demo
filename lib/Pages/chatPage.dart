import 'dart:io';
import 'dart:math';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Models/friend.dart';
import 'package:fearless_chat_demo/Models/message.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:fearless_chat_demo/Widgets/audioBubble.dart';
import 'package:fearless_chat_demo/Widgets/recordButton.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:file_picker/file_picker.dart' as filePicker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as M;

class ChatPage extends StatefulWidget {
  List<TakenCameraMedia>? listShareMedia;
  final String userId;
  ChatPage({Key? key, this.listShareMedia, required this.userId})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

late Map<IconData, String> icons;

late Friend _friend;
List<Message> _messages = [];

final ScrollController _controller = ScrollController();
FocusNode? _focusNode;
TextEditingController? _textEditingController;
late double _textEditorWidth;
bool isVisibleChatBox = true;
List<String> _locationString = [];

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  double leftPadding = 0.0;
  @override
  void initState() {
    icons = {
      Icons.image: 'Gallery',
      Icons.camera: 'Camera',
      Icons.file_present: 'Document',
      Icons.location_on: 'Location'
    };
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textEditorWidth = 308;
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    _textEditingController!.addListener(_onTextChange);

    _messages = Global.getMessages()
        .where((element) => element.usrId == widget.userId)
        .toList();

    _friend = Friend.fromMap(friendsList
        .where((element) => element['usrId'] == widget.userId)
        .first);
    // _friend =
    //     friendsList.where((element) => element['usrId'] == widget.userId).first;

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
                    backgroundImage: NetworkImage(_friend.imgUrl),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _friend.username,
                      style: Theme.of(context).textTheme.subtitle1,
                      overflow: TextOverflow.clip,
                    ),
                    Text(
                      _friend.isOnline ? "Online" : "Offline",
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
      body: SafeArea(
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
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
                      child: _messages[index].status == MessageType.received
                          ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage: NetworkImage(
                                      _messages[index].contactImgUrl!),
                                  backgroundColor: Colors.transparent,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _messages[index].contactName!,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                            _messages[index].message,
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
                                              _messages[index].time,
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
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                          _messages[index].message != ""
                                              ? Text(_messages[index].message,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .apply(
                                                        color: Colors.white,
                                                      ))
                                              : const SizedBox(),
                                          getVoiceMedia(index, context),
                                          getGridMedia(index, context),
                                          getMap(List<String>.from(
                                              _messages[index].location)),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (_messages[index]
                                                      .message
                                                      .contains('.pdf') ||
                                                  _messages[index]
                                                      .message
                                                      .contains('.doc') ||
                                                  _messages[index]
                                                      .message
                                                      .contains('.ppt') ||
                                                  _messages[index]
                                                      .message
                                                      .contains('.pptx') ||
                                                  _messages[index]
                                                      .message
                                                      .contains('.txt') ||
                                                  _messages[index]
                                                      .message
                                                      .contains('.xls') ||
                                                  _messages[index]
                                                      .message
                                                      .contains('.xlsx'))
                                                Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Icon(
                                                    Icons.file_present_outlined,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              else
                                                SizedBox(),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  _messages[index].time,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .apply(
                                                          color: Colors.white),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          )
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
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: 0, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: getWidthChatBox(context),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Global.borderRadius),
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
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10.0))),
                                    builder: (context) {
                                      return SafeArea(
                                        child: Expanded(
                                          child: SingleChildScrollView(
                                            child: Container(
                                              child: Wrap(
                                                children: [
                                                  for (var key in icons.keys)
                                                    ListTile(
                                                      title: Text(
                                                        icons[key].toString(),
                                                        style: TextStyle(
                                                            color: Global
                                                                .mainColor),
                                                      ),
                                                      leading: Icon(
                                                        key,
                                                        color: Global.mainColor,
                                                      ),
                                                      onTap: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        if (icons[key]
                                                                .toString() ==
                                                            'Gallery') {
                                                          getImageFromGallery();
                                                        } else if (icons[key]
                                                                .toString() ==
                                                            'Camera') {
                                                          showOptionsShareMedia(
                                                              context);
                                                        } else if (icons[key]
                                                                .toString() ==
                                                            'Document') {
                                                          getMultipleFile();
                                                        } else if (icons[key]
                                                                .toString() ==
                                                            'Location') {
                                                          List<String>
                                                              location =
                                                              await shareLocation();

                                                          setState(
                                                            () {
                                                              Global.messages
                                                                  .add(
                                                                {
                                                                  'usrId': widget
                                                                      .userId,
                                                                  'status':
                                                                      MessageType
                                                                          .sent,
                                                                  'message': "",
                                                                  'time': DateFormat(
                                                                          'dd.MM.yyyy – kk:mm')
                                                                      .format(DateTime
                                                                          .now()),
                                                                  'hasShareMedia':
                                                                      false,
                                                                  'filePaths':
                                                                      [],
                                                                  'location':
                                                                      location
                                                                },
                                                              );
                                                              _messages = Global
                                                                      .getMessages()
                                                                  .where((element) =>
                                                                      element
                                                                          .usrId ==
                                                                      widget
                                                                          .userId)
                                                                  .toList();
                                                              scrollDown();
                                                            },
                                                          );
                                                        }
                                                      },
                                                    )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                            Visibility(
                              visible: isVisibleChatBox,
                              child: Expanded(
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
                                    if (_textEditingController!.text.isNotEmpty)
                                      setState(() {
                                        Global.messages.add(
                                          {
                                            'usrId': widget.userId,
                                            'status': MessageType.sent,
                                            'message':
                                                _textEditingController!.text,
                                            'time':
                                                DateFormat('dd.MM.yyyy – kk:mm')
                                                    .format(DateTime.now()),
                                            'hasShareMedia': false,
                                            'filePaths': [],
                                            'location': []
                                          },
                                        );
                                        _messages = Global.getMessages()
                                            .where((element) =>
                                                element.usrId == widget.userId)
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
                    ),
                    // const SizedBox(width: 2),
                    Visibility(
                      visible: _textEditingController!.text.isEmpty,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: RecordButton(
                          hasRecord: (value) {
                            setState(() {
                              if (value) {
                                isVisibleChatBox = false;
                              } else {
                                isVisibleChatBox = true;
                              }
                            });
                          },
                          endOfRecord: (messages) {
                            setState(() {
                              _messages = Global.getMessages()
                                  .where((element) =>
                                      element.usrId == widget.userId)
                                  .toList();
                            });
                            scrollDown();
                          },
                          controller: controller,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 1),
                    // const SizedBox(width: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getWidthChatBox(BuildContext context) {
    double width = 0.0;

    if (isVisibleChatBox &&
        MediaQuery.of(context).orientation == Orientation.portrait &&
        _textEditingController!.text.isEmpty) {
      width = MediaQuery.of(context).size.width -
          MediaQuery.of(context).size.width / 5.5;
    } else if (isVisibleChatBox &&
        MediaQuery.of(context).orientation == Orientation.landscape &&
        _textEditingController!.text.isEmpty) {
      width = MediaQuery.of(context).size.width -
          MediaQuery.of(context).size.width / 9;
    } else if (isVisibleChatBox &&
        MediaQuery.of(context).orientation == Orientation.portrait &&
        _textEditingController!.text.isNotEmpty) {
      width = MediaQuery.of(context).size.width * 0.95;
    } else if (isVisibleChatBox &&
        MediaQuery.of(context).orientation == Orientation.landscape &&
        _textEditingController!.text.isNotEmpty) {
      width = MediaQuery.of(context).size.width -
          MediaQuery.of(context).size.width * .03;
    } else if (!isVisibleChatBox) {
      width = 0.0;
    }
    return width;
  }

  void showOptionsShareMedia(BuildContext context) {
    showGeneralDialog(
        context: context,
        useRootNavigator: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter sfsetState) {
              return const CameraPage();
            },
          );
        }).then((value) {
      setState(() {
        List<String> lst =
            (value as List<TakenCameraMedia>).map((e) => e.filePath).toList();
        Global.messages.add(
          {
            'usrId': widget.userId,
            'status': MessageType.sent,
            'message': _textEditingController!.text,
            'time': DateFormat('dd.MM.yyyy – kk:mm').format(DateTime.now()),
            'hasShareMedia': true,
            'filePaths': lst,
            'location': []
          },
        );
        _messages = Global.getMessages()
            .where((element) => element.usrId == widget.userId)
            .toList();

        scrollDown();
      });
    });
  }

  Widget getVoiceMedia(int index, BuildContext context) {
    Widget widget = const SizedBox();
    if (index > _messages.length) {
      return widget;
    }
    var t = List<String>.from(_messages[index].filePaths);
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

  Widget getMap(List<String> locationString) {
    Widget widget;

    if (locationString.isNotEmpty) {
      double latitude = double.parse(locationString[0]);
      double longitude = double.parse(locationString[1]);
      widget = Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: EdgeInsets.all(2),
        height: 150,
        child: new FlutterMap(
          options: new MapOptions(
            allowPanningOnScrollingParent: false,
            slideOnBoundaries: true,

            center: new LatLng(latitude, longitude),
            enableScrollWheel: false,
            zoom: 16,

            swPanBoundary: LatLng(latitude, longitude),
            nePanBoundary: LatLng(latitude, longitude), allowPanning: false,
            onTap: (tapPosition, point) async {
              final availableMaps = await M.MapLauncher.installedMaps;
              if (availableMaps.isNotEmpty) if (availableMaps.length > 1)
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10.0))),
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            child: Wrap(
                              children: <Widget>[
                                for (var map in availableMaps)
                                  ListTile(
                                    onTap: () async {
                                      await M.MapLauncher.showMarker(
                                        mapType: map.mapType,
                                        coords: M.Coords(latitude, longitude),
                                        title: "I am here.",
                                        description: "",
                                      );
                                    },
                                    title: Text(map.mapName),
                                    leading: SvgPicture.asset(
                                      map.icon,
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              else
                await M.MapLauncher.showMarker(
                  mapType: availableMaps.first.mapType,
                  coords: M.Coords(latitude, longitude),
                  title: "I am here.",
                  description: "",
                );
            },
            // maxZoom: 14.0,
            // minZoom: 13,
          ),
          layers: [
            TileLayerOptions(
              // tileProvider: AssetTileProvider(),
              // backgroundColor: Colors.transparent,
              overrideTilesWhenUrlChanges: false,
              urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?source=${DateTime.now().millisecondsSinceEpoch}",
              subdomains: ['a', 'b', 'c'],
              // attributionBuilder: (_) {
              //   return Text("© OpenStreetMap contributors");
              // },
            ),
            new MarkerLayerOptions(
              rotate: false,
              markers: [
                new Marker(
                  width: 80.0,
                  height: 80.0,
                  point: new LatLng(latitude, longitude),
                  builder: (ctx) => new Container(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.white70.withOpacity(0.5)),
                        ),
                        new Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      widget = SizedBox();
    }
    return widget;
  }

  Widget getGridMedia(int index, BuildContext context) {
    List<String> mediaPathList = [];
    Widget widget = const SizedBox();
    if (index > _messages.length) {
      return widget;
    }
    var t = List<String>.from(_messages[index].filePaths);
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
            'filePaths': lst,
            'location': []
          },
        );
        _messages = Global.getMessages()
            .where((element) => element.usrId == widget.userId)
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

  Future getVideosFromGallery() async {
    var pickedVideoList = await picker.pickVideo(source: ImageSource.gallery);
  }

  Future getMultipleFile() async {
    filePicker.FilePickerResult? result = await filePicker.FilePicker.platform
        .pickFiles(
            type: filePicker.FileType.custom,
            allowedExtensions: [
              'pdf',
              'doc',
              'txt',
              'ppt',
              'pptx',
              'xls',
              'xlsx'
            ],
            withData: true);
    List<filePicker.PlatformFile> fileList = result!.files;
    for (var file in fileList) {
      String fileSize = await getFileSize(file.path, 1);
      setState(() {
        Global.messages.add(
          {
            'usrId': widget.userId,
            'status': MessageType.sent,
            'message': file.name + '\n' + fileSize,
            'time': DateFormat('dd.MM.yyyy – kk:mm').format(DateTime.now()),
            'hasShareMedia': true,
            'filePaths': [file.path],
            'location': []
          },
        );
        _messages = Global.getMessages()
            .where((element) => element.usrId == widget.userId)
            .toList();
      });

      scrollDown();
    }
  }

  getFileSize(String? filepath, int decimals) async {
    if (filepath != null) {}
    File file = File(filepath!);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  final Location location = Location();
  bool _loading = false;
  LocationData? _location;
  String? _error;

  Future<List<String>> shareLocation() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
        _loading = false;
        _locationString.add(_locationResult.latitude.toString());
        _locationString.add(_locationResult.longitude.toString());
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
        _loading = false;
      });
    }
    return _locationString;
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
        _textEditorWidth = MediaQuery.of(context).size.width - 20;
        leftPadding = 0.0;
      });
    } else if (_textEditingController!.text.isEmpty) {
      setState(() {
        _textEditorWidth = 308;
        leftPadding = 0.0;
        // _textEditorWidth = MediaQuery.of(context).size.width -
        //     MediaQuery.of(context).size.width / 4;
      });
    }
  }
}
