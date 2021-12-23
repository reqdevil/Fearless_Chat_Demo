import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatefulWidget {
  final Duration? duration;

  AnimationController? animationController;
  CustomCircularProgressIndicator(
      {Key? key, this.duration, this.animationController})
      : super(key: key);
  @override
  _CustomCircularProgressIndicatorState createState() =>
      _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState
    extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  // int timerCount = 60;
  // Timer _timer;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    widget.animationController = controller;
    controller.addListener(() {
      if (controller.value == 1.0) {
        controller.repeat(reverse: false);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.forward();
    // startTimer();
    return Transform(
      transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        strokeWidth: 6,
        value: controller.value,
        color: Colors.white,
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
      ),
    );
  }
}
