import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoPlayFileScreen extends StatefulWidget {
  final File file;

  const VideoPlayFileScreen({Key? key, required this.file}) : super(key: key);

  @override
  State<VideoPlayFileScreen> createState() => _VideoPlayFileScreenState();
}

class _VideoPlayFileScreenState extends State<VideoPlayFileScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(widget.file),
    );
  }

  @override
  void dispose() {
    super.dispose();
    flickManager.dispose();
  }

  void _openMyPage() {
    flickManager.dispose();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Scaffold(
          body: Center(
              child: FlickVideoPlayer(
                  flickVideoWithControls: const FlickVideoWithControls(
                    closedCaptionTextStyle: TextStyle(fontSize: 8),
                    controls: FlickPortraitControls(),
                  ),
                  flickVideoWithControlsFullscreen:
                      const FlickVideoWithControls(
                    controls: FlickLandscapeControls(),
                  ),
                  flickManager: flickManager))),
    );
  }
}
