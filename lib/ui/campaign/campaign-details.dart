import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/models/campaign_details_model.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/paragraph.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';
import '../main/main.dart';
import '../personal/save-personal-info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final String location;

  const CampaignDetailsScreen({Key? key, this.location = "home"})
      : super(key: key);

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  double statusBarHeight = 5.0;

  CampaignDetailsModel? data;

  int? privacyType;
  int adminApproveStatus = 0;
  String? campaignApplyType = "";
  String? checkType = "";
  String applyButtonText = "";
  String msg = "";
  var isClickButton = false;

  void _openMyPage() {
    if (widget.location == "notify") {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MainScreen(),
        ),
        (route) => false, //if you want to disable back feature set to false
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // checkCheckPrivacyPolicy();
    // checkCampaignApply(1);
    getCampaignDetails();
  }

  @override
  void dispose() {
    super.dispose();
    // _refreshController.dispose();
  }

  void checkCheckPrivacyPolicy() async {
    if (kDebugMode) {
      print(
          "campaign_token details ${await SharedPrefProvider.getString(SharedPrefProvider.campaignToken)}");
    }
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken),
    };
    if (kDebugMode) {
      print("reqParam check privacy $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiCheckPrivacyPolicy(map).then((it) {
        if (it["status"] == "SUCCESS") {
          if (mounted) {
            // Fluttertoast.showToast(msg: it["message"].toString());
            if (kDebugMode) {
              print("responseSuccess check privacy $it");
            }
            if (kDebugMode) {
              print(
                  "responseSuccess ${it["data"]["revuer_approve_status"].toString()}");
            }
            privacyType = it["data"]["type"];
            setState(() {
              adminApproveStatus = it["data"]["revuer_approve_status"];
            });
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it["status"] == "FAILURE") {
          if (mounted) {
            Fluttertoast.showToast(msg: it["message"].toString());
            if (kDebugMode) {
              print("responseFailure check privacy$it");
            }
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Something went wrong");
        }
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException check privacy$obj");
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

  void checkCampaignApply(int type) async {
    log("apply called function :- $campaignApplyType");
    log("campaign_token details ${await SharedPrefProvider.getString(SharedPrefProvider.campaignToken)}");
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken),
      "brand_token": await SharedPrefProvider.getString(
          SharedPrefProvider.brandloginUniqueToken),
      "camp_type_id": data?.campTypeId,
      "type": type
    };
    if (kDebugMode) {
      print("reqParam apply campaign $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiCampaignApply(map).then((it) {
        if (it["status"] == "SUCCESS") {
          if (mounted) {
            // Fluttertoast.showToast(msg: it["message"].toString());
            if (kDebugMode) {
              print("responseSuccess apply campaign $it");
            }
            if (kDebugMode) {
              print(
                  "responseSuccess apply campaign ${it["data"]["type"].toString()}");
            }
            setState(() {
              campaignApplyType = it["data"]["type"].toString();
              checkType = it["data"]["campaign_type"].toString();

              print("hbsdjkzcnxklmas====> ${campaignApplyType}");
              if (campaignApplyType == "1") {
                applyButtonText = "ALREADY APPLIED!";
              } else if (campaignApplyType == "2") {
                applyButtonText =
                    "Participation Request Approved"; //APPROVED BY ADMIN
              } else if (campaignApplyType == "3") {
                applyButtonText =
                    "Participation Request Declined"; //DECLINED BY ADMIN
              } else if (campaignApplyType == "5") {
                applyButtonText = "APPLY";
              } else if (campaignApplyType == "6") {
                applyButtonText = "ALREADY APPLIED!";
              } else if (campaignApplyType == "4") {
                log("apply called type :- $campaignApplyType");
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      showAccountVerifiedDialog(),
                );
                Fluttertoast.showToast(msg: it["message"].toString());
              }

              if (it["data"]["campaign_type"].toString() == "2") {
                // getCampaignDetails();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      showAppliedCampaignDialog(),
                );
              } else if (it["data"]["campaign_type"].toString() == "1") {
                Fluttertoast.showToast(msg: it["message"].toString());
              }
            });
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it["status"] == "FAILURE") {
          if (mounted) {
            Fluttertoast.showToast(msg: it["message"].toString());
            if (kDebugMode) {
              print("responseFailure apply campaign $it");
            }
            setState(() {
              isClickButton = false;
            });
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Something went wrong");
        }
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException apply campaign $obj");
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
      setState(
        () {
          isClickButton = false;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    if (kDebugMode) {
      print("campaignApplyType $campaignApplyType");
    }
    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
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
                  EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => _openMyPage(),
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                              child: Image.asset(
                                'assets/icons/back.png',
                                width: 23.0,
                                height: 23.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          /* Image.asset('assets/icons/search.png',
                                width: 22.0,
                                height: 21.0,
                                fit: BoxFit.fitWidth),*/
                        ],
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      data?.campaignName != null
                          ? Text(
                              "${data?.campaignName}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox(height: 20.0),
                    ],
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  data?.categoryName != null
                      ? Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff2A3B53)
                                        .withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 7,
                                    offset: const Offset(1, 1),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xff2A3B53)
                                        .withOpacity(0.08),
                                    spreadRadius: 0,
                                    blurRadius: 20.0,
                                    offset: const Offset(0, 0),
                                  )
                                ]),
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 50.0),
                              shrinkWrap: true,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Image.network(
                                        data!.image!,
                                        width: 78.0,
                                        height: 78.0,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return SizedBox(
                                            width: 78.0,
                                            height: 78.0,
                                            child: Image.asset(
                                              width: 60.0,
                                              height: 60.0,
                                              'assets/images/error_image.png',
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${data?.categoryName}",
                                            style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 2.0,
                                          ),
                                          Text(
                                            "${data?.camTypeName}",
                                            style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 2.0),
                                            child: Image.asset(
                                                'assets/icons/wallet.png',
                                                width: 19.0,
                                                height: 19.0,
                                                fit: BoxFit.fitWidth),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Earn UpTo",
                                                  style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 2.0,
                                                ),
                                                Text(
                                                  "\u{20B9}${data?.earnUpto}",
                                                  style: const TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 32.0,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/icons/compaign.png',
                                          width: 24.75,
                                          height: 20.0,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Campaign Objective",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(height: 10.0),
                                              ParagraphText(
                                                moreStyle: const TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                text: "${data?.campaignObj}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          'assets/icons/task.png',
                                          width: 20.01,
                                          height: 25.87,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Tasks",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(height: 10.0),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: data!
                                                      .campaignTaskNames!
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Text(
                                                        "Task ${entry.key + 1}: ${entry.value}",
                                                        style: const TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    data!.dos![0] != ""
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/icons/check.png',
                                                width: 20.0,
                                                height: 20.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Do’s",
                                                      style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: data!.dos!
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          log("map entry: $entry");
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                /*Image.asset(
                                                                  'assets/icons/like.png',
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8.0,
                                                                ),*/
                                                                Expanded(
                                                                  child:
                                                                      ParagraphText(
                                                                    moreStyle: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    text: entry
                                                                        .value,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        }).toList()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    data!.donts![0] != ""
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/icons/close.png',
                                                width: 20.0,
                                                height: 20.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Don’ts",
                                                      style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: data!.donts!
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          return Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                /*Image.asset(
                                                                  'assets/icons/unlike.png',
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8.0,
                                                                ),*/
                                                                Expanded(
                                                                  child:
                                                                      ParagraphText(
                                                                    moreStyle: const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                    text: entry
                                                                        .value,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          );
                                                        }).toList()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    data?.additionals != ""
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/icons/compaign.png',
                                                width: 24.75,
                                                height: 20.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Additional Details",
                                                      style: TextStyle(
                                                          color: secondaryColor,
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    const SizedBox(
                                                        height: 10.0),
                                                    ParagraphText(
                                                      moreStyle:
                                                          const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                      text:
                                                          "${data?.additionals}",
                                                    ),
                                                    const SizedBox(
                                                      height: 10.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(
                                            height: 0.0,
                                          ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icons/star.png',
                                                width: 20.0,
                                                height: 20.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                data!.revuerLimit!,
                                                style: const TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              const Text(
                                                "Revuers Approved",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 30.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/icons/clock.png',
                                                width: 20.0,
                                                height: 20.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                "${data!.totaldays!} Days",
                                                style: const TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              const Text(
                                                "Campaign Days Left",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20.0,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                          color: primaryColor,
                        ))
                ],
              ),
            ),
            adminApproveStatus == 1
                ? campaignApplyType == "0" || checkType == "1"
                    ? Positioned(
                        bottom: 24.0,
                        left: 16.0,
                        right: 16.0,
                        child: IgnorePointer(
                          ignoring: isClickButton,
                          child: (!isClickButton)
                              ? ButtonWidget(
                                  buttonText: "APPLY",
                                  onPressed: () {
                                    setState(
                                      () {
                                        isClickButton = true;
                                      },
                                    );
                                    if (kDebugMode) {
                                      print("privacyType $privacyType");
                                    }
                                    checkCampaignApply(0);
                                  })
                              : Container(
                                  height: 48,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: primaryColor,
                                  ),
                                  child: const SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 27.0,
                                  ),
                                ),
                        ),
                      )
                    : Positioned(
                        bottom: 24.0,
                        left: 16.0,
                        right: 16.0,
                        child: SizedBox(
                          height: 48,
                          child: ButtonWidget(
                              buttonText: applyButtonText,
                              buttonColor: primaryLightColor,
                              onPressed: () {}),
                        ),
                      )
                : data?.categoryName != null
                    ? Positioned(
                        bottom: 24.0,
                        left: 16.0,
                        right: 16.0,
                        child: ButtonWidget(
                            buttonText: "APPLY",
                            buttonColor: primaryLightColor,
                            onPressed: () {}),
                      )
                    : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget showAppliedCampaignDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: CustomDialog(
        Child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/icons/applied.png',
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  const Text(
                    "Your application is successfully submitted for review...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "We will notify you as soon as possible",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: thirdColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  ButtonWidget(
                      buttonText: "OK",
                      onPressed: () {
                        getCampaignDetails();
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showAccountVerifiedDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: CustomDialog(
        Child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/icons/applied.png',
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  const Text(
                    "Your Profile is still incomplete!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "To participate in this campaign you must fill address and other details in your profile so that we can better interact with brands.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: thirdColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  ButtonWidget(
                      buttonText: "COMPLETE",
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) =>
                                    const SavePersonalInfoScreen()))
                            .then((value) {
                          log("apply called return screen then called :- $campaignApplyType");
                          getCampaignDetails();
                        });
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCampaignDetails() async {
    Map<String, dynamic> body = {
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken)
    };
    log("reqParam campaign details $body");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetCampaignDetails(body).then((it) {
        if (it.status == "SUCCESS") {
          if (mounted) {
            // Fluttertoast.showToast(msg: it["message"].toString());
            log("responseSuccess campaign details$it");
            var realData = DataEncryption.getDecryptedData(
                it.data!.reqKey.toString(), it.data!.reqData.toString());
            log("real data details data ${jsonEncode(realData)}");
            setState(() {
              data = CampaignDetailsModel.fromJson(realData);
            });
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          if (mounted) {
            Fluttertoast.showToast(msg: it.message.toString());
            log("responseFailure campaign details$it");
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Something went wrong");
        }
        // non-200 error goes here.
        log("responseException campaign details $obj");
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
    checkCheckPrivacyPolicy();
    print("asjkdbvxchbjnzxck nv=========>>>>>>>> 2");
    checkCampaignApply(1);
  }
}
