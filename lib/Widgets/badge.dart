import 'package:fearless_chat_demo/Utils/global.dart';
import 'package:flutter/material.dart';

class Badge extends StatefulWidget {
  final int count;
  const Badge({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  State<Badge> createState() => _BadgeState();
}

class _BadgeState extends State<Badge> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.count > 0,
      child: Positioned(
        top: -1.0,
        right: 0.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.brightness_1,
              size: 25.0,
              color: Global.mainColor,
            ),
            Text(
              widget.count.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
