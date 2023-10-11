import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/feedbackModel.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';

class MyCampaignDetailsTab3Screen extends StatefulWidget {
  const MyCampaignDetailsTab3Screen({Key? key}) : super(key: key);

  @override
  State<MyCampaignDetailsTab3Screen> createState() =>
      _MyCampaignDetailsTab3ScreenState();
}

class _MyCampaignDetailsTab3ScreenState
    extends State<MyCampaignDetailsTab3Screen> {
  Map<String, dynamic> map = {};

  FeedbackModel data = FeedbackModel();
  bool isApiCalled = true;
  String revuerMessage = "";
  String date = "";
  int page = 0;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Chat> myFeedList = [];

  @override
  void initState() {
    super.initState();
    /* _scrollController.addListener(() {
      setState(() {});
    });*/
    getFeedback("get");
  }

  getFeedback(String s) async {
    // isApiCalled = true;
    Map<String, dynamic> body = {
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken),
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "brand_token": await SharedPrefProvider.getString(
          SharedPrefProvider.brandloginUniqueToken),
      "revuer_message": revuerMessage,
      "page": page
    };
    log("reqParam feedback $body");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetFeedOption(body).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it["message"].toString());
          if (mounted) {
            log("responseSuccess feedback$it");
            log("responseSuccess feedback${it.data.toString()}");
            log("base url ${Strings.baseUrl}");
            var realData = DataEncryption.getDecryptedData(
                it.data!.reqKey.toString(), it.data!.reqData.toString());
            log("feed data ${realData.toString()}");
            setState(() {
              isApiCalled = false;
              data = FeedbackModel.fromJson(realData);
              if (s == "insert" && data.chat != null) {
                myFeedList.clear();
                myFeedList.addAll(data.chat!);
                myFeedList = myFeedList.reversed.toList();
                for(var i = 0; i<myFeedList.length; i++) {
                  if(i == 0){
                    date = myFeedList[0].date!;
                    log("0 index  $date" );
                  }
                  if(i != 0 && date == myFeedList[i].date){
                    log("blank date :- ");
                    myFeedList[i].date = "";
                  }else{
                    date = myFeedList[i].date!;
                    myFeedList[i].date = myFeedList[i].date!;
                    log("changed date :- $date");
                  }
                }
                //  myFeedList = myFeedList.reversed.toList();
              } else if (s == "load" && data.chat != null) {
                log("feed 2 before ${myFeedList.length}");
                myFeedList.addAll(data.chat!);
                _refreshController.loadComplete();
                log("feed 2 after ${myFeedList.length}");
              } else if (s == "get" && data.chat != null) {
                myFeedList.addAll(data.chat!);
                myFeedList = myFeedList.reversed.toList();
                for(var i = 0; i<myFeedList.length ; i++) {
                  if(i == 0){
                    date = myFeedList[0].date!;
                    log("0 index  $date" );
                  }
                  if(i != 0 && date == myFeedList[i].date){
                    log("blank date :- ");
                    myFeedList[i].date = "";
                  }else{
                    date = myFeedList[i].date!;
                    myFeedList[i].date = myFeedList[i].date!;
                    log("changed date :- $date");
                  }
                }
                //myFeedList = myFeedList.reversed.toList();
              }
              myFeedList = myFeedList.reversed.toList();
              if (data.chat == null) {
                _refreshController.loadNoData();
                _refreshController
                    .loadComplete(); // _refreshController.loadComplete();
              }
            });
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          if (mounted) {
            Fluttertoast.showToast(msg: it.message.toString());
            log("responseFailure feedback $it");
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Something went wrong new");
        }
        // non-200 error goes here.

        setState(() {
          isApiCalled = false;
        });
        log("responseException feedback$obj");
        switch (obj.runtimeType) {
          case DioError:
            // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            log("status ${res?.statusCode}");
            log("status ${res?.statusMessage}");
            log("status ${res?.data}");
            break;
          default:
            break;
        }
      });
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5.0, left: 16.0, right: 16.0),
      padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
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
              color: const Color(0xff2A3B53).withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20.0,
              offset: const Offset(0, 0),
            )
          ]),
      child: isApiCalled
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                /*myFeedList.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: const Center(
                          child: Text(
                            "Today",
                            style: TextStyle(
                                color: thirdColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0.0,
                      ),*/

                myFeedList.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        controller: _scrollController,
                        itemCount: myFeedList.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          width: 8.0,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              showDate(index),
                              myFeedList[index].type == "1"
                                  ? admin(index)
                                  : user(index),
                            ],
                          );
                        },
                      )
                        /*child: SmartRefresher(
                          controller: _refreshController,
                          enablePullDown: false,
                          enablePullUp:false */ /*myFeedList.length >= 5 ? true : false*/ /*,
                         */ /* onLoading: () {
                            page++;
                            revuer_message = "";
                            getFeedback("load");
                          },*/ /*
                          child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            reverse: false,
                            controller: _scrollController,
                            itemCount: myFeedList.length,
                            shrinkWrap: false,
                            padding: EdgeInsets.zero,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(
                              width: 8.0,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              if(index == 0){
                                date = myFeedList[0].date!;
                                log("o index  $date" );
                              }
                              return Column(
                                children: [
                                  showDate(index),
                                  myFeedList[index].type == "1"
                                      ? admin(index)
                                      : user(index),
                                ],
                              );
                            },
                          ),
                        ),*/
                        )
                    : noTask(),
                // data.options!.isNotEmpty
                data.options != null && data.options!.isNotEmpty
                    ? SizedBox(
                        height: 40.0,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.options!.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(
                            width: 8.0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                if(data.authType =="1"){
                                  setState(() {
                                    revuerMessage = data.options![index].name!;
                                    page = 0;
                                    getFeedback("insert");
                                  });
                                }
                              },
                              child:data.authType == "1"
                                  ? Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  border: Border.all(color: grayColor),
                                ),
                                child: Text(
                                  data.options![index].name!,
                                  style: const TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                                  : Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: fadeGreyColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      border: Border.all(color: grayColor),
                                    ),
                                    child: Text(
                                      data.options![index].name!,
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
    );
  }

  Widget showDate(int index) {
    return myFeedList[index].date! == ""
        ? const SizedBox()
        : Column(
      children: [
        Text(
          myFeedList[index].date!,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: thirdColor, fontSize: 12.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 16.0,
        ),
      ],
    );
    /* log("date index = ${index}");
    if(index == 0){
      return Column(
        children: [
          const SizedBox(
            height: 8.0,
          ),
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: thirdColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 16.0,
          ),
        ],
      );
    }
    if(index != 0 && date == myFeedList[index].date!){
      return const SizedBox();
    }else{
      if(index != 0){
        date = myFeedList[index].date!;
      }
      return Column(
        children: [
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: thirdColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 16.0,
          ),
        ],
      );
    }*/
  }

  Widget admin(int index) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipOval(
            child: showImage(myFeedList[index].image),
          ),
          const SizedBox(width: 4.0),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.all(16.0),
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
                      color: const Color(0xff2A3B53).withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20.0,
                      offset: const Offset(0, 0),
                    )
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    myFeedList[index].message!.trim(),
                    style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 16.0,
      ),
    ]);
  }

  Widget user(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(left: 8.0),
                padding: const EdgeInsets.all(16.0),
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
                        color: const Color(0xff2A3B53).withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 20.0,
                        offset: const Offset(0, 0),
                      )
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      myFeedList[index].message!.trim(),
                      style: const TextStyle(
                          color: secondaryColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4.0),
            ClipOval(
              child: showImage(myFeedList[index].revuer_image),
            ),
          ],
        ),
        const SizedBox(
          height: 16.0,
        ),
      ],
    );
  }

  Widget noTask() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/speaker.png',
              width: 40.00,
              height: 35.00,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "No feedbacks found...",
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10.0),
            const Text(
              "You don’t have any feedbacks...",
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget showImage(String? image) {
    if (isApiCalled) {
      return Shimmer.fromColors(
        baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
        highlightColor: Colors.white,
        child: Container(
          width: 30.0,
          height: 30.0,
          color: Colors.grey,
        ),
      );
    } else {
      if (image!.isNotEmpty) {
        return Image.network(image,
            width: 30.0,
            height: 30.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 30.0,
              height: 30.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 30.0,
            height: 30.0,
            child: Image.asset(
              width: 30.0,
              height: 30.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return ClipOval(
          child: Image.asset(
            'assets/images/dummy_avtar.png',
            width: 30.0,
            height: 30.0,
            fit: BoxFit.cover,
          ),
        );
      }
    }
  }
}
