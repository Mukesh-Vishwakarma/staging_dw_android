import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:revuer/networking/models/campaign_details_model.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/paragraph.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';

class MyCampaignDetailsPendingScreen extends StatefulWidget {
  const MyCampaignDetailsPendingScreen({Key? key}) : super(key: key);
  @override
  State<MyCampaignDetailsPendingScreen> createState() =>
      _MyCampaignDetailsPendingScreenState();
}

class _MyCampaignDetailsPendingScreenState
    extends State<MyCampaignDetailsPendingScreen> {
  double statusBarHeight = 5.0;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  CampaignDetailsModel? data;

  void _openMyPage() {
    Navigator.of(context).pop();
   /* Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => MainScreen(index: 1),
      ),
      (route) => false, //if you want to disable back feature set to false
    );*/
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
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  "Earn Upto",
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
                                                moreStyle: const TextStyle(color: secondaryColor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400), text: "${data?.campaignObj}",
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
                                    data!.dos![0] == ""? const SizedBox():Row(
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
                                              const SizedBox(height: 10.0),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: data!.dos!
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                         /* Image.asset(
                                                            'assets/icons/like.png',
                                                            width: 20.0,
                                                            height: 20.0,
                                                            fit: BoxFit.contain,
                                                          ),
                                                          const SizedBox(
                                                            width: 8.0,
                                                          ),*/
                                                          Expanded(
                                                            child:
                                                                ParagraphText(
                                                              moreStyle: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400), text: entry.value,
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
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    data!.donts![0] == ""? const SizedBox():Row(
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
                                              const SizedBox(height: 10.0),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: data!.donts!
                                                      .asMap()
                                                      .entries
                                                      .map((entry) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          /*Image.asset(
                                                            'assets/icons/unlike.png',
                                                            width: 20.0,
                                                            height: 20.0,
                                                            fit: BoxFit.contain,
                                                          ),
                                                          const SizedBox(
                                                            width: 8.0,
                                                          ),*/
                                                          Expanded(
                                                            child:
                                                                ParagraphText(
                                                              moreStyle: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400), text: entry.value,
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
                                    ),
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
                                                                      .w400), text: "${data?.additionals}",
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
            data?.categoryName != null
                ? Positioned(
                    bottom: 24.0,
                    left: 16.0,
                    right: 16.0,
                    child: SizedBox(
                      height: 48,
                      child: ButtonWidget(
                          buttonText: "ALREADY APPLIED!",
                          buttonColor: primaryLightColor,
                          onPressed: () {}),
                    ),
                  )
                : const SizedBox()
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

    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetCampaignDetails(body).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it["message"].toString());
          log("responseSuccess $it");
          log("responseSuccess ${it.data.toString()}");
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          log("details data ${realData.toString()}");
          setState(() {
            data = CampaignDetailsModel.fromJson(realData);
          });
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          log("responseFailure $it");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        log("responseFailure $obj");
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
}
