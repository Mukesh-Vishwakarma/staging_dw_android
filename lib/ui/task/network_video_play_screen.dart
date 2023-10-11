import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import '../../res/colors.dart';

class VideoPlayNetworkScreen extends StatefulWidget {
  final String url;

  const VideoPlayNetworkScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPlayNetworkScreen> createState() => _VideoPlayNetworkScreenState();
}

class _VideoPlayNetworkScreenState extends State<VideoPlayNetworkScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    if (kDebugMode) {
      print("inti called video network ${widget.url}");
    }
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.url),
    );
    super.initState();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("dispose called video network");
    }
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
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  _openMyPage();
                },
              ),
              backgroundColor: secondaryColor,
            ),
            body: Center(child: FlickVideoPlayer(flickManager: flickManager))));
  }
}
