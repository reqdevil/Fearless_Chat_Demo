import 'package:flutter/material.dart';

class HorizontalProgressIndicator extends StatefulWidget {
  @override
  HorizontalProgressIndicatorState createState() =>
      HorizontalProgressIndicatorState();
}

class HorizontalProgressIndicatorState
    extends State<HorizontalProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation animation;

  double beginAnim = 0.0;
  double endAnim = 1.0;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 5), vsync: this);
    animation = Tween(begin: beginAnim, end: endAnim).animate(controller)
      ..addListener(() {
        setState(() {
          // Change here any Animation object value.
        });
      });
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  startProgress() {
    controller.forward();
  }

  stopProgress() {
    controller.stop();
  }

  resetProgress() {
    controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20.0),
        child: LinearProgressIndicator(
          value: animation.value,
        ));
  }
}
