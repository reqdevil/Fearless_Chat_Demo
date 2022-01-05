import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fearless_chat_demo/Models/cameraimage.dart';
import 'package:fearless_chat_demo/Utils/fixExifRotation.dart';
import 'package:fearless_chat_demo/Widgets/circularprogressindicator.dart';
import 'package:fearless_chat_demo/Widgets/videoitem.dart';
import 'package:fearless_chat_demo/enums.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:math' as math;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

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
bool _isCameraInitialized = false;
late Stream<int>? timerStream;
late StreamSubscription<int> timerSubscription;
String hoursStr = "";
String minutesStr = "";
String secondsStr = "";
late CameraType cameraType;
TapDownDetails? exposedAreaDetails;

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationElementsController;
  late Animation<double> _animation;

  List<CameraDescription> cameras = [];
  List<TakenCameraMedia> mediaPathList = [];
  List<TakenCameraMedia> _listShareMedia = [];
  String imagePath = "";
  bool _toggleCamera = false;
  CameraController? controller;
  int _pointers = 0;
  // double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double minAvailableExposureOffset = 0.0;
  double maxAvailableExposureOffset = 0.0;
  double currentExposureOffset = 0.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  XFile? imageFile;
  XFile? videoFile;
  NativeDeviceOrientation oldOrientation = NativeDeviceOrientation.portraitUp;
  NativeDeviceOrientation? _orientationBeforeCapturevideo;
  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {});
    _animationElementsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: math.pi / 2)
        .animate(_animationElementsController);

    try {
      getCamera();
      _isTapImage = false;
      _isflashTap = false;
      _isVideoRecorderSelected = false;
      _isVideoRecording = false;
      hideStatusbar();
      enableRotation();

      // Future.delayed(const Duration(milliseconds: 1000), () {
      //   onCameraSelected(cameras[0]);
      // });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationElementsController.dispose();
    controller!.dispose();
    backToOriginalRotation();
    showStatusbar();
    super.dispose();
  }

  Future<void> getCamera() async {
    cameras = await availableCameras();
    setState(() {
      cameraType = CameraType.back;
    });
    onCameraSelected(cameras[0]);
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

    // if (!controller!.value.isInitialized) {
    //   return Container();
    // }

    return Scaffold(
        key: _scaffoldKey,
        body: _isCameraInitialized
            ? NativeDeviceOrientationReader(
                useSensor: true,
                builder: (context) {
                  // NativeDeviceOrientation orientation;
                  final orientation =
                      NativeDeviceOrientationReader.orientation(context);
                  int turns = 0;
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

                  if (oldOrientation != orientation) {
                    onRotationChangeHandler(orientation);
                    oldOrientation = orientation;
                  }
                  return Listener(
                    onPointerDown: (_) => _pointers++,
                    onPointerUp: (_) => _pointers--,
                    child: Stack(
                      clipBehavior: Clip.none,
                      // fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: CameraPreview(
                              controller!,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedOpacity(
                                opacity: _isVideoRecorderSelected ? 0 : 1,
                                duration: const Duration(milliseconds: 250),
                                child: GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, bottom: 0, top: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: const Icon(
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
                              AnimatedOpacity(
                                opacity: !_isVideoRecorderSelected ? 1 : 0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeIn,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 0),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 11),
                                    height: 32,
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        )),
                                    child: DropdownButton<ResolutionPreset>(
                                      alignment: Alignment.center,
                                      dropdownColor: Colors.black87,
                                      iconEnabledColor: Colors.white,
                                      underline: Container(),
                                      value: currentResolutionPreset,
                                      items: [
                                        for (ResolutionPreset preset
                                            in resolutionPresets)
                                          DropdownMenuItem(
                                            child: Text(
                                              preset
                                                  .toString()
                                                  .split('.')[1]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                              textAlign: TextAlign.center,
                                            ),
                                            value: preset,
                                          )
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          currentResolutionPreset = value!;
                                          _isCameraInitialized = false;
                                        });
                                        onCameraSelected(
                                            controller!.description);
                                      },
                                      hint: const Text("Select item"),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 1.8,
                            height: MediaQuery.of(context).size.height / 12.5,
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.only(top: 0, bottom: 8),
                            margin: const EdgeInsets.only(
                                bottom: 5, left: 8, top: 5, right: 0),
                            decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(_isflashTap ? 0.5 : 0.0),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    topLeft: Radius.circular(10.0))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  height:
                                      MediaQuery.of(context).size.height / 12,
                                  child: AnimatedOpacity(
                                    opacity: _isflashTap ? 1 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0,
                                          top: 10,
                                          right: 0,
                                          bottom: 0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 18.0, left: 5, top: 0),
                                            child: GestureDetector(
                                              child: AnimatedBuilder(
                                                animation: _animation,
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.flash_auto,
                                                      color: _isFlashAuto
                                                          ? Colors.yellow[700]
                                                          : Colors.white,
                                                      size: 25,
                                                    ),
                                                    Text(
                                                      'Auto',
                                                      style: TextStyle(
                                                          color: _isFlashAuto
                                                              ? Colors
                                                                  .yellow[700]
                                                              : Colors.white,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                builder: (context, child) {
                                                  return Transform.rotate(
                                                    angle: _animation.value,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                              onTap: () {
                                                if (!_isFlashAuto) {
                                                  setFlashMode(FlashMode.auto);
                                                }
                                                setState(() {
                                                  _isflashTap = false;
                                                  _isFlashOn = false;
                                                  _isFlashOff = false;
                                                  _isFlashAuto = true;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 18.0),
                                            child: GestureDetector(
                                              child: AnimatedBuilder(
                                                animation: _animation,
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.flash_off,
                                                      color: _isFlashOff
                                                          ? Colors.yellow[700]
                                                          : Colors.white,
                                                      size: 25,
                                                    ),
                                                    Text(
                                                      'Off',
                                                      style: TextStyle(
                                                          color: _isFlashOff
                                                              ? Colors
                                                                  .yellow[700]
                                                              : Colors.white,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                builder: (context, child) {
                                                  return Transform.rotate(
                                                    angle: _animation.value,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                              onTap: () {
                                                if (!_isFlashOff) {
                                                  setFlashMode(FlashMode.off);
                                                }
                                                setState(() {
                                                  _isflashTap = false;
                                                  _isFlashOff = true;
                                                  _isFlashAuto = false;
                                                  _isFlashOn = false;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5, right: 16.0),
                                            child: GestureDetector(
                                              child: AnimatedBuilder(
                                                animation: _animation,
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.flash_on,
                                                      color: _isFlashOn
                                                          ? Colors.yellow[700]
                                                          : Colors.white,
                                                      size: 25,
                                                    ),
                                                    Text(
                                                      'On',
                                                      style: TextStyle(
                                                          color: _isFlashOn
                                                              ? Colors
                                                                  .yellow[700]
                                                              : Colors.white,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                builder: (context, child) {
                                                  return Transform.rotate(
                                                    angle: _animation.value,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                              onTap: () {
                                                if (!_isFlashOn) {
                                                  setFlashMode(FlashMode.torch);
                                                }
                                                setState(() {
                                                  _isflashTap = false;
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
                                        left: 0.0,
                                        bottom: 0,
                                        top: 5,
                                        right: 5.0),
                                    child: AnimatedBuilder(
                                      animation: _animation,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: _isflashTap
                                              ? Colors.transparent
                                              : Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Icon(
                                          _isFlashOn
                                              ? Icons.flash_on
                                              : _isFlashOff
                                                  ? Icons.flash_off
                                                  : _isFlashAuto
                                                      ? Icons.flash_auto
                                                      : Icons.flash_off,
                                          color: (_isFlashAuto || _isFlashOn)
                                              ? Colors.yellow[700]
                                              : Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _animation.value,
                                          child: child,
                                        );
                                      },
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
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width / 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(Icons.add,
                                    color: Colors.white, size: 20),
                                RotatedBox(
                                  quarterTurns: -1,
                                  child: Slider(
                                    value: _currentScale,
                                    min: _minAvailableZoom,
                                    max: _maxAvailableZoom / 10,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white30,
                                    onChanged: (value) async {
                                      setState(() {
                                        _currentScale = value;
                                      });
                                      await controller!.setZoomLevel(value);
                                    },
                                  ),
                                ),
                                AnimatedBuilder(
                                    animation: _animation,
                                    child: const Icon(Icons.remove,
                                        color: Colors.white, size: 20),
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _animation.value,
                                        child: child,
                                      );
                                    }),
                                const SizedBox(
                                  width: 15,
                                  height: 15,
                                ),
                                AnimatedBuilder(
                                  animation: _animation,
                                  child: Container(
                                    width: 70,
                                    margin: const EdgeInsets.only(right: 5),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.black87.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.0, vertical: 10.0),
                                      child: Text(
                                        _currentScale.toStringAsFixed(1) + 'x',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _animation.value,
                                      child: child,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              itemCount: mediaPathList.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder:
                                                  (context, itemIndex) {
                                                return AnimatedBuilder(
                                                  animation: _animation,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            top: 2,
                                                            bottom: 8),
                                                    child: Stack(
                                                      // fit: StackFit.loose,
                                                      // alignment: Alignment.center,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: SizedBox(
                                                            child: Container(
                                                              child: Center(
                                                                  child: mediaPathList
                                                                              .reversed
                                                                              .toList()[
                                                                                  itemIndex]
                                                                              .fileType ==
                                                                          FileType
                                                                              .photo
                                                                      ? Image
                                                                          .file(
                                                                          File(mediaPathList
                                                                              .reversed
                                                                              .toList()[itemIndex]
                                                                              .filePath),
                                                                          fit: BoxFit
                                                                              .fill,
                                                                        )
                                                                      : VideoItem(
                                                                          url: mediaPathList
                                                                              .reversed
                                                                              .toList()[itemIndex]
                                                                              .filePath)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .transparent,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                              ),
                                                            ),
                                                            width: 64.0,
                                                            height: 64.0,
                                                          ),
                                                        ),
                                                        Positioned.fill(
                                                          child:
                                                              GestureDetector(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(2),
                                                                height: 20,
                                                                width: 20,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    color: mediaPathList[
                                                                                itemIndex]
                                                                            .isSelected
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .transparent,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .blue)),
                                                                child: mediaPathList[
                                                                            itemIndex]
                                                                        .isSelected
                                                                    ? const Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            15,
                                                                      )
                                                                    : Container(),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              setState(() {
                                                                mediaPathList[
                                                                        itemIndex]
                                                                    .isSelected = !mediaPathList[
                                                                        itemIndex]
                                                                    .isSelected;
                                                                if (mediaPathList
                                                                    .where((element) =>
                                                                        element
                                                                            .isSelected)
                                                                    .toList()
                                                                    .isNotEmpty) {
                                                                  _isSelectedImage =
                                                                      true;
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
                                                  builder: (context, child) {
                                                    return Transform.rotate(
                                                      angle: _animation.value,
                                                      child: child,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          AnimatedBuilder(
                                            animation: _animation,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  if (!_isSelectedImage) {
                                                    null;
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  minimumSize:
                                                      MaterialStateProperty.all(
                                                          const Size(15, 15)),
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          const EdgeInsets.all(
                                                              0)),
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith<Color>(
                                                    (Set<MaterialState>
                                                        states) {
                                                      if (_isSelectedImage) {
                                                        return Colors.green[600]
                                                            as Color;
                                                      } else if (!_isSelectedImage) {
                                                        return Colors.grey;
                                                      }
                                                      return Colors.transparent;
                                                    },
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.upload,
                                                  color: Colors.white,
                                                  size: 25,
                                                )),
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle: _animation.value,
                                                child: child,
                                              );
                                            },
                                          )
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
                                  color: const Color.fromRGBO(00, 00, 00, 0.7)
                                      .withOpacity(0.3),
                                  child: Stack(
                                    // fit: StackFit.loose,
                                    alignment: Alignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                radius: 0,
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                onTap: () {
                                                  _captureImage();
                                                },
                                                child: SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.0),
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
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth:
                                                                    6.0,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white24,
                                                                valueColor:
                                                                    Colors.red,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            60),
                                                              ),
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            _isVideoRecorderSelected &&
                                                    !_isVideoRecording
                                                ? GestureDetector(
                                                    child: const Icon(
                                                        Icons.circle,
                                                        color: Colors.red,
                                                        size: 50),
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
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                        ),
                                                        onTap: () {
                                                          onStopButtonPressed();
                                                          setState(() {
                                                            _isVideoRecording =
                                                                false;
                                                          });
                                                        },
                                                      )
                                                    : Container()
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            AnimatedBuilder(
                                              animation: _animation,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (!_isVideoRecording) {
                                                    setState(() {
                                                      _isVideoRecorderSelected =
                                                          !_isVideoRecorderSelected;
                                                    });
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  minimumSize:
                                                      const Size(50, 50),
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
                                                child: Icon(
                                                    Icons
                                                        .video_camera_back_outlined,
                                                    size: 30,
                                                    color:
                                                        _isVideoRecorderSelected
                                                            ? Colors.yellow[700]
                                                            : Colors.white),
                                              ),
                                              builder: (context, child) {
                                                return Transform.rotate(
                                                  angle: _animation.value,
                                                  child: child,
                                                );
                                              },
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                height: 50,
                                                width: 50,
                                                child: InkWell(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              50.0)),
                                                  onTap: () {
                                                    if (!_isVideoRecording) {
                                                      if (!_toggleCamera) {
                                                        onCameraSelected(
                                                            cameras[1]);
                                                        setState(() {
                                                          _toggleCamera = true;
                                                          cameraType =
                                                              CameraType.front;
                                                        });
                                                      } else {
                                                        onCameraSelected(
                                                            cameras[0]);
                                                        setState(() {
                                                          _toggleCamera = false;
                                                          cameraType =
                                                              CameraType.back;
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 0.0,
                                                            right: 0),
                                                    child: AnimatedBuilder(
                                                      animation: _animation,
                                                      child: Image.asset(
                                                        'assets/ic_switch_camera_3.png',
                                                        color: Colors.grey[200],
                                                        width: 50.0,
                                                        height: 50.0,
                                                      ),
                                                      builder:
                                                          (context, child) {
                                                        return Transform.rotate(
                                                          angle:
                                                              _animation.value,
                                                          child: child,
                                                        );
                                                      },
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
                                        child: mediaPathList.isNotEmpty
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
                        exposedAreaDetails != null
                            ? addExposedArea(exposedAreaDetails!)
                            : Container(),
                      ],
                    ),
                  );
                },
              )
            : Container(color: Colors.black));
  }

  Widget addExposedArea(TapDownDetails details) {
    Widget exposedArea = Row(
      children: [
        Positioned(
          left: details.globalPosition.dx,
          top: details.globalPosition.dy,
          child: SizedBox(
            height: 100,
            width: 100,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 1),
              ),
            ),
          ),
        ),
        RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            height: 30,
            child: Slider(
              value: currentExposureOffset,
              min: minAvailableExposureOffset,
              max: maxAvailableExposureOffset,
              activeColor: Colors.amber,
              inactiveColor: Colors.amber[300],
              onChanged: (value) async {
                setState(() {
                  currentExposureOffset = value;
                });
                await controller!.setExposureOffset(value);
              },
            ),
          ),
        ),
      ],
    );
    return exposedArea;
  }

  double angle = 0.0;
  void onRotationChangeHandler(NativeDeviceOrientation orientation) {
    if (kDebugMode) {
      print(orientation);
    }

    if (orientation == NativeDeviceOrientation.landscapeLeft) {
      _animation = Tween<double>(begin: 0, end: math.pi / 2)
          .animate(_animationElementsController);
    } else if (orientation == NativeDeviceOrientation.portraitDown) {
      _animation = Tween<double>(begin: math.pi / 2, end: math.pi)
          .animate(_animationElementsController);
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      _animation = Tween<double>(begin: math.pi, end: math.pi + math.pi / 2)
          .animate(_animationElementsController);
    } else if (orientation == NativeDeviceOrientation.portraitUp) {
      _animation =
          Tween<double>(begin: math.pi + math.pi / 2, end: math.pi + math.pi)
              .animate(_animationElementsController);
    }
    _animationElementsController.forward(from: 0);
  }

  void onCameraSelected(CameraDescription cameraDescription) async {
    // await controller!.dispose();
    setState(() {
      controller = CameraController(cameraDescription, currentResolutionPreset);
    });

    controller!.addListener(() {
      if (mounted) {
        setState(() {
          setState(() {
            _isCameraInitialized = controller!.value.isInitialized;
          });
        });
      }
      if (controller!.value.hasError) {
        showMessage('Camera Error: ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
      const Duration(milliseconds: 500);
      await controller!.lockCaptureOrientation();
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb
            ? [
                controller!
                    .getMinExposureOffset()
                    .then((value) => minAvailableExposureOffset = value),
                controller!
                    .getMaxExposureOffset()
                    .then((value) => maxAvailableExposureOffset = value)
              ]
            : []),
        controller!
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        controller!
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      showException(e);
    }

    if (mounted) setState(() {});
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() {
    takePicture().then((String filePath) async {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        File file =
            await fixExifRotation(imagePath, oldOrientation, cameraType);
        TakenCameraMedia media =
            TakenCameraMedia(file.path, false, DateTime.now(), FileType.photo);
        setState(() {
          mediaPathList.add(media);
        });

        saveFileToGalery(FileType.photo, file.path);
        // showMessage('Picture saved to $filePath');
        // setCameraResult();
      }
    });
  }

  Future<void> captureVideo() async {
    _orientationBeforeCapturevideo = oldOrientation;

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
      return;
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
    stopVideoRecording().then((file) async {
      if (mounted) setState(() {});
      if (file != null) {
        // showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        imagePath = file.path;
        if (kDebugMode) {
          print(videoFile!.path);
        }
        Directory videoFileDirectory = File(videoFile!.path).parent;

        // 0 = 90CounterCLockwise and Vertical Flip (default)
        // 1 = 90Clockwise
        // 2 = 90CounterClockwise
        // 3 = 90Clockwise and Vertical Flip
        // String rotation = '';
        DateTime now = DateTime.now();
        String newFilePath = videoFileDirectory.path +
            '/RECFearlessChat' +
            DateFormat('yyyy-MM-dd–kk:mm').format(now) +
            '.mp4';
        String filePath = videoFile!.path;
        String looselessConversion = '';
        if (_orientationBeforeCapturevideo ==
            NativeDeviceOrientation.landscapeLeft) {
          looselessConversion =
              '-i ' + filePath + ' -vf "transpose=2" ' + newFilePath;
          // rotation = '2';
        } else if (_orientationBeforeCapturevideo ==
            NativeDeviceOrientation.landscapeRight) {
          // rotation = '1';
          looselessConversion =
              '-i ' + filePath + ' -vf "transpose=1" ' + newFilePath;
        } else if (oldOrientation == NativeDeviceOrientation.portraitUp) {
          // rotation = '0';
          TakenCameraMedia media =
              TakenCameraMedia(filePath, false, DateTime.now(), FileType.video);
          mediaPathList.add(media);
          saveFileToGalery(FileType.video, filePath);
          _startVideoPlayer(filePath);
          return;
          // looselessConversion =
          //     '-i ' + filePath + ' -vf "transpose=0" ' + newFilePath;
        } else if (oldOrientation == NativeDeviceOrientation.portraitDown) {
          // rotation = '3';
          looselessConversion = '-i ' +
              filePath +
              ' -vf "transpose=2,transpose=2" ' +
              newFilePath;
        }

        // final String ac = '-i ' +
        //     filePath +
        //     ' -map_metadata 0 -metadata:s:v rotate="90" -codec copy ' +
        //     newFilePath;
        // final String looselessConversion = '-i ' +
        //     filePath +
        //     ' -vf "transpose=' +
        //     rotation +
        //     '" ' +
        //     newFilePath;
        try {
          FFmpegKit.execute(looselessConversion).then((session) async {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              // SUCCESS
              await File(videoFile!.path).delete();
              TakenCameraMedia media = TakenCameraMedia(
                  newFilePath, false, DateTime.now(), FileType.video);
              mediaPathList.add(media);
              saveFileToGalery(FileType.video, newFilePath);
              _startVideoPlayer(newFilePath);
            } else if (ReturnCode.isCancel(returnCode)) {
              // CANCEL

            } else {
              // ERROR

            }
          });
        } catch (e) {
          if (kDebugMode) {
            print('video processing error: $e');
          }
        }
      }
    });
  }

  Future<void> _startVideoPlayer(String videoFilePath) async {
    if (!File(videoFilePath).existsSync()) {
      return;
    }
    // if (videoFile == null) {
    //   return;
    // }

    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.network(videoFilePath)
        : VideoPlayerController.file(File(videoFilePath));

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
    await vController.seekTo(const Duration(milliseconds: 900));
    await vController.setVolume(0.0);
    await vController.pause();
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
    setFlashMode(mode);
    // setFlashMode(mode).then((_) {
    //   if (mounted) setState(() {});
    //   // showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    // });
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
    if (controller == null) {
      return;
    }
    setState(() {
      _currentScale = (_baseScale * details.scale)
          .clamp(_minAvailableZoom, _maxAvailableZoom / 10);
      // _baseScale = _baseScale * details.scale;
    });

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
    setState(() {
      exposedAreaDetails = details;
    });
    // addExposedArea(details);
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
      kIsWeb ? ResolutionPreset.max : currentResolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;
    // CameraDescription direction = cameraController.description;
    // If the controller is updated then update the UI.

    cameraController.addListener(() {
      if (mounted) {
        setState(() {
          _isCameraInitialized = controller!.value.isInitialized;
        });
      }

      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb
            ? [
                cameraController
                    .getMinExposureOffset()
                    .then((value) => minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((value) => maxAvailableExposureOffset = value)
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
    return AnimatedBuilder(
      animation: _animation,
      child: Stack(children: [
        GestureDetector(
          child: Container(
              margin: const EdgeInsets.only(left: 10),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: FileImage(File(mediaPathList.last.filePath)),
                    fit: BoxFit.cover,
                  )),
              child: localVideoController != null &&
                      localVideoController.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: AspectRatio(
                        aspectRatio: localVideoController.value.aspectRatio,
                        child: VideoPlayer(localVideoController),
                      ),
                    )
                  : Container()),
          onTap: () {
            setState(() {
              // _isTapImage = !_isTapImage;
              _listShareMedia = mediaPathList;
              showModalBottomSheet(
                enableDrag: true,
                isDismissible: true,
                isScrollControlled: true,
                backgroundColor: Colors.black,
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _animation,
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (!_isSelectedImage) {
                                        null;
                                      }
                                      setState(() {});
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
                                      Icons.upload,
                                      color: Colors.white,
                                      size: 25,
                                    )),
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _animation.value,
                                    child: child,
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: _animation,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (!_isSelectedImage) {
                                        null;
                                      } else {
                                        setState(() {
                                          removeMediaFromShareList();
                                        });
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
                                            return Colors.red;
                                          } else if (!_isSelectedImage) {
                                            return Colors.grey;
                                          }
                                          return Colors.transparent;
                                        },
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 25,
                                    )),
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _animation.value,
                                    child: child,
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            // width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 2.5,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: mediaPathList.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 20),
                                  child: AnimatedBuilder(
                                    animation: _animation,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          mediaPathList.reversed
                                                  .toList()[index]
                                                  .isSelected =
                                              !mediaPathList.reversed
                                                  .toList()[index]
                                                  .isSelected;
                                          if (mediaPathList.reversed
                                              .toList()
                                              .where((element) =>
                                                  element.isSelected)
                                              .toList()
                                              .isNotEmpty) {
                                            _isSelectedImage = true;
                                          } else {
                                            _isSelectedImage = false;
                                          }
                                          _listShareMedia =
                                              mediaPathList.reversed.toList();
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              alignment: Alignment.center,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 20),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                border: Border.all(
                                                    color: mediaPathList
                                                            .reversed
                                                            .toList()[index]
                                                            .isSelected
                                                        ? Colors.amber
                                                        : Colors.grey
                                                            .withOpacity(0.5),
                                                    width: 2),
                                                image: DecorationImage(
                                                  image: FileImage(
                                                    File(mediaPathList.reversed
                                                        .toList()[index]
                                                        .filePath),
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              child: mediaPathList.reversed
                                                          .toList()[index]
                                                          .fileType ==
                                                      FileType.video
                                                  ? VideoItem(
                                                      url: mediaPathList
                                                          .reversed
                                                          .toList()[index]
                                                          .filePath)
                                                  : Container(),
                                            ),
                                          ),
                                          Positioned.fill(
                                            top: 22,
                                            right: 12,
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Container(
                                                margin: const EdgeInsets.all(2),
                                                height: 20,
                                                width: 20,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: mediaPathList
                                                            .reversed
                                                            .toList()[index]
                                                            .isSelected
                                                        ? Colors.blue
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.5))),
                                                child: mediaPathList.reversed
                                                        .toList()[index]
                                                        .isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )
                                                    : Container(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _animation.value,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            });
          },
        ),
        mediaPathList.isNotEmpty
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.red)),
                    child: Text(
                      mediaPathList.length.toString(),
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
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
    );
  }

  saveFileToGalery(FileType fileType, String filePath) async {
    if (fileType == FileType.video) {
      final result = await ImageGallerySaver.saveFile(filePath);
      if (kDebugMode) {
        print(result);
      }
      // toastInfo("$result");
    } else if (fileType == FileType.photo) {
      final originalFile = File(filePath);
      List<int> imageBytes = await originalFile.readAsBytes();
      // Uint8List bytes = File.fromUri(Uri.parse(filePath)).readAsBytesSync();
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(imageBytes),
          quality: 80);

      if (kDebugMode) {
        print(result);
      }
      // toastInfo("$result");
    }
  }

  toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  void removeMediaFromShareList() {
    for (var item in _listShareMedia.reversed.toList()) {
      if (item.isSelected) {
        setState(() {
          mediaPathList.remove(item);
        });
      }
    }

    if (mediaPathList.isEmpty) {
      setState(() {
        _listShareMedia.clear();
      });

      Navigator.pop(context);
    }
    if (mediaPathList.reversed
        .toList()
        .where((element) => element.isSelected)
        .toList()
        .isEmpty) {
      setState(() {
        _isSelectedImage = false;
      });
    }
  }
}
