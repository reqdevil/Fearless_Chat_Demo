// ignore_for_file: file_names
import 'package:camera/camera.dart';
import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Pages/camerapage_old.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      const PlaceholderWidget(color: Colors.white),
      // CameraPage(),
      // const PlaceholderWidget(color: Colors.deepOrange),
      const PlaceholderWidget(color: Colors.green),
      const PlaceholderWidget(color: Colors.blue)
    ];

    super.initState();
  }

  // Future<void> getCameras() async {
  //   cameras = await availableCameras();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: _children[selectedPageIndex],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.redAccent),
        child: BottomNavigationBar(
          currentIndex: selectedPageIndex,
          onTap: changePage,
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.white,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              title: Text(
                'Camera',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              title: Text(
                'Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
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
