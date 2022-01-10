import 'package:fearless_chat_demo/Pages/LoginPage.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Pages/chatPage.dart';
import 'package:fearless_chat_demo/Utils/TransitionHelpers.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // late List<CameraDescription> cameras;
  int selectedPageIndex = 0;
  late List _children = [];

  // List<CameraDescription> cameras = [];

  // set cameras(List<CameraDescription> cameras) {}
  @override
  void initState() {
    _children = [
      null,
      const PlaceholderWidget(color: Colors.green),
      const PlaceholderWidget(color: Colors.deepOrange),
      const LoginPage()
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: selectedPageIndex == 0
          ? AppBar(
              iconTheme: IconThemeData(
                color: Colors.grey[700], //change your color here
              ),
              backgroundColor: Colors.white,
              textTheme:
                  Theme.of(context).textTheme.apply(bodyColor: Colors.black45),
              title: const Text("Messengerish"),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add_box),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: SafeArea(
          child: selectedPageIndex == 0
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: friendsList.length,
                  itemBuilder: (ctx, i) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          isThreeLine: true,
                          onLongPress: () {},
                          // onTap: () => Navigator.of(context).pushNamed('chat'),
                          onTap: () async {
                            await navigatePageBottom(
                                context: context,
                                page: ChatPage(userId: friendsList[i]['usrId']),
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
                                    color: Colors.grey.withOpacity(.3),
                                    offset: const Offset(0, 5),
                                    blurRadius: 25)
                              ],
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(friendsList[i]['imgUrl']),
                                  ),
                                ),
                                friendsList[i]['isOnline']
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
                            "${friendsList[i]['username']}",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          subtitle: Text(
                            "${friendsList[i]['lastMsg']}",
                            style: !friendsList[i]['seen']
                                ? Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .apply(color: Colors.black87)
                                : Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .apply(color: Colors.black54),
                          ),
                          trailing: SizedBox(
                            width: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    friendsList[i]['seen']
                                        ? const Icon(
                                            Icons.check,
                                            size: 15,
                                          )
                                        : const SizedBox(height: 15, width: 15),
                                    Text("${friendsList[i]['lastMsgTime']}")
                                  ],
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                friendsList[i]['hasUnSeenMsgs']
                                    ? Container(
                                        alignment: Alignment.center,
                                        height: 25,
                                        width: 25,
                                        decoration: BoxDecoration(
                                          color: Global().purple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          "${friendsList[i]['unseenCount']}",
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
                )
              : _children[selectedPageIndex]),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: keyboardIsOpened
          ? null
          : FloatingActionButton(
              elevation: 5,
              backgroundColor: Global().purple,
              child: const Icon(Icons.camera),
              onPressed: () async {
                await navigatePageBottom(
                    context: context,
                    page: const CameraPage(),
                    rootNavigator: true);
              },
            ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.message,
                  color: selectedPageIndex == 0
                      ? Global().purple
                      : Colors.black45),
              onPressed: () async {
                setState(() {
                  selectedPageIndex = 0;
                });

                // await navigatePageBottom(
                //     context: context, page: ChatPage(), rootNavigator: true);
              },
            ),
            IconButton(
              icon: Icon(Icons.view_list,
                  color: selectedPageIndex == 1
                      ? Global().purple
                      : Colors.black45),
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
                      ? Global().purple
                      : Colors.black45),
              onPressed: () {
                setState(() {
                  selectedPageIndex = 2;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.person_outline,
                  color: selectedPageIndex == 3
                      ? Global().purple
                      : Colors.black45),
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
      // bottomNavigationBar: Theme(
      //   data: Theme.of(context).copyWith(canvasColor: Colors.redAccent),
      //   child: BottomNavigationBar(
      //     currentIndex: selectedPageIndex,
      //     onTap: changePage,
      //     type: BottomNavigationBarType.fixed,
      //     fixedColor: Colors.white,
      //     items: [
      //       const BottomNavigationBarItem(
      //         icon: Icon(Icons.person),
      //         title: Text(
      //           'Profile',
      //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //         ),
      //       ),
      //       const BottomNavigationBarItem(
      //         icon: Icon(Icons.camera),
      //         title: Text(
      //           'Camera',
      //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //         ),
      //       ),
      //       const BottomNavigationBarItem(
      //         icon: Icon(Icons.chat_bubble),
      //         title: Text(
      //           'Chat',
      //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //         ),
      //       ),
      //       const BottomNavigationBarItem(
      //         icon: Icon(Icons.settings),
      //         title: Text(
      //           'Settings',
      //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
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
