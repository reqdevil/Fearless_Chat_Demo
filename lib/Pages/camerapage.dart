import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Widgets/circularprogressindicator.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

late bool _isflashTap;
bool _isFlashOn = false;
bool _isFlashAuto = false;
bool _isFlashOff = false;
late bool _isVideoRecorderSelected;
late bool _isVideoRecording;
late bool _isTapImage;
bool _isSelectedImage = false;
int turns = 0;
late Stream<int>? timerStream;
late StreamSubscription<int> timerSubscription;
String hoursStr = "";
String minutesStr = "";
String secondsStr = "";

class _CameraPageState extends State<CameraPage> {
  List<CameraDescription> cameras = [];
  List<TakenCameraImage> imagePathList = [];
  String imagePath = "";
  bool _toggleCamera = false;
  CameraController? controller;
  int _pointers = 0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  XFile? imageFile;
  XFile? videoFile;
  @override
  void initState() {
    try {
      _isTapImage = false;
      _isflashTap = false;
      _isVideoRecorderSelected = false;
      _isVideoRecording = false;
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
                  quarterTurns: turns,
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
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: _isVideoRecording && _isVideoRecorderSelected
                      ? Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              color: Colors.red),
                          child: Text(
                            "$hoursStr:$minutesStr:$secondsStr",
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      : !_isVideoRecording && _isVideoRecorderSelected
                          ? const Text(
                              "00:00:00",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : Container(),
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
                                                        child: imagePathList
                                                                    .reversed
                                                                    .toList()[
                                                                        itemIndex]
                                                                    .fileType ==
                                                                FileType.photo
                                                            ? Image.file(
                                                                File(imagePathList
                                                                    .reversed
                                                                    .toList()[
                                                                        itemIndex]
                                                                    .filePath),
                                                                fit:
                                                                    BoxFit.fill,
                                                              )
                                                            : VideoItem(
                                                                url: imagePathList
                                                                    .reversed
                                                                    .toList()[
                                                                        itemIndex]
                                                                    .filePath)
                                                        // : VideoWidget(
                                                        //     url: imagePathList
                                                        //         .reversed
                                                        //         .toList()[
                                                        //             itemIndex]
                                                        //         .filePath,
                                                        //     play: false),
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
                                                      if (imagePathList
                                                          .where((element) =>
                                                              element
                                                                  .isSelected)
                                                          .toList()
                                                          .isNotEmpty) {
                                                        _isSelectedImage = true;
                                                      } else {
                                                        _isSelectedImage =
                                                            false;
                                                      }
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
                                    onPressed: () {
                                      if (!_isSelectedImage) {
                                        null;
                                      }
                                    },
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(15, 15)),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(0)),
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (_isSelectedImage) {
                                            return Colors.green[600] as Color;
                                          } else if (!_isSelectedImage) {
                                            return Colors.grey;
                                          }
                                          return Colors.transparent;
                                        },
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0)),
                                      onTap: () {
                                        _captureImage();
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Image.asset(
                                              'assets/ic_shutter_1.png',
                                              width: 50.0,
                                              height: 50.0,
                                            ),
                                          ),
                                          _isVideoRecording
                                              ? SizedBox(
                                                  height: 45,
                                                  width: 45,
                                                  child:
                                                      CustomCircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 6.0,
                                                    backgroundColor:
                                                        Colors.white24,
                                                    valueColor: Colors.red,
                                                    duration: const Duration(
                                                        seconds: 60),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  ),
                                  _isVideoRecorderSelected && !_isVideoRecording
                                      ? GestureDetector(
                                          child: const Icon(Icons.circle,
                                              color: Colors.red, size: 50),
                                          onTap: () {
                                            setState(() {
                                              _isVideoRecording =
                                                  !_isVideoRecording;
                                            });
                                            if (_isVideoRecorderSelected) {
                                              captureVideo();
                                            }
                                          },
                                        )
                                      : (_isVideoRecorderSelected &&
                                              _isVideoRecording)
                                          ? GestureDetector(
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                              ),
                                              onTap: () {
                                                onStopButtonPressed();
                                                setState(() {
                                                  _isVideoRecording = false;
                                                });
                                              },
                                            )
                                          : Container()
                                ],
                              ),
                            ),

                            // cameraTogglesRowWidget(),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (!_isVideoRecording) {
                                        setState(() {
                                          _isVideoRecorderSelected =
                                              !_isVideoRecorderSelected;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(30, 30),
                                      padding: const EdgeInsets.all(0),
                                      primary: Colors.grey.withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Icon(
                                        Icons.video_camera_back_outlined,
                                        size: 20,
                                        color: _isVideoRecorderSelected
                                            ? Colors.yellow[700]
                                            : Colors.white),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0)),
                                      onTap: () {
                                        if (!_isVideoRecording) {
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
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            bottom: 0.0, right: 25),
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
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: imagePathList.isNotEmpty
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
          TakenCameraImage image = TakenCameraImage(
              imagePath, false, DateTime.now(), FileType.photo);
          imagePathList.add(image);
        });

        showMessage('Picture saved to $filePath');
        // setCameraResult();
      }
    });
  }

  Future<void> captureVideo() async {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      setState(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
    });
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void onStopButtonPressed() {
    timerSubscription.cancel();
    timerStream = null;
    setState(() {
      hoursStr = '00';
      minutesStr = '00';
      secondsStr = '00';
    });
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        imagePath = file.path;
        print(videoFile!.path);
        TakenCameraImage image =
            TakenCameraImage(imagePath, false, DateTime.now(), FileType.video);
        imagePathList.add(image);
        _startVideoPlayer();
      }
    });
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.network(videoFile!.path)
        : VideoPlayerController.file(File(videoFile!.path));

    videoPlayerListener = () {
      if (videoController != null && videoController!.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
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
    // _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
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

  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        throw ArgumentError('Unknown lens direction');
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;
    CameraDescription direction = cameraController.description;
    int angle = direction.sensorOrientation;
    // If the controller is updated then update the UI.

    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb
            ? [
                cameraController
                    .getMinExposureOffset()
                    .then((value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((value) => _maxAvailableExposureOffset = value)
              ]
            : []),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Stream<int> stopWatchStream() {
    late StreamController<int> streamController;
    late Timer? timer;
    Duration timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  Widget cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    final onChanged = (CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    };

    if (cameras.isEmpty) {
      return const Text('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged:
                  controller != null && controller!.value.isRecordingVideo
                      ? null
                      : onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            localVideoController == null && imagePath.isEmpty
                ? Container()
                : RotatedBox(
                    quarterTurns: -turns,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(children: [
                        GestureDetector(
                          child: SizedBox(
                            child: (localVideoController == null)
                                ? (
                                    // The captured image on the web contains a network-accessible URL
                                    // pointing to a location within the browser. It may be displayed
                                    // either with Image.network or Image.memory after loading the image
                                    // bytes to memory.
                                    Image.file(File(imagePath)))
                                : Container(
                                    child: Center(
                                      child: AspectRatio(
                                          aspectRatio: localVideoController
                                              .value.aspectRatio,
                                          child: VideoPlayer(
                                              localVideoController)),
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(color: Colors.grey)),
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
