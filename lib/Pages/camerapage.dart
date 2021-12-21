import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

late bool _isflashTap;
bool _isFlashOn = false;
bool _isFlashAuto = false;
bool _isFlashOff = false;
late bool _isTapImage;
int turns = 0;

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras = [];
  List<TakenCameraImage> imagePathList = [];
  String imagePath = "";
  bool _toggleCamera = false;
  CameraController? controller;
  int _pointers = 0;
  final double _minAvailableZoom = 1.0;
  final double _maxAvailableZoom = 10.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  XFile? imageFile;
  XFile? videoFile;
  @override
  void initState() {
    try {
      _isTapImage = false;
      _isflashTap = false;
      hideStatusbar();
      enableRotation();
      getCamera();
      Future.delayed(const Duration(seconds: 1), () {
        onCameraSelected(cameras[0]);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    backToOriginalRotation();
    showStatusbar();
    super.dispose();
  }

  Future<void> getCamera() async {
    cameras = await availableCameras();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          '',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      );
    }

    if (!controller!.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      key: _scaffoldKey,
      body: NativeDeviceOrientationReader(
        builder: (context) {
          NativeDeviceOrientation orientation;
          orientation = NativeDeviceOrientationReader.orientation(context);

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
          // final scale =
          //     1 / (controller!.value.aspectRatio * mediaSize.aspectRatio);
          return Stack(
            // fit: StackFit.expand,
            // alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: RotatedBox(
                  quarterTurns: -turns,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Listener(
                      onPointerDown: (_) => _pointers++,
                      onPointerUp: (_) => _pointers--,
                      child: CameraPreview(
                        controller!,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onScaleStart: _handleScaleStart,
                            onScaleUpdate: _handleScaleUpdate,
                            onTapDown: (details) =>
                                onViewFinderTap(details, constraints),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 0.0, bottom: 0, top: 0),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      height: MediaQuery.of(context).size.height / 15,
                      child: AnimatedOpacity(
                        opacity: _isflashTap ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, top: 14, right: 0, bottom: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 18.0, left: 18, top: 0),
                                child: GestureDetector(
                                  child: RotatedBox(
                                    quarterTurns: -turns,
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.flash_auto,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          'Auto',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if (!_isFlashOn) {
                                      onSetFlashModeButtonPressed(
                                          FlashMode.auto);
                                    }
                                    setState(() {
                                      _isFlashOn = false;
                                      _isFlashOff = false;
                                      _isFlashAuto = true;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: GestureDetector(
                                  child: RotatedBox(
                                    quarterTurns: -turns,
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.flash_off,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          'Off',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if (!_isFlashOff) {
                                      onSetFlashModeButtonPressed(
                                          FlashMode.off);
                                    }
                                    setState(() {
                                      _isFlashOff = true;
                                      _isFlashAuto = false;
                                      _isFlashOn = false;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: GestureDetector(
                                  child: RotatedBox(
                                    quarterTurns: -turns,
                                    child: Column(
                                      children: const [
                                        Icon(
                                          Icons.flash_on,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        Text(
                                          'On',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    if (!_isFlashOn) {
                                      onSetFlashModeButtonPressed(
                                          FlashMode.always);
                                    }
                                    setState(() {
                                      _isFlashOn = true;
                                      _isFlashOff = false;
                                      _isFlashAuto = false;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0.0, bottom: 0, top: 12, right: 10),
                        child: RotatedBox(
                          quarterTurns: -turns,
                          child: Icon(
                            _isFlashOn
                                ? Icons.flash_on
                                : _isFlashOff
                                    ? Icons.flash_off
                                    : _isFlashAuto
                                        ? Icons.flash_auto
                                        : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _isflashTap = !_isflashTap;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: _isTapImage ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0)),
                              color: Colors.black.withOpacity(0.7),
                            ),
                            // margin: const EdgeInsets.all(5),
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 64,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: imagePathList.length,
                                    // padding: const EdgeInsets.all(5),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, itemIndex) {
                                      return RotatedBox(
                                        quarterTurns: -turns,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, top: 2, bottom: 8),
                                          child: Stack(
                                            // fit: StackFit.loose,
                                            // alignment: Alignment.center,
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: SizedBox(
                                                  child: Container(
                                                    child: Center(
                                                      child: Image.file(
                                                        File(imagePathList
                                                            .reversed
                                                            .toList()[itemIndex]
                                                            .filePath),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  10)),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                  ),
                                                  width: 64.0,
                                                  height: 64.0,
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: GestureDetector(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              2),
                                                      height: 20,
                                                      width: 20,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          color: imagePathList[
                                                                      itemIndex]
                                                                  .isSelected
                                                              ? Colors.blue
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.blue)),
                                                      child: imagePathList[
                                                                  itemIndex]
                                                              .isSelected
                                                          ? const Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white,
                                                              size: 15,
                                                            )
                                                          : Container(),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      imagePathList[itemIndex]
                                                              .isSelected =
                                                          !imagePathList[
                                                                  itemIndex]
                                                              .isSelected;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(15, 10),
                                      padding: const EdgeInsets.all(0),
                                      primary: Colors.blue.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.upload_outlined,
                                      color: Colors.white,
                                      size: 25,
                                    ))
                              ],
                            ),
                          ),
                        ),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
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
                                    padding: const EdgeInsets.only(
                                        bottom: 0.0, right: 50),
                                    child: RotatedBox(
                                      quarterTurns: turns,
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
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: imagePath.isNotEmpty
                                  ? _thumbnailWidget()
                                  : Container(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        useSensor: true,
      ),
    );
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    // await controller!.dispose();
    controller = CameraController(cameraDescription, ResolutionPreset.max);

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
          TakenCameraImage image =
              TakenCameraImage(imagePath, false, DateTime.now());
          imagePathList.add(image);
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
    XFile file;
    if (!controller!.value.isInitialized) {
      showMessage('Error: select a camera first.');
      return "null";
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/FearlessChat/Camera/Images';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return "null";
    }

    try {
      file = await controller!.takePicture();
    } on CameraException catch (e) {
      showException(e);
      return "error";
    }
    return file.path;
  }

  void showException(CameraException e) {
    logError(e.code, e.description ?? "Empty");
    showMessage('Error: ${e.code}\n${e.description}');
  }

  void showMessage(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  void logError(String code, String message) =>
      print('Error: $code\nMessage: $message');

  Future<void> enableRotation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);
  }

  hideStatusbar() {
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.bottom, //This line is used for showing the bottom bar
    ]);
  }

  showStatusbar() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

// may block rotation; sets orientation back to OS defaults for the app
  Future<void> backToOriginalRotation() async {
    await SystemChrome.setPreferredOrientations([]);
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description ?? "Error");
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    if (kDebugMode) {
      print(_currentScale);
    }
    await controller!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            imagePath.isEmpty
                ? Container()
                : RotatedBox(
                    quarterTurns: -turns,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(children: [
                        GestureDetector(
                          child: SizedBox(
                            child:
                                // The captured image on the web contains a network-accessible URL
                                // pointing to a location within the browser. It may be displayed
                                // either with Image.network or Image.memory after loading the image
                                // bytes to memory.
                                Container(
                              child: Center(
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.5))),
                            ),
                            width: 64.0,
                            height: 64.0,
                          ),
                          onTap: () {
                            setState(() {
                              _isTapImage = !_isTapImage;
                            });
                          },
                        ),
                        imagePathList.isNotEmpty
                            ? Positioned.fill(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 2, right: 2, bottom: 2, top: 2),
                                    height: 20,
                                    width: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(color: Colors.red)),
                                    child: Text(
                                      imagePathList.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ]),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
