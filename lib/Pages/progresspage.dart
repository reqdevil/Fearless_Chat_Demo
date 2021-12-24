import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math' as math;

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  final List<LinearProgress> _list = [];
  late Timer timer;

  @override
  void initState() {
    for (var i = 0; i < 30; i++) {
      LinearProgress item =
          LinearProgress(GlobalObjectKey('key' + i.toString()), 0);

      _list.add(item);
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        int i = 0;
        timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
          if (i == _list.length) {
            timer.cancel();
            print('cancelled');
          }
          if (i < _list.length) {
            setState(() {
              _list[i].percentage += 10;

              // _list[i + 1].percentage = 0;
            });
          }

          if (_list[i].percentage == 100) i++;
          print(i);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        children: [
          ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: 30,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, itemIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Transform.rotate(
                    angle: -math.pi / 22,
                    child: LinearPercentIndicator(
                      // key: _list[itemIndex].key,
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      curve: Curves.linear,
                      restartAnimation: false,
                      animation: true,
                      animationDuration: 10,
                      alignment: MainAxisAlignment.center,
                      fillColor: Colors.transparent,
                      animateFromLastPercent: true,
                      width: MediaQuery.of(context).size.width,
                      lineHeight: 18.0,
                      percent: _list.isNotEmpty
                          ? _list.reversed.toList()[itemIndex].percentage / 100
                          : 0.0,
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      backgroundColor: Colors.white,
                      progressColor: Colors.indigo[400],
                    ),
                  ),
                );
              }),
          Positioned.fill(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: .5, sigmaY: 0.5),
                child: Container(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LinearProgress {
  // LinearPercentIndicator progressBar;
  GlobalObjectKey key;
  int percentage;

  LinearProgress(this.key, this.percentage);
}
