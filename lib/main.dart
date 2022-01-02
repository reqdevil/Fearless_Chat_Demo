import 'package:fearless_chat_demo/Pages/camerapage.dart';
import 'package:fearless_chat_demo/Pages/mainPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const FearlessChatApp());
}

class FearlessChatApp extends StatelessWidget {
  const FearlessChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraPage(),
    );
  }

  requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    if (kDebugMode) {
      print(info);
    }
    _toastInfo(info);
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }
}
