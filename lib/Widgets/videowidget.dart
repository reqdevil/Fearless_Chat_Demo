import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final bool play;
  String url;

  VideoWidget({Key? key, required this.url, required this.play})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController? videoPlayerController;
  // late Future<void> initializeVideoPlayerFuture;
  late VoidCallback? videoPlayerListener;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(File(widget.url));
    startVideoPlayer();
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }

  Future<void> startVideoPlayer() async {
    final VideoPlayerController vController = kIsWeb
        ? VideoPlayerController.network(widget.url)
        : VideoPlayerController.file(File(widget.url));

    videoPlayerListener = () {
      if (videoPlayerController != null &&
          videoPlayerController!.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoPlayerController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoPlayerController!.dispose();
    if (mounted) {
      setState(() {
        widget.url = "null";
        videoPlayerController = vController;
      });
    }
    if (widget.play) await vController.play();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(videoPlayerController!));
  }
}
