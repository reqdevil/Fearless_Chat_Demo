import 'dart:async';
import 'dart:io';
import 'package:fearless_chat_demo/Utils/audioState.dart';
import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:fearless_chat_demo/Widgets/flowShader.dart';
import 'package:fearless_chat_demo/Widgets/lottieAnimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';

class RecordButton extends StatefulWidget {
  Function(List<Map<String, dynamic>>) endOfRecord;
  Function(bool) hasRecord;
  // Function(List<Map<String, dynamic>>) onLongPressEnd;
  RecordButton(
      {Key? key,
      required this.controller,
      required this.endOfRecord,
      required this.hasRecord})
      : super(key: key);

  final AnimationController controller;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 50;

  final double lockerHeight = 200;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
  late Record record;

  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    record = Record();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth =
        MediaQuery.of(context).size.width - 2 * Global.defaultPadding - 4;
    timerAnimation =
        Tween<double>(begin: timerWidth + Global.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation =
        Tween<double>(begin: lockerHeight + Global.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    record.dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        lockSlider(),
        cancelSlider(),
        audioButton(),
        if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Global.borderRadius),
          color: Global.mainColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.lock,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value,
      child: Container(
        height: size,
        width: timerWidth,
        // width: MediaQuery.of(context).size.width - 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Global.borderRadius),
          color: Global.mainColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              showLottie
                  ? const LottieAnimation()
                  : Padding(
                      padding: const EdgeInsets.only(left: 18.0),
                      child: Text(recordDuration,
                          style: TextStyle(color: Colors.white)),
                    ),
              const SizedBox(width: size),
              FlowShader(
                child: Row(
                  children: const [
                    Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.white,
                    ),
                    Text(
                      "Slide to cancel",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                duration: const Duration(seconds: 3),
                flowColors: const [Colors.white, Colors.grey],
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        // width: timerWidth,
        width: MediaQuery.of(context).size.width - 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Global.borderRadius),
          color: Global.mainColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: () async {
              Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;
              recordDuration = "00:00";

              var filePath = await Record().stop();
              AudioState.files.add(filePath!);
              List<Map<String, dynamic>> lstMessages = Global.getMessages();
              DateTime now = DateTime.now();
              lstMessages.add(
                {
                  'usrId': Global.selectedUserId,
                  'status': MessageType.sent,
                  'message': "",
                  'time': DateFormat('dd.MM.yyyy – kk:mm').format(now),
                  'hasShareMedia': true,
                  'filePaths': [filePath]
                },
              );
              widget.endOfRecord(lstMessages);
              // Global.audioListKey.currentState!
              //     .insertItem(AudioState.files.length - 1);
              debugPrint(filePath);
              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  recordDuration,
                  style: TextStyle(color: Colors.white),
                ),
                FlowShader(
                  child: const Text("Tap lock to stop",
                      style: TextStyle(color: Colors.white)),
                  duration: const Duration(seconds: 3),
                  flowColors: const [Colors.white, Colors.grey],
                ),
                const Center(
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          child: const Icon(
            Icons.mic,
            color: Colors.white,
          ),
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Global.mainColor,
          ),
        ),
      ),
      onLongPressDown: (_) {
        widget.hasRecord(true);
        debugPrint("onLongPressDown");
        widget.controller.forward();
      },
      onLongPressEnd: (details) async {
        debugPrint("onLongPressEnd");
        widget.hasRecord(false);
        if (isCancelled(details.localPosition, context)) {
          Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            var filePath = await record.stop();
            debugPrint(filePath);
            File(filePath!).delete();
            debugPrint("Deleted $filePath");
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();

          Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          widget.controller.reverse();

          Vibrate.feedback(FeedbackType.success);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          var filePath = await Record().stop();
          AudioState.files.add(filePath!);
          // Global.audioListKey.currentState!
          //     .insertItem(AudioState.files.length - 1);
          debugPrint(filePath);
          List<Map<String, dynamic>> lstMessages = Global.getMessages();
          DateTime now = DateTime.now();
          lstMessages.add(
            {
              'usrId': Global.selectedUserId,
              'status': MessageType.sent,
              'message': "",
              'time': DateFormat('dd.MM.yyyy – kk:mm').format(now),
              'hasShareMedia': true,
              'filePaths': [filePath]
            },
          );
          widget.endOfRecord(lstMessages);
        }
      },
      onLongPressCancel: () {
        debugPrint("onLongPressCancel");
        widget.controller.reverse();
      },
      onLongPress: () async {
        debugPrint("onLongPress");
        Vibrate.feedback(FeedbackType.success);
        if (await Record().hasPermission()) {
          print(Global.documentPath +
              "audio_${DateTime.now().millisecondsSinceEpoch}.m4a");
          await record.start(
            path: Global.documentPath +
                "audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
            encoder: AudioEncoder.AAC,
            bitRate: 128000,
            samplingRate: 44100,
          );
          startTime = DateTime.now();
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            final minDur = DateTime.now().difference(startTime!).inMinutes;
            final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
            String min = minDur < 10 ? "0$minDur" : minDur.toString();
            String sec = secDur < 10 ? "0$secDur" : secDur.toString();
            setState(() {
              recordDuration = "$min:$sec";
            });
          });
        }
      },
    );
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width) * 0.2);
  }
}
