import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:native_device_orientation/native_device_orientation.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras = [];
  late String imagePath;
  bool _toggleCamera = false;
  CameraController? controller;

  @override
  void initState() {
    try {
      getCamera();
      // Future.delayed(const Duration(seconds: 2), () {
      //   onCameraSelected(cameras[0]);
      // });
    } catch (e) {
      print(e.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  Future<void> getCamera() async {
    cameras = await availableCameras();
    onCameraSelected(cameras[0]);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // if (cameras.isEmpty) {
    //   return Container(
    //     alignment: Alignment.center,
    //     padding: const EdgeInsets.all(16.0),
    //     child: const Text(
    //       'No Camera Found',
    //       style: TextStyle(
    //         fontSize: 16.0,
    //         color: Colors.white,
    //       ),
    //     ),
    //   );
    // }

    // if (!controller!.value.isInitialized) {
    //   return Container();
    // }

    return Scaffold(
      key: _scaffoldKey,
      body: NativeDeviceOrientationReader(
        builder: (context) {
          NativeDeviceOrientation orientation =
              NativeDeviceOrientationReader.orientation(context);

          int turns;
          switch (orientation) {
            case NativeDeviceOrientation.landscapeLeft:
              turns = -1;
              break;
            case NativeDeviceOrientation.landscapeRight:
              turns = 1;
              break;
            case NativeDeviceOrientation.portraitDown:
              turns = 2;
              break;
            default:
              turns = 0;
              break;
          }
          final size = MediaQuery.of(context).size;
          final deviceRatio = size.width / size.height;

          final mediaSize = MediaQuery.of(context).size;
          final scale =
              1 / (controller!.value.aspectRatio * mediaSize.aspectRatio);
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: scale,
                  child: RotatedBox(
                    quarterTurns: turns,
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                          child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: CameraPreview(controller!))),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 0.0, bottom: 0, top: 15),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 0.0, bottom: 0, top: 15),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 90,
                  // padding: const EdgeInsets.only(bottom: 80.0),
                  color: const Color.fromRGBO(00, 00, 00, 0.7),
                  child: Stack(
                    fit: StackFit.loose,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            onTap: () {
                              _captureImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                'assets/ic_shutter_1.png',
                                width: 50.0,
                                height: 50.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            onTap: () {
                              if (!_toggleCamera) {
                                onCameraSelected(cameras[1]);
                                setState(() {
                                  _toggleCamera = true;
                                });
                              } else {
                                onCameraSelected(cameras[0]);
                                setState(() {
                                  _toggleCamera = false;
                                });
                              }
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(bottom: 0.0, right: 80),
                              child: Image.asset(
                                'assets/ic_switch_camera_3.png',
                                color: Colors.grey[200],
                                width: 32.0,
                                height: 32.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    // await controller!.dispose();
    controller =
        CameraController(cameraDescription, ResolutionPreset.ultraHigh);

    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showMessage('Camera Error: ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      showException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });

        showMessage('Picture saved to $filePath');
        // setCameraResult();

      }
    });
  }

  void setCameraResult() {
    Navigator.pop(context, imagePath);
  }

  Future<String> takePicture() async {
    if (!controller!.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return "null";
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/FlutterDevs/Camera/Images';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return "null";
    }

    try {
      XFile file = await controller!.takePicture();
    } on CameraException catch (e) {
      showException(e);
      return "error";
    }
    return filePath;
  }

  void showException(CameraException e) {
    logError(e.code, e.description ?? "Empty");
    showMessage('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    print(message);
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');

  getApplicationDocumentsDirectory() {}
}
