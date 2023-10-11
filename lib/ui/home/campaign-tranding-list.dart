import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/models/camp_trending_model.dart';
import 'package:revuer/ui/campaign/campaign-details.dart';
import 'package:revuer/ui/campaign/my-campaign-details.dart';
import 'package:revuer/ui/refer_earn/refer_earn_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shared_preference/preference_provider.dart';

class CampaignTrendingListItem extends StatefulWidget {
  final int index;
  final int verifyStatus;
  final List<CampaignData> data;

  const CampaignTrendingListItem(
      {Key? key, this.index = 0, this.verifyStatus = 0, required this.data})
      : super(key: key);

  @override
  State<CampaignTrendingListItem> createState() =>
      _CampaignTrendingListItemState();
}

class _CampaignTrendingListItemState extends State<CampaignTrendingListItem> {
  @override
  Widget build(BuildContext context) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: widget.index == 0
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  )
                : BorderRadius.zero),
        child: widget.data[widget.index].listDisplayType == 1
            ? InkWell(
                onTap: () async {


                  print("djshabzxjhknwksdmax=========>");

/*
          Map<String, dynamic> trendingBody = {
            "campaign_token": widget.data[widget.index].campaignToken
          };

          var data = await Provider.of<CampaignDetailsProvider>(context,
              listen: false)
              .getCampaignDetails(trendingBody);
*/
                  // log("campaign data ${data.campaignObj}");
                  // if(data.categoryName!.isNotEmpty) {
                  // }

                  // print("Check screen nagivation===> ${widget.data[widget.index].approveStatus}");

                  if (widget.data[widget.index].approveStatus == 1) {
                    SharedPrefProvider.setString(
                        SharedPrefProvider.campaignToken,
                        "${widget.data[widget.index].campaignToken}");
                    SharedPrefProvider.setString(
                        SharedPrefProvider.brandloginUniqueToken,
                        "${widget.data[widget.index].brandloginUniqueToken}");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/campaign-task'),
                        builder: (context) => const MyCampaignDetailsScreen(),
                      ),
                    );
                    //  Navigator.pushReplacementNamed(context, '/my-campaign-details');
                  } else {
                    SharedPrefProvider.setString(
                        SharedPrefProvider.campaignToken,
                        "${widget.data[widget.index].campaignToken}");
                    SharedPrefProvider.setString(
                        SharedPrefProvider.brandloginUniqueToken,
                        "${widget.data[widget.index].brandloginUniqueToken}");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/campaign-task'),
                        builder: (context) => const CampaignDetailsScreen(
                          location: "home",
                        ),
                      ),
                    );
                    // Navigator.pushReplacementNamed(context, '/campaign-details');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff2A3B53).withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 7,
                          offset: const Offset(1, 1),
                        ),
                        BoxShadow(
                          color: const Color(0xff2A3B53).withOpacity(0.04),
                          spreadRadius: 0,
                          blurRadius: 9.0,
                          offset: const Offset(0, 0),
                        )
                      ]),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: widget.data[widget.index].socialIcon!.isNotEmpty
                            ? Container(
                                width: 40.0,
                                height: 40.0,
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: grayColorD,
                                  shape: BoxShape.circle,
                                ),
                                child: showSocialIcon(
                                    widget.data[widget.index].socialIcon!))
                            : const SizedBox(),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(13.0, 17.0, 10.0, 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Image.network(
                                "${widget.data[widget.index].image}",
                                width: 130.0,
                                height: 130.0,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: const Color.fromRGBO(
                                        191, 191, 191, 0.5254901960784314),
                                    highlightColor: Colors.white,
                                    child: Container(
                                      width: 130.0,
                                      height: 130.0,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    width: 130.0,
                                    height: 130.0,
                                    child: Image.asset(
                                      width: 80.0,
                                      height: 80.0,
                                      'assets/images/error_image.png',
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 14.0,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 30),
                                    child: Text(
                                      "${widget.data[widget.index].campaignName}",
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: unitHeightValue * 1.8 > 14.0
                                            ? 14.0
                                            : unitHeightValue * 1.8,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                    "${widget.data[widget.index].brandName}",
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: unitHeightValue * 1.99 > 16.0
                                          ? 16.0
                                          : unitHeightValue * 1.99,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  FittedBox(
                                    child: Row(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 2.0),
                                              child: Image.asset(
                                                  'assets/icons/wallet.png',
                                                  width: 18.0,
                                                  height: 18.0,
                                                  fit: BoxFit.fitWidth),
                                            ),
                                            const SizedBox(
                                              width: 5.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Earn Upto",
                                                  style: TextStyle(
                                                    color: thirdColor,
                                                    fontSize: unitHeightValue *
                                                                1.8 >
                                                            14.0
                                                        ? 14.0
                                                        : unitHeightValue * 1.8,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                Text(
                                                  "\u{20B9}${widget.data[widget.index].earnUpto}",
                                                  style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize:
                                                        unitHeightValue * 1.99 >
                                                                16.0
                                                            ? 16.0
                                                            : unitHeightValue *
                                                                1.99,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 18.0,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 2.0),
                                              child: Image.asset(
                                                  'assets/icons/slot.png',
                                                  width: 20.5,
                                                  height: 19.0,
                                                  fit: BoxFit.fitWidth),
                                            ),
                                            const SizedBox(
                                              width: 5.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Slots",
                                                  style: TextStyle(
                                                    color: thirdColor,
                                                    fontSize: unitHeightValue *
                                                                1.8 >
                                                            14.0
                                                        ? 14.0
                                                        : unitHeightValue * 1.8,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${widget.data[widget.index].joinRevuer}",
                                                      style: TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: unitHeightValue *
                                                                    1.99 >
                                                                16.0
                                                            ? 16.0
                                                            : unitHeightValue *
                                                                1.99,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      "/${widget.data[widget.index].revuerLimit}",
                                                      style: TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: unitHeightValue *
                                                                    1.8 >
                                                                14.0
                                                            ? 14.0
                                                            : unitHeightValue *
                                                                1.8,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff2A3B53).withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 7,
                        offset: const Offset(1, 1),
                      ),
                      BoxShadow(
                        color: const Color(0xff2A3B53).withOpacity(0.04),
                        spreadRadius: 0,
                        blurRadius: 9.0,
                        offset: const Offset(0, 0),
                      )
                    ]),
                child: showView(widget.data[widget.index].mainType,
                    widget.data[widget.index]),
              ));
  }

  Widget showSocialIcon(String type) {
    log("social type:- $type");
    if (type == "1") {
      return Image.asset(
        "assets/images/facebook.png",
        width: 30,
        height: 30,
      );
    } else if (type == "2") {
      return Image.asset(
        "assets/images/instagram.png",
        width: 30,
        height: 30,
      );
    } else if (type == "3") {
      return Image.asset(
        "assets/images/twitter.png",
        width: 30,
        height: 30,
      );
    } else if (type == "4") {
      return Image.asset(
        "assets/images/youtube.png",
        width: 30,
        height: 30,
      );
    } else if (type == "5") {
      return Image.asset(
        "assets/images/pinterest.png",
        width: 30,
        height: 30,
      );
    } else if (type == "6") {
      return Image.asset(
        "assets/images/linkedin.png",
        width: 30,
        height: 30,
      );
    } else {
      return const SizedBox();
    }
  }

  browseInternet(String url) async {
    try {
      log("url is:$url");
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
      return true;
    } catch (error) {
      log("url is error :$error");
    }
  }

  Widget showView(int? mainType, CampaignData data) {
    if (mainType == 1) {
      return InkWell(
        onTap: () {
          apiAdsTrack(mainType!, 0, data.advertisementToken!);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            height: 150,
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    data.image!,
                    height: 150.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        child: Image.asset(
                          'assets/images/error_image.png',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, bottom: 8, right: 12),
                  child: Text(
                    data.content!,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else if (mainType == 2) {
      return InkWell(
        onTap: () {
          apiAdsTrack(mainType!, 0, data.advertisementToken!);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const ReferEarnScreen();
          }));
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            height: 150,
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    data.image!,
                    height: 150.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                          height: 150,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.blue,
                          )));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        child: Image.asset(
                          'assets/images/error_image.png',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else if (mainType == 3) {
      return InkWell(
        onTap: () {
          apiAdsTrack(mainType!, 0, data.advertisementToken!);
          Navigator.pushNamed(context, "/social-account");
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            height: 150,
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    data.image!,
                    height: 150.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        child: Image.asset(
                          'assets/images/error_image.png',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, bottom: 8, right: 12),
                  child: Text(
                    data.content!,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else if (mainType == 4) {
      return VideoPlay(
        path: data.videoName,
        imagePath: data.thumbnailImage,
        content: data.content,
        iconImage: data.iconImage,
        link: data.link,
        type: mainType,
        adToken: data.advertisementToken!,
      );
    } else {
      return const SizedBox();
    }
  }
}

class VideoPlay extends StatefulWidget {
  String? path;
  String? adToken;
  String? imagePath;
  String? content;
  String? iconImage;
  String? link;
  int? type;

  @override
  _VideoPlayState createState() => _VideoPlayState();

  VideoPlay(
      {Key? key,
      this.path,
      this.imagePath,
      this.content,
      this.iconImage,
      this.link,
      this.type,
      this.adToken // Video from assets folder
      })
      : super(key: key);
}

class _VideoPlayState extends State<VideoPlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;
  bool isMusicOn = false;
  bool isShowVideo = false;

  initVideo() {
    controller = VideoPlayerController.network(widget.path!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    futureController = controller!.initialize();
  }

  @override
  void initState() {
    initVideo();
    controller!.addListener(() {
      if (controller!.value.isInitialized) {
        currentPosition.value = controller!.value;
      }
    });
    controller!.addListener(() {
      if (controller!.value.position ==
          const Duration(seconds: 0, minutes: 0, hours: 0)) {
        if (kDebugMode) {
          print('video has Started');
        }
      }
      if (controller!.value.position == controller!.value.duration) {
        if (kDebugMode) {
          print('video has Ended');
        }
        setState(() {
          isShowVideo = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureController,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          widget.imagePath!,
                          height: 150.0,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                                height: 150,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.blue,
                                )));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              child: Image.asset(
                                'assets/images/error_image.png',
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ClipOval(
                                    child: Image.network(widget.iconImage!,
                                        width: 35.0,
                                        height: 35.0,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Shimmer.fromColors(
                                        baseColor: const Color.fromRGBO(
                                            191, 191, 191, 0.5254901960784314),
                                        highlightColor: Colors.white,
                                        child: Container(
                                          width: 41.0,
                                          height: 41.0,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }, errorBuilder:
                                            (context, error, stackTrace) {
                                      return SizedBox(
                                        width: 41.0,
                                        height: 41.0,
                                        child: Image.asset(
                                          width: 41.0,
                                          height: 41.0,
                                          'assets/images/error_image.png',
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }),
                                  )),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.content!,
                                      maxLines: 2,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  apiAdsTrack(widget.type!, 2, widget.adToken!);
                                  browseInternet(widget.link!);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.open_in_new,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          );
        } else {
          if (isShowVideo) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (controller!.value.isPlaying) {
                      controller!.pause();
                    } else {
                      // If the video is paused, play it.
                      controller!.play();
                    }
                  });
                },
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            child: SizedBox(
                              child: FutureBuilder(
                                future: futureController,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return VideoPlayer(controller!);
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () {
                                soundToggle();
                              },
                              child: Icon(
                                isMusicOn == true
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          if (!controller!.value.isPlaying)
                            Container(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  // apiAdsTrack(1);
                                  setState(() {
                                    // If the video is playing, pause it.
                                    if (controller!.value.isPlaying) {
                                      controller!.pause();
                                    } else {
                                      // If the video is paused, play it.
                                      controller!.play();
                                    }
                                  });
                                },
                                child: Icon(
                                  controller!.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: ClipOval(
                                        child: Image.network(widget.iconImage!,
                                            width: 35.0,
                                            height: 35.0,
                                            fit: BoxFit.cover, loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Shimmer.fromColors(
                                            baseColor: const Color.fromRGBO(191,
                                                191, 191, 0.5254901960784314),
                                            highlightColor: Colors.white,
                                            child: Container(
                                              width: 41.0,
                                              height: 41.0,
                                              color: Colors.grey,
                                            ),
                                          );
                                        }, errorBuilder:
                                                (context, error, stackTrace) {
                                          return SizedBox(
                                            width: 41.0,
                                            height: 41.0,
                                            child: Image.asset(
                                              width: 41.0,
                                              height: 41.0,
                                              'assets/images/error_image.png',
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        }),
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.content!,
                                          maxLines: 2,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      apiAdsTrack(
                                          widget.type!, 2, widget.adToken!);
                                      browseInternet(widget.link!);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.open_in_new,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.network(
                            widget.imagePath!,
                            height: 150.0,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                  height: 150,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  )));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                child: Image.asset(
                                  'assets/images/error_image.png',
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              apiAdsTrack(widget.type!, 1, widget.adToken!);
                              setState(() {
                                isShowVideo = true;
                                // If the video is playing, pause it.
                                if (controller!.value.isPlaying) {
                                  controller!.pause();
                                } else {
                                  // If the video is paused, play it.
                                  controller!.play();
                                }
                              });
                            },
                            child: Icon(
                              controller!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: ClipOval(
                                      child: Image.network(widget.iconImage!,
                                          width: 35.0,
                                          height: 35.0,
                                          fit: BoxFit.cover, loadingBuilder:
                                              (BuildContext context,
                                                  Widget child,
                                                  ImageChunkEvent?
                                                      loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Shimmer.fromColors(
                                          baseColor: const Color.fromRGBO(191,
                                              191, 191, 0.5254901960784314),
                                          highlightColor: Colors.white,
                                          child: Container(
                                            width: 41.0,
                                            height: 41.0,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }, errorBuilder:
                                              (context, error, stackTrace) {
                                        return SizedBox(
                                          width: 41.0,
                                          height: 41.0,
                                          child: Image.asset(
                                            width: 41.0,
                                            height: 41.0,
                                            'assets/images/error_image.png',
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }),
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.content!,
                                        maxLines: 2,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    apiAdsTrack(
                                        widget.type!, 2, widget.adToken!);
                                    browseInternet(widget.link!);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.open_in_new,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            );
          }
        }
      },
    );
  }

  browseInternet(String url) async {
    try {
      log("url is:$url");
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
      return true;
    } catch (error) {
      log("url is error :$error");
    }
  }

  void soundToggle() {
    setState(() {
      isMusicOn == false
          ? controller!.setVolume(0.0)
          : controller!.setVolume(1.0);
      isMusicOn = !isMusicOn;
    });
  }
}

apiAdsTrack(int type, int clickType, String token) async {
  Map<String, dynamic> map = {
    "main_type": type,
    "click_type": clickType,
    "advertisement_token": token,
    "revuer_token":
        await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
  };
  if (kDebugMode) {
    print("requestParam api ads track$map");
  }
  bool isOnline = await ApiClient.hasNetwork();
  if (isOnline) {
    ApiClient.getClient()
        .apiAdsTracker(DataEncryption.getEncryptedData(map))
        .then((it) {
      if (it.status == "SUCCESS") {
        if (kDebugMode) {
          print("responseSuccess api ads track $it");
        }
      } else if (it.status == "FAILURE") {
        if (kDebugMode) {
          print("responseFailure api ads track$it");
        }
        Fluttertoast.showToast(msg: it.message.toString());
      }
    }).catchError((Object obj) {
      Fluttertoast.showToast(msg: "Something went wrong");
      // non-200 error goes here.
      if (kDebugMode) {
        print("responseException api ads track$obj");
      }
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (kDebugMode) {
            print("status ${res?.statusCode}");
          }
          if (kDebugMode) {
            print("status ${res?.statusMessage}");
          }
          if (kDebugMode) {
            print("status ${res?.data}");
          }
          break;
        default:
          break;
      }
    });
  } else {
    Fluttertoast.showToast(msg: "No Internet Available");
  }
}
