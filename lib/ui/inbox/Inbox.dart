import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../res/paragraph.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../campaign/campaign-details.dart';
import '../campaign/my-campaign-details.dart';
import '../earnings/my-earnings.dart';
import '../main/main.dart';
import 'notice_model.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  double statusBarHeight = 5.0;

  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();
  NotificationModel notificationModel = NotificationModel();
  String revuerImage = "";
  var _revuerName = "";
  bool isApiCalled = false;
  bool _enabled = true;
  var noticePage = 0;
  List<NotificationList> noticeList = [];
  final RefreshController noticeRefreshController =
      RefreshController(initialRefresh: true);

  getRevuerDetails() async {
    if (mounted) {
      setState(() {
        isApiCalled = true;
      });
    }
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) {
        if (it.status == "SUCCESS") {
          if (mounted) {
            setState(() {
              isApiCalled = false;
            });
          }
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          revuerDetailsModel = RevuerDetailsModel.fromJson(realData);

          if (revuerDetailsModel.revuerData!.firstName == "" ||
              revuerDetailsModel.revuerData!.firstName == null) {
            _revuerName = Strings.appName;
          } else {
            if (mounted) {
              setState(() {
                _revuerName = revuerDetailsModel.revuerData!.firstName!.replaceFirst(
                    revuerDetailsModel.revuerData!.firstName![0],
                    revuerDetailsModel.revuerData!.firstName![0].toUpperCase());
              });
            }
          }

          if (revuerDetailsModel.revuerData!.image == "" ||
              revuerDetailsModel.revuerData!.image == null) {
            revuerImage = "";
          } else {
            if (mounted) {
              setState(() {
                revuerImage = revuerDetailsModel.revuerData!.image!;
              });
            }
          }

          if (kDebugMode) {
            print("real data $realData");
          }
          if (kDebugMode) {
            print("responseSuccess $it");
          }
        } else if (it.status == "FAILURE") {
          if (mounted) {
            setState(() {
              isApiCalled = false;
            });
          }
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          setState(() {
            isApiCalled = false;
          });
        }
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException $obj");
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

  getNoticeList(String s) async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "page": noticePage //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetNotificationList(map).then((it) {
        if (it.status == "SUCCESS") {
          if (kDebugMode) {
            print("responseSuccess get notice ${it.data}");
          }
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          notificationModel = NotificationModel.fromJson(realData);
          if (kDebugMode) {
            print("responseSuccess real data get notice $realData");
          }
          if (mounted) {
            setState(() {
              if (notificationModel.notificationList != null &&
                  notificationModel.notificationList!.isNotEmpty) {
                if (s == "refresh") {
                  if (kDebugMode) {
                    print("responseSuccess ${it.data}");
                  }
                  setState(() {
                    noticeRefreshController.refreshCompleted();
                    noticeList.clear();
                    noticeList.addAll(notificationModel.notificationList!);
                    noticeRefreshController.resetNoData();
                  });
                } else if (s == "loading") {
                  if (kDebugMode) {
                    print("responseSuccess ${it.data}");
                  }
                  noticeList.addAll(notificationModel.notificationList!);
                  noticeRefreshController.loadComplete();
                } else {
                  if (kDebugMode) {
                    print("responseSuccess ${it.data}");
                  }
                  noticeList.clear();
                  noticeList.addAll(notificationModel.notificationList!);
                }
              } else {
                if (s == "refresh") {
                  noticeRefreshController.refreshCompleted();
                  noticeList.clear();
                  noticeRefreshController.resetNoData();
                } else if (s == "loading") {
                  Fluttertoast.showToast(msg: it.message!);
                  noticeRefreshController.loadComplete();
                  noticeRefreshController.loadNoData();
                }
              }
            });
            setState(() {
              _enabled = false;
            });
          }
        } else if (it.status == "FAILURE") {
          if (kDebugMode) {
            print("responseFailure get notice ${it.data}");
          }
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
          if (s == "refresh") {
            noticeRefreshController.refreshFailed();
          } else if (s == "loading") {
            noticeRefreshController.loadFailed();
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException get notice $obj");
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

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  void initState() {
    super.initState();
    getRevuerDetails();
  }

  @override
  void dispose() {
    super.dispose();
    noticeRefreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Stack(
        children: [
          SizedBox(
            child: ClipPath(
              clipper: OvalClipper(),
              child: Container(
                width: double.infinity,
                height: 242.0,
                color: secondaryColor,
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.fromLTRB(16.0, (statusBarHeight + 8.0), 16.0, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/profile');
                          },
                          child: ClipOval(
                              child:
                                  showImage()
                              ),
                        ),
                        /*Image.asset(
                            'assets/icons/search.png',
                            width: 22.0,
                            height: 21.0,
                            fit: BoxFit.fitWidth
                        ),*/
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      Strings.inbox,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                    child: SmartRefresher(
                      controller: noticeRefreshController,
                      enablePullUp: true,
                      footer: CustomFooter(
                        builder: (BuildContext context, LoadStatus? mode) {
                          Widget body;
                          if (mode == LoadStatus.idle) {
                            body = const Text("pull up load");
                          } else if (mode == LoadStatus.loading) {
                            body = const CupertinoActivityIndicator();
                          } else if (mode == LoadStatus.failed) {
                            body = const Text("Load Failed!Click retry!");
                          } else if (mode == LoadStatus.canLoading) {
                            body = const Text("Release to load more");
                          } else {
                            body = const Text("List ends here..");
                          }
                          return SizedBox(
                            height: 55.0,
                            child: Center(child: body),
                          );
                        },
                      ),
                      onRefresh: () {
                        if (mounted) {
                          setState(() {
                            _enabled = true;
                          });
                        }
                        noticePage = 0;
                        getNoticeList("refresh");
                      },
                      onLoading: () {
                        noticePage++;
                        getNoticeList("loading");
                      },
                      child: _enabled
                          ? ListView.builder(
                              itemCount: 6,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  top: 10, left: 1.0, right: 1.0),
                              itemBuilder: (context, index) {
                                // print('apiData ${apiData.list[index]}');
                                return Shimmer.fromColors(
                                  baseColor: const Color.fromRGBO(
                                      191, 191, 191, 0.5),
                                  highlightColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 20.0, 0.0, 20.0),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 40.0,
                                            height: 40.0,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                top: 10.0),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xff5CEF9A)),
                                            child: const Text("J",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                    FontWeight.w600)),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  decoration:
                                                  const BoxDecoration(
                                                      color: Colors
                                                          .white,
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(
                                                        Radius.circular(
                                                            20.0),
                                                      )),
                                                  child: Text(
                                                    "Review recent added",
                                                    style: TextStyle(
                                                      color:
                                                      secondaryColor,
                                                      fontSize: unitHeightValue *
                                                          1.8 >
                                                          14.0
                                                          ? 14.0
                                                          : unitHeightValue *
                                                          1.8,
                                                      fontWeight:
                                                      FontWeight
                                                          .w400,
                                                    ),
                                                  )),
                                              const SizedBox(
                                                height: 5.0,
                                              ),
                                              Container(
                                                  decoration:
                                                  const BoxDecoration(
                                                      color: Colors
                                                          .white,
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(
                                                        Radius.circular(
                                                            20.0),
                                                      )),
                                                  child: Text(
                                                    "Shoppers",
                                                    style: TextStyle(
                                                      color:
                                                      secondaryColor,
                                                      fontSize: unitHeightValue *
                                                          1.8 >
                                                          14.0
                                                          ? 14.0
                                                          : unitHeightValue *
                                                          1.8,
                                                      fontWeight:
                                                      FontWeight
                                                          .w400,
                                                    ),
                                                  )),
                                              const SizedBox(
                                                height: 5.0,
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Container(
                                              decoration:
                                              const BoxDecoration(
                                                  color: Colors
                                                      .white,
                                                  borderRadius:
                                                  BorderRadius
                                                      .all(
                                                    Radius.circular(
                                                        20.0),
                                                  )),
                                              child: Text(
                                                "10 m",
                                                style: TextStyle(
                                                  color:
                                                  secondaryColor,
                                                  fontSize: unitHeightValue *
                                                      1.8 >
                                                      14.0
                                                      ? 14.0
                                                      : unitHeightValue *
                                                      1.8,
                                                  fontWeight:
                                                  FontWeight
                                                      .w400,
                                                ),
                                              ) ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ); //,data: apiData);
                              })
                          : noticeList.isNotEmpty
                              ? ListView.separated(
                                  itemCount: noticeList.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(
                                            height: 1,
                                            color: grayColor,
                                          ),
                                  itemBuilder: (context, index) {
                                    return showWidgets(noticeList[index]);
                                  })
                              : noInbox(),
                    ),
                    /* ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff5CEF9A)),
                                child: const Text("J",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Purchase home made Pickle, K-homes",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "Campaign 20",
                                      style: TextStyle(
                                          color: thirdColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              const Text(
                                "10m",
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: grayColor,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFAC876)),
                                child: const Text("S",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Review a product, Shoppers",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "Campaign 20",
                                      style: TextStyle(
                                          color: thirdColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              const Text(
                                "1h ago",
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: grayColor,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFBA88E)),
                                child: const Text("A",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lorem ipsum",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 18.0),
                                      child: Text(
                                        "Added file to Brand A campaign Task.",
                                        style: TextStyle(
                                            color: thirdColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/icons/pdf.png',
                                          width: 34.0,
                                          height: 34.0,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Document 1.pdf",
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              height: 3.0,
                                            ),
                                            Text(
                                              "1.2 MB",
                                              style: TextStyle(
                                                  color: thirdColor,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              const Text(
                                "19h ago",
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: grayColor,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFAC876)),
                                child: const Text("S",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Review a product, Shoppers",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "Campaign 20",
                                      style: TextStyle(
                                          color: thirdColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              const Text(
                                "1h ago",
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: grayColor,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff5CEF9A)),
                                child: const Text("J",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Purchase home made Pickle, K-homes",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "Campaign 20",
                                      style: TextStyle(
                                          color: thirdColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              const Text(
                                "10m",
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          color: grayColor,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 10.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffFBA88E)),
                                child: const Text("A",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lorem ipsum",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 18.0),
                                      child: Text(
                                        "Added file to Brand A campaign Task.",
                                        style: TextStyle(
                                            color: thirdColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/icons/pdf.png',
                                          width: 34.0,
                                          height: 34.0,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Document 1.pdf",
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              height: 3.0,
                                            ),
                                            Text(
                                              "1.2 MB",
                                              style: TextStyle(
                                                  color: thirdColor,
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15.0,
                              ),
                              const Text(
                                "19h ago",
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),*/
                  ),
                ),
                /*Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
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
                        ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/envelope.png',
                          width: 52.0,
                          height: 41.6,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16.5,),
                        const Text(
                          "Your inbox is empty...",
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0,),
                        const Text(
                          "You haven’t applied in an any\ncampaign yet...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
              ],
            ),
          )
        ],
      ),
    );
  }

  getFormattedDateFromFormattedString(
      {required value,
        required String currentFormat,
        required String desiredFormat,
        isUtc = false}) {
    DateTime? dateTime = DateTime.now();
    if (value != null || value.isNotEmpty) {
      try {
        dateTime = DateFormat(currentFormat).parse(value, isUtc).toLocal();
      } catch (e) {
        if (kDebugMode) {
          print("$e");
        }
      }
    }
    return dateTime;
  }

  Widget showWidgets(NotificationList noticeList) {
    DateTime dateTime = getFormattedDateFromFormattedString(
        value: noticeList.insertDate!,
        currentFormat: "yyyy-MM-ddTHH:mm:ssZ",
        desiredFormat: "yyyy-MM-dd HH:mm:ss");
    return InkWell(
      onTap: (){
        if (noticeList.type == "1") {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(
             builder: (context) => MainScreen(),
           ),
         );
        } else if (noticeList.type == "2") {
          var campToken = noticeList.campaignToken;
          var brandToken = noticeList.brandToken;
          var campType = noticeList.requestType;
          SharedPrefProvider.setString(
              SharedPrefProvider.campaignToken, "$campToken");
          SharedPrefProvider.setString(
              SharedPrefProvider.brandloginUniqueToken, "$brandToken");
          if (campType == "1") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MyCampaignDetailsScreen(index: 0,),
              ),
            );
          } else if (campType == "2") {
            Navigator.of(context).push(
              MaterialPageRoute(
                settings: const RouteSettings(name: '/campaign-task'),
                builder: (context) =>  const CampaignDetailsScreen(location: "inbox",),
              ),
            );
          }
        } else if (noticeList.type == "3") {
          var campToken = noticeList.campaignToken;
          var brandToken = noticeList.brandToken;
          var campType = noticeList.requestType;
          SharedPrefProvider.setString(
              SharedPrefProvider.campaignToken, "$campToken");
          SharedPrefProvider.setString(
              SharedPrefProvider.brandloginUniqueToken, "$brandToken");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MyCampaignDetailsScreen(index: 1,),
            ),
          );
        } else if (noticeList.type == "4") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MyEarningsScreen(location: "inbox",),
            ),
          );
        } else if (noticeList.type == "5") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MyEarningsScreen(location: "inbox",),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipOval(child: showNoticeImage(noticeList)),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(
                    moreStyle: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400),
                    text:  noticeList.message!,
                  ),
                  showNoticeCampText(noticeList),
                ],
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              noticeList.insertDate!,
              style: const TextStyle(
                  color: thirdColor, fontSize: 12.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget showNoticeImage(NotificationList noticeList) {
    if (noticeList.type == "1") {
      if (noticeList.revuerImage!.isNotEmpty) {
        return Image.network(noticeList.revuerImage!,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 40.0,
              height: 40.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 40.0,
            height: 40.0,
            child: Image.asset(
              width: 40.0,
              height: 40.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 40.0,
          height: 40.0,
          color: primaryColor,
          child: Center(
              child: Text(
            noticeList.revuerName!.isNotEmpty
                ? noticeList.revuerName![0].toUpperCase()
                : "R",
            style: const TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: "Poppins"),
          )),
        );
      }
    } else if (noticeList.type == "2") {
      if (noticeList.campaignImage!.isNotEmpty) {
        return Image.network(noticeList.campaignImage!,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 40.0,
              height: 40.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 40.0,
            height: 40.0,
            child: Image.asset(
              width: 40.0,
              height: 40.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 40.0,
          height: 40.0,
          color: primaryColor,
          child: Center(
              child: Text(
            noticeList.campaignName!.isNotEmpty
                ? noticeList.campaignName![0].toUpperCase()
                : "R",
            style: const TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: "Poppins"),
          )),
        );
      }
    } else if (noticeList.type == "3") {
      if (noticeList.campaignImage!.isNotEmpty) {
        return Image.network(noticeList.campaignImage!,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 40.0,
              height: 40.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 40.0,
            height: 40.0,
            child: Image.asset(
              width: 40.0,
              height: 40.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 40.0,
          height: 40.0,
          color: primaryColor,
          child: Center(
              child: Text(
            noticeList.campaignName!.isNotEmpty
                ? noticeList.campaignName![0].toUpperCase()
                : "R",
            style: const TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: "Poppins"),
          )),
        );
      }
    } else if (noticeList.type == "4") {
      if (noticeList.campaignImage!.isNotEmpty) {
        return Image.network(noticeList.campaignImage!,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 40.0,
              height: 40.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 40.0,
            height: 40.0,
            child: Image.asset(
              width: 40.0,
              height: 40.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 40.0,
          height: 40.0,
          color: primaryColor,
          child: Center(
              child: Text(
            noticeList.campaignName!.isNotEmpty
                ? noticeList.campaignName![0].toUpperCase()
                : "R",
            style: const TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: "Poppins"),
          )),
        );
      }
    } else if (noticeList.type == "5") {
      if (noticeList.revuerImage!.isNotEmpty) {
        return Image.network(noticeList.revuerImage!,
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 40.0,
              height: 40.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 40.0,
            height: 40.0,
            child: Image.asset(
              width: 40.0,
              height: 40.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 40.0,
          height: 40.0,
          color: primaryColor,
          child: Center(
              child: Text(
            noticeList.revuerName!.isNotEmpty
                ? noticeList.revuerName![0].toUpperCase()
                : "R",
            style: const TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: "Poppins"),
          )),
        );
      }
    } else {
      return const SizedBox();
    }
  }

  Widget showNoticeCampText(NotificationList noticeList) {
    if (noticeList.type == "1") {
      return const SizedBox();
    }
    else if (noticeList.type == "2") {
      return Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(
              noticeList.campaignName!,
              style: const TextStyle(
                  color: thirdColor,
                  fontSize: 14.0,
                  fontWeight:
                  FontWeight.w400)),
        ],
      );
    }
    else if (noticeList.type == "3") {
      return Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(
              noticeList.campaignName!,
              style: const TextStyle(
                  color: thirdColor,
                  fontSize: 14.0,
                  fontWeight:
                  FontWeight.w400)),
        ],
      );
    }
    else if (noticeList.type == "4") {
      return Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(
              noticeList.campaignName!,
              style: const TextStyle(
                  color: thirdColor,
                  fontSize: 14.0,
                  fontWeight:
                  FontWeight.w400)),
        ],
      );
    }
    else if (noticeList.type == "5") {
      return const SizedBox();
    } else {
      return const SizedBox();
    }
  }

  Widget showImage() {
    if (isApiCalled) {
      return Shimmer.fromColors(
        baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
        highlightColor: Colors.white,
        child: Container(
          width: 41.0,
          height: 41.0,
          color: Colors.grey,
        ),
      );
    } else {
      if (kDebugMode) {
        print("image url $revuerImage");
      }
      if (revuerImage.isNotEmpty) {
        return Image.network(revuerImage,
            width: 41.0,
            height: 41.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 41.0,
              height: 41.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
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
        });
      } else {
        return Container(
          width: 41.0,
          height: 41.0,
          color: primaryColor,
          child: Center(
              child: Text(
            _revuerName.isNotEmpty ? _revuerName[0].toUpperCase() : "R",
            style: const TextStyle(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                fontFamily: "Poppins"),
          )),
        ); /*Image.asset(
          'assets/images/dummy_avtar.png',
          width: 41.0,
          height: 41.0,
          fit: BoxFit.cover,
        );*/
      }
    }
  }

  Widget noInbox() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/inbox-a.png',
            width: 40.00,
            height: 40.00,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Text(
            "your inbox is empty...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "You haven’t applied in an any campaign yet...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
