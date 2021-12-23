import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatefulWidget {
  final Duration? duration;
  final Color valueColor;
  final Color backgroundColor;
  final double strokeWidth;
  final Color color;
  AnimationController? animationController;
  CustomCircularProgressIndicator(
      {Key? key,
      this.duration,
      this.animationController,
      required this.valueColor,
      required this.backgroundColor,
      required this.strokeWidth, required this.color})
      : super(key: key);
  @override
  _CustomCircularProgressIndicatorState createState() =>
      _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState
    extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

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
    return Transform(
      transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        value: controller.value,
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
      ),
    );
  }
}
