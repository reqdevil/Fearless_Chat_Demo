import 'dart:async';

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
    for (var i = 0; i < 31; i++) {
      LinearProgress item =
          LinearProgress(GlobalObjectKey('key' + i.toString()), 0);

      _list.add(item);
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        int i = 0;
        timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
          if (i == _list.length + 1) {
            timer.cancel();
            print('cancelled');
          }
          if (i < _list.length) {
            setState(() {
              _list[i].percentage += 10;

              // _list[i + 1].percentage = 0;
            });
          }

          if (_list[i].percentage == 100 && i < _list.length) i++;
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
      body: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: 31,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, itemIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Transform.rotate(
                angle: -math.pi / 13.5,
                child: LinearPercentIndicator(
                  // key: _list[itemIndex].key,
                  padding: const EdgeInsets.all(0),
                  // curve: Curves.linear,
                  restartAnimation: false,
                  animation: true,
                  animationDuration: 100,
                  alignment: MainAxisAlignment.center,
                  fillColor: Colors.red,
                  animateFromLastPercent: true,
                  width: MediaQuery.of(context).size.width,
                  lineHeight: 18.0,
                  percent: _list.isNotEmpty
                      ? _list.reversed.toList()[itemIndex].percentage / 100
                      : 0.0,
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  backgroundColor: Colors.white,
                  progressColor: Colors.indigo.withOpacity(0.5),
                ),
              ),
            );
          }),
    );
  }
}

class LinearProgress {
  // LinearPercentIndicator progressBar;
  GlobalObjectKey key;
  int percentage;

  LinearProgress(this.key, this.percentage);
}
