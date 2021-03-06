import 'dart:io';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Models/friend.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Pages/chatPage.dart';
import 'package:fearless_chat_demo/Pages/settingsPage.dart';
import 'package:fearless_chat_demo/Services/ServiceProvider.dart';
import 'package:fearless_chat_demo/Utils/TransitionHelpers.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:fearless_chat_demo/Widgets/badge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<TakenCameraMedia> listOfShareMediaList = [];
  List<Friend> _friendList = [];
  List<Friend> _friendFavoriteList = [];

  int selectedPageIndex = 0;
  late bool _isVisibileFavoriteFriendList;
  late List _children = [];
  bool _isVisibleSearch = false;
  bool _isVisibleSearchClean = false;
  final TextEditingController _searchTextEditorController =
      TextEditingController();
  ScrollController _friendListController = ScrollController();
  List<Friend> _searchResult = [];
  List<Friend> result = [];
  bool _isOpenedCamera = false;
  // late dynamic _provider;
  @override
  void initState() {
    requestPermissions();
    Future.delayed(Duration.zero, () async {
      await Future.wait(
          [getAlbumss().then((value) => Global.allAlbums = value)]);
    });
    _children = [
      null,
      const PlaceholderWidget(color: Colors.green),
      const PlaceholderWidget(color: Colors.deepOrange),
      // const LoginPage()
      const SettingsPage()
    ];
    for (var item in friendsList) {
      Friend f = Friend.fromMap(item);
      if (f.isFavorite) {
        _friendFavoriteList.add(f);
      }
      _friendList.add(f);
    }
    setState(() {
      if (_friendFavoriteList.isNotEmpty)
        _isVisibileFavoriteFriendList = true;
      else
        _isVisibileFavoriteFriendList = false;
    });

    _searchTextEditorController.addListener(() {
      if (_searchTextEditorController.text.isNotEmpty) {
        setState(() {
          _isVisibleSearchClean = true;
        });
      } else {
        setState(() {
          _isVisibleSearchClean = false;
        });
      }
    });
    // WidgetsBinding.instance!.addPostFrameCallback((_) async {});

    super.initState();
  }

  Future<bool> _promptPermissionSetting() async {
    // if (!t) {
    //   showDialog(
    //       context: context,
    //       builder: (BuildContext context) => CupertinoAlertDialog(
    //             title: Text('Camera Permission'),
    //             content: Text('This app needs media gallery'),
    //             actions: <Widget>[
    //               CupertinoDialogAction(
    //                 child: Text('Deny'),
    //                 onPressed: () => Navigator.of(context).pop(),
    //               ),
    //               CupertinoDialogAction(
    //                 child: Text('Settings'),
    //                 onPressed: () => openAppSettings(),
    //               ),
    //             ],
    //           ));
    // }
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<List<Album>> getAlbumss() async {
    List<TakenCameraMedia> mediaPathList = [];
    List<Album> allAlbums = [];
    if (await _promptPermissionSetting()) {
      List<Album> imageAlbums = await PhotoGallery.listAlbums(
          mediumType: MediumType.image, hideIfEmpty: true);
      List<Album> videoAlbums = await PhotoGallery.listAlbums(
          mediumType: MediumType.video, hideIfEmpty: true);

      allAlbums = [...imageAlbums, ...videoAlbums];
    }
    return allAlbums;
  }

  @override
  Widget build(BuildContext context) {
    ServiceProvider _provider =
        Provider.of<ServiceProvider>(context, listen: false);
    _provider.getUnseenMessageCount(_friendList);
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          // backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: selectedPageIndex == 0
              ? AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.grey[700], //change your color here
                  ),
                  // backgroundColor: Colors.white,
                  textTheme: Theme.of(context)
                      .textTheme
                      .apply(bodyColor: Colors.black45),
                  title: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(35.0),
                        border: Border.all(color: Colors.grey)),
                    height: 40,
                    child: Center(
                      child: TextField(
                          controller: _searchTextEditorController,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                            hintText: 'Search...',
                            suffixIcon: Visibility(
                              visible: _isVisibleSearchClean,
                              child: GestureDetector(
                                onTap: () {
                                  _searchTextEditorController.text = "";
                                  setState(() {
                                    _searchResult.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value == "") {
                              setState(() {
                                _searchResult.clear();
                              });
                            } else {
                              result = _friendList
                                  .where((user) => (user.username)
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            }
                            setState(() {
                              _searchResult = result;
                            });
                          }),
                    ),
                  ),
                  actions: <Widget>[
                    // IconButton(
                    //   icon: const Icon(Icons.search),
                    //   onPressed: () {
                    //     setState(() {
                    //       _isVisibleSearch = !_isVisibleSearch;
                    //     });
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Icons.add_box),
                      onPressed: () {},
                    ),
                  ],
                )
              : null,
          body: SafeArea(
              child: selectedPageIndex == 0 && _searchResult.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Visibility(
                          visible: _isVisibileFavoriteFriendList,
                          child: Container(
                            height: 90,
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(
                                  left: 5, right: 5, top: 10, bottom: 0),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _friendFavoriteList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  _friendFavoriteList[index]
                                                      .imgUrl),
                                            ),
                                          ),
                                          _friendFavoriteList[index].isOnline
                                              ? Positioned.fill(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Container(
                                                      height: 15,
                                                      width: 15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 3,
                                                        ),
                                                        shape: BoxShape.circle,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                        ]),
                                        Text(
                                          _friendFavoriteList[index].username,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    await navigatePageBottom(
                                        context: context,
                                        page: ChatPage(
                                          userId:
                                              _friendFavoriteList[index].usrId,
                                          listShareMedia: listOfShareMediaList,
                                        ),
                                        rootNavigator: true);
                                  },
                                  onLongPress: () {
                                    openFriendOptions(
                                        context, _friendFavoriteList[index]);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 15),
                            controller: _friendListController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _friendList.length,
                            itemBuilder: (ctx, i) {
                              return Column(
                                children: <Widget>[
                                  ListTile(
                                    isThreeLine: true,
                                    onLongPress: () {
                                      openFriendOptions(
                                          context, _friendList[i]);
                                    },
                                    // onTap: () => Navigator.of(context).pushNamed('chat'),
                                    onTap: () async {
                                      setState(() {
                                        _isVisibleSearch = false;
                                      });
                                      Global.selectedUserId =
                                          _friendList[i].usrId;
                                      await navigatePageTop(
                                          context: context,
                                          page: ChatPage(
                                            userId: _friendList[i].usrId,
                                            listShareMedia:
                                                listOfShareMediaList,
                                          ),
                                          rootNavigator: true);
                                    },
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(.3),
                                              offset: const Offset(0, 5),
                                              blurRadius: 25)
                                        ],
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned.fill(
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  _friendList[i].imgUrl),
                                            ),
                                          ),
                                          _friendList[i].isOnline
                                              ? Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    height: 15,
                                                    width: 15,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 3,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    title: Text(
                                      "${_friendList[i].username}",
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    subtitle: Text(
                                      "${_friendList[i].lastMsg}",
                                      style: !friendsList[i]['seen']
                                          ? Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                          : Theme.of(context)
                                              .textTheme
                                              .subtitle1!,
                                    ),
                                    trailing: SizedBox(
                                      width: 60,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _friendList[i].seen
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 15,
                                                    )
                                                  : const SizedBox(
                                                      height: 15, width: 15),
                                              Text(
                                                  "${_friendList[i].lastMsgTime}")
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          _friendList[i].hasUnSeenMsgs
                                              ? Container(
                                                  alignment: Alignment.center,
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    color: Global.mainColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    "${_friendList[i].unseenCount}",
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 25,
                                                  width: 25,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : _searchResult.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Visibility(
                              visible: _isVisibileFavoriteFriendList,
                              child: Container(
                                height: 90,
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 5, top: 10, bottom: 0),
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _friendFavoriteList.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Stack(children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      _friendFavoriteList[index]
                                                          .imgUrl),
                                                ),
                                              ),
                                              _friendFavoriteList[index]
                                                      .isOnline
                                                  ? Positioned.fill(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Container(
                                                          height: 15,
                                                          width: 15,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 3,
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ]),
                                            Text(
                                              _friendFavoriteList[index]
                                                  .username,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        await navigatePageBottom(
                                            context: context,
                                            page: ChatPage(
                                                userId:
                                                    _friendFavoriteList[index]
                                                        .usrId,
                                                listShareMedia:
                                                    listOfShareMediaList),
                                            rootNavigator: true);
                                      },
                                      onLongPress: () {
                                        openFriendOptions(
                                            context, _friendList[index]);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 15),
                                // controller: _friendListController,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _searchResult.length,
                                itemBuilder: (ctx, i) {
                                  return Column(
                                    children: <Widget>[
                                      ListTile(
                                        isThreeLine: true,
                                        onLongPress: () {
                                          openFriendOptions(
                                              context, _friendList[i]);
                                        },
                                        // onTap: () => Navigator.of(context).pushNamed('chat'),
                                        onTap: () async {
                                          await navigatePageBottom(
                                              context: context,
                                              page: ChatPage(
                                                  userId:
                                                      _searchResult[i].usrId,
                                                  listShareMedia:
                                                      listOfShareMediaList),
                                              rootNavigator: true);
                                        },
                                        leading: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(.3),
                                                  offset: const Offset(0, 5),
                                                  blurRadius: 25)
                                            ],
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Positioned.fill(
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      _searchResult[i].imgUrl),
                                                ),
                                              ),
                                              _searchResult[i].isOnline
                                                  ? Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Container(
                                                        height: 15,
                                                        width: 15,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.white,
                                                            width: 3,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        title: Text(
                                          "${_searchResult[i].username}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                        subtitle: Text(
                                            "${_searchResult[i].lastMsg}",
                                            style: !friendsList[i]['seen']
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                : Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!),
                                        trailing: SizedBox(
                                          width: 60,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _searchResult[i].seen
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 15,
                                                        )
                                                      : const SizedBox(
                                                          height: 15,
                                                          width: 15),
                                                  Text(
                                                      "${_searchResult[i].lastMsgTime}")
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5.0,
                                              ),
                                              _searchResult[i].hasUnSeenMsgs
                                                  ? Container(
                                                      alignment:
                                                          Alignment.center,
                                                      height: 25,
                                                      width: 25,
                                                      decoration: BoxDecoration(
                                                        color: Global.mainColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text(
                                                        "${_searchResult[i].unseenCount}",
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : const SizedBox(
                                                      height: 25,
                                                      width: 25,
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        height: 1,
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : _children[selectedPageIndex]),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: keyboardIsOpened
              ? null
              : FloatingActionButton(
                  elevation: 5,
                  foregroundColor: Colors.white,
                  backgroundColor: Global.mainColor,
                  child: const Icon(Icons.camera),
                  onPressed: () async {
                    setState(() {
                      _isOpenedCamera = true;
                    });
                    showGeneralDialog(
                        context: context,
                        useRootNavigator: true,
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter sfsetState) {
                              return const CameraPage();
                            },
                          );
                        }).then((value) {
                      setState(() {
                        _isOpenedCamera = false;
                      });
                      if (value != null)
                        setState(() {
                          listOfShareMediaList =
                              (value as List<TakenCameraMedia>);
                        });
                    });
                  },
                ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: -10.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(children: [
                  IconButton(
                    icon: Icon(Icons.message,
                        color: selectedPageIndex == 0
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onPrimary),
                    onPressed: () async {
                      setState(() {
                        selectedPageIndex = 0;
                      });

                      // await navigatePageBottom(
                      //     context: context, page: ChatPage(), rootNavigator: true);
                    },
                  ),
                  Badge()
                ]),
                IconButton(
                  icon: Icon(Icons.view_list,
                      color: selectedPageIndex == 1
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    setState(() {
                      selectedPageIndex = 1;
                    });
                  },
                ),
                const SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call,
                      color: selectedPageIndex == 2
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    setState(() {
                      selectedPageIndex = 2;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person_outline,
                      color: selectedPageIndex == 3
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onPrimary
                      // Global.mainColor : Colors.black45,
                      ),
                  onPressed: () async {
                    setState(() {
                      selectedPageIndex = 3;
                    });
                    // await navigatePageBottom(
                    //     context: context,
                    //     page: const LoginPage(),
                    //     rootNavigator: true);
                  },
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: _isOpenedCamera,
          child: Positioned.fill(
            child: Container(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void openFriendOptions(BuildContext context, Friend friend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Wrap(
                children: [
                  friend.isFavorite
                      ? ListTile(
                          leading: Icon(Icons.remove_circle_outline_rounded,
                              color: Colors.red),
                          title: Text(
                            "Remove from favorites",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            setState(() {
                              _friendFavoriteList.remove(friend);
                              List<Friend> _tempFriendList = _friendList;
                              for (Friend item in _tempFriendList) {
                                if (item == friend) {
                                  int index = _friendList.indexOf(friend);
                                  _friendList[index].isFavorite = false;
                                }
                              }

                              if (_friendFavoriteList.isEmpty)
                                _isVisibileFavoriteFriendList = false;
                              else
                                _isVisibileFavoriteFriendList = true;
                            });
                            Navigator.pop(context);
                          },
                        )
                      : ListTile(
                          leading: Icon(Icons.add,
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                          title: Text(
                            "Add to favorites",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                          onTap: () {
                            setState(() {
                              _friendFavoriteList.add(friend);
                              List<Friend> _tempFriendList = _friendList;
                              for (Friend item in _tempFriendList) {
                                if (item == friend) {
                                  int index = _friendList.indexOf(friend);
                                  _friendList[index].isFavorite = true;
                                }
                              }

                              if (_friendFavoriteList.length > 0)
                                _isVisibileFavoriteFriendList = true;
                            });
                            Navigator.pop(context);
                          },
                        )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Platform.isAndroid ? Permission.storage : Permission.photos,
      Permission.camera,
      Permission.microphone,
      Permission.mediaLibrary,
      Permission.speech,
      Permission.location,
    ].request();

    final info = statuses[Permission.storage].toString();
    if (kDebugMode) {
      print(info);
    }
    // toastInfo(info);
  }

  void changePage(int value) {
    setState(() {
      if (value != 1) selectedPageIndex = value;
    });
    if (value == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );
    } else if (value == 0) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const ProgressPage()),
      // );
    }
  }

  int getUnseenMessageCount() {
    int count = 0;
    for (var item in _friendList) {
      if (item.hasUnSeenMsgs) {
        count += item.unseenCount;
      }
    }
    return count;
  }
}

class PlaceholderWidget extends StatefulWidget {
  final Color color;
  const PlaceholderWidget({Key? key, required this.color}) : super(key: key);

  @override
  State<PlaceholderWidget> createState() => _PlaceholderWidgetState();
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
    );
  }
}
