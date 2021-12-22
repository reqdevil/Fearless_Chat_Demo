import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  final String url;

  VideoItem({Key? key, required this.url}) : super(key: key);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(alignment: Alignment.center, children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                    onTap: playPause,
                    child: Icon(Icons.play_circle,
                        color: Colors.white.withOpacity(0.6))))
          ])
        : Container();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  playPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }
}
