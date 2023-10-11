import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/analytics_data_model.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  double statusBarHeight = 5.0;

  bool isApiCalled = false;
  bool isAnalyticsApiCalled = false;
  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();
  String revuerImage = "";
  var _revuerName = "";

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

  AnalyticsDataModel analyticsDataModel = AnalyticsDataModel();

  getAnalytics() async {
    setState(() {
      isAnalyticsApiCalled = true;
    });
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    if (kDebugMode) {
      print("requestParam analytics $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetAnalytics(map).then((it) {
        setState(() {
          isAnalyticsApiCalled = false;
        });
        if (it.status == "SUCCESS") {
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          analyticsDataModel = AnalyticsDataModel.fromJson(realData);
          if (kDebugMode) {
            print("real data analytics $realData");
          }
          if (kDebugMode) {
            print("responseSuccess analytics $it");
          }
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure analytics $it");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          isAnalyticsApiCalled = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException analytics $obj");
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
    getAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
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
            padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 8.0), 16.0, 10),
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
                            child: showImage() /*Image.asset(
                              'assets/images/dummy_avtar.png',
                              width: 41.0,
                              height: 41.0,
                              fit: BoxFit.cover,
                            )*/,
                          ),
                        ),
                        /* Image.asset('assets/icons/search.png',
                            width: 22.0, height: 21.0, fit: BoxFit.fitWidth),*/
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    const Text(
                      Strings.earnings,
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
                isAnalyticsApiCalled
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
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
                                            .withOpacity(0.04),
                                        spreadRadius: 0,
                                        blurRadius: 9.0,
                                        offset: const Offset(0, 0),
                                      )
                                    ]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 32.0, horizontal: 25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/icons/2Xwallet.png',
                                                width: 32.0,
                                                height: 32.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              const Text(
                                                "My Earnings",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400),
                                              )
                                            ],
                                          ),
                                          const SizedBox(width: 20,),
                                          Text(
                                            analyticsDataModel.earningAmount != null
                                                ? "\u{20B9}${analyticsDataModel.earningAmount}"
                                                :"N/A",
                                            style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 16,right: 16),
                                      height: 1,color: grayColor,),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 25.0, horizontal: 25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/icons/2Xreview.png',
                                                width: 32.0,
                                                height: 32.0,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(
                                                width: 10.0,
                                              ),
                                              const Text(
                                                "My Ranking",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400),
                                              )
                                            ],
                                          ),
                                          Text(
                                            analyticsDataModel.rank == null && analyticsDataModel.rank == 0
                                                ? "N/A"
                                                : "#${analyticsDataModel.rank}",
                                            style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              /*Container(
                                margin: const EdgeInsets.only(bottom: 20.0),
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
                                            .withOpacity(0.04),
                                        spreadRadius: 0,
                                        blurRadius: 9.0,
                                        offset: const Offset(0, 0),
                                      )
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32.0, horizontal: 25.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/icons/2Xreview.png',
                                            width: 32.0,
                                            height: 32.0,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          const Text(
                                            "My Ranking",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w400),
                                          )
                                        ],
                                      ),
                                      Text(
                                        analyticsDataModel.rank == 0
                                            ? "N/A"
                                            : "#${analyticsDataModel.rank}",
                                        style: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                              const Text(
                                "Leaderboard",
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Expanded(
                                      child:analyticsDataModel.leaderboardData != null && analyticsDataModel.leaderboardData!.isNotEmpty
                                          ? ListView.separated(
                                          itemCount: analyticsDataModel
                                              .leaderboardData!.length,
                                          shrinkWrap: true,
                                          padding:
                                              const EdgeInsets.only(bottom: 12.0),
                                          separatorBuilder:
                                              (BuildContext context, int index) =>
                                                  const Divider(
                                                    height: 1,
                                                    color: grayColor,
                                                  ),
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 15.0),
                                              decoration: BoxDecoration(
                                                  gradient: getCardColor(analyticsDataModel.leaderboardData![index].rank!),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10.0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          const Color(0xff2A3B53)
                                                              .withOpacity(0.08),
                                                      spreadRadius: 0,
                                                      blurRadius: 7,
                                                      offset: const Offset(1, 1),
                                                    ),
                                                    BoxShadow(
                                                      color:
                                                          const Color(0xff2A3B53)
                                                              .withOpacity(0.08),
                                                      spreadRadius: 0,
                                                      blurRadius: 20.0,
                                                      offset: const Offset(0, 0),
                                                    )
                                                  ]),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        getBagIcon(analyticsDataModel.leaderboardData![index].rank!),
                                                        /*Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                        child: Image.asset(
                                                          'assets/icons/money-bag.png',
                                                          width: 22.0,
                                                          height: 30.0,
                                                          fit: BoxFit.contain,
                                                          color: cdColor1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),*/
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Text(
                                                          "${analyticsDataModel.leaderboardData![index].firstName} ${analyticsDataModel.leaderboardData![index].lastName}",
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 20,),
                                                    Expanded(
                                                      child: Text(
                                                        "\u{20B9}${analyticsDataModel.leaderboardData![index].earningAmount}",
                                                        textAlign: TextAlign.end,
                                                        style: TextStyle(
                                                          color:
                                                              getTextColor(analyticsDataModel.leaderboardData![index].rank!),
                                                          fontSize: 19.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          })
                                          : noRank()
                                      /*child: ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                      18.0, 16.0, 18.0, 0.0),
                                  shrinkWrap: true,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15.0),
                                      decoration: BoxDecoration(
                                          gradient: cdGradient1,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff2A3B53)
                                                  .withOpacity(0.08),
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: Image.asset(
                                                        'assets/icons/money-bag.png',
                                                        width: 22.0,
                                                        height: 30.0,
                                                        fit: BoxFit.contain,
                                                        color: cdColor1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20.0,
                                                ),
                                                 Text(
                                                  "${analyticsDataModel.leaderboardData![0].firstName} ${analyticsDataModel.leaderboardData![0].lastName}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                             Text(
                                              "\u{20B9}${analyticsDataModel.leaderboardData![0].earningAmount}",
                                              style: const TextStyle(
                                                color: cdColor1,
                                                fontSize: 19.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15.0),
                                      decoration: BoxDecoration(
                                          gradient: cdGradient2,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff2A3B53)
                                                  .withOpacity(0.08),
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: Image.asset(
                                                        'assets/icons/money-bag.png',
                                                        width: 22.0,
                                                        height: 30.0,
                                                        fit: BoxFit.contain,
                                                        color: cdColor2,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: Image.asset(
                                                        'assets/icons/money-bag.png',
                                                        width: 22.0,
                                                        height: 30.0,
                                                        fit: BoxFit.contain,
                                                        color: cdColor2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20.0,
                                                ),
                                                 Text(
                                                  "${analyticsDataModel.leaderboardData![1].firstName} ${analyticsDataModel.leaderboardData![1].lastName}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                             Text(
                                              "\u{20B9}${analyticsDataModel.leaderboardData![1].earningAmount}",
                                              style: const TextStyle(
                                                color: cdColor2,
                                                fontSize: 19.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15.0),
                                      decoration: BoxDecoration(
                                          gradient: cdGradient3,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff2A3B53)
                                                  .withOpacity(0.08),
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: Image.asset(
                                                        'assets/icons/money-bag.png',
                                                        width: 22.0,
                                                        height: 30.0,
                                                        fit: BoxFit.contain,
                                                        color: cdColor3,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: Image.asset(
                                                        'assets/icons/money-bag.png',
                                                        width: 22.0,
                                                        height: 30.0,
                                                        fit: BoxFit.contain,
                                                        color: cdColor3,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: Image.asset(
                                                        'assets/icons/money-bag.png',
                                                        width: 22.0,
                                                        height: 30.0,
                                                        fit: BoxFit.contain,
                                                        color: cdColor3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20.0,
                                                ),
                                                const Text(
                                                  "Divya Shah",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Text(
                                              "\u{20B9}13,000",
                                              style: TextStyle(
                                                color: cdColor3,
                                                fontSize: 19.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),*/
                                      )
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
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
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
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
            },
            errorBuilder: (context, error, stackTrace) {
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

  Gradient getCardColor(int rank) {
    if (rank == 1) {
      return cdGradient1;
    } else if (rank == 2) {
      return cdGradient2;
    } else {
      return cdGradient3;
    }
  }

  Color getTextColor(int rank) {
    if (rank == 1) {
      return cdColor1;
    } else if (rank == 2) {
      return cdColor2;
    } else {
      return cdColor3;
    }
  }

  Widget getBagIcon(int rank) {
    if (rank == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/icons/money-bag.png',
              width: 22.0,
              height: 30.0,
              fit: BoxFit.contain,
              color: cdColor1,
            ),
          ),
        ],
      );
    } else if (rank == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/icons/money-bag.png',
              width: 22.0,
              height: 30.0,
              fit: BoxFit.contain,
              color: cdColor2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/icons/money-bag.png',
              width: 22.0,
              height: 30.0,
              fit: BoxFit.contain,
              color: cdColor2,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/icons/money-bag.png',
              width: 22.0,
              height: 30.0,
              fit: BoxFit.contain,
              color: cdColor3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/icons/money-bag.png',
              width: 22.0,
              height: 30.0,
              fit: BoxFit.contain,
              color: cdColor3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/icons/money-bag.png',
              width: 22.0,
              height: 30.0,
              fit: BoxFit.contain,
              color: cdColor3,
            ),
          ),
        ],
      );
    }
  }

  Widget noRank() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/2Xreview.png',
            width: 40.00,
            height: 40.00,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Text(
            "No ranking available..",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          /*const SizedBox(height: 10.0),
          const Text(
            "You haven't any active campaign in your account...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),*/
        ],
      ),
    );
  }

}
