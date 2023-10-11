import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../personal/save-personal-info.dart';

class ProfileScreen extends StatefulWidget {
  final String location;

  const ProfileScreen({Key? key, this.location = ""}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double statusBarHeight = 5.0;

  String _revuerName = "N/A";
  String _revuerMobile = "N/A";
  String _revuerImage = "";
  bool isApiCalled = true;

  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();

  var appVersion = "";

  browseInternet(String url) async {
    try {
      if (kDebugMode) {
        print("url is:$url");
      }
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        print("url is error :$error");
      }
    }
  }

  List<Map<String, Object>> cat = [
    {
      "category": "General Info",
      "subCategory": [
        /* {
          "imgIcon": "assets/icons/2Xreview.png",
          "title": "Leaderboard Rank",
          */ /*"link": ""*/ /*
          "link": "/coming-soon"
        },*/
        {
          "imgIcon": "assets/icons/interests.png",
          "title": "Interests",
          "link": "/interests"
        },
        {
          "imgIcon": "assets/icons/share.png",
          "title": "Social Media Accounts",
          "link": "/social-account"
        },
      ],
    },
    {
      "category": "Payment Details",
      "subCategory": [
        {
          "imgIcon": "assets/icons/wallet.png",
          "title": "My Earnings",
          "link": "/earning-history"
          // "link": "/coming-soon"
        },
        {
          "imgIcon": "assets/icons/withdraw.png",
          "title": "Withdraw Earnings",
          "link": "/withdraw-earnings"
          // "link": "/coming-soon"
        },
        {
          "imgIcon": "assets/icons/refer.png",
          "title": "Refer & Earn",
          "link": "/refer-earn-screen"
        },
      ],
    },
    {
      "category": "Settings & Preferences",
      "subCategory": [
        /* {
          "imgIcon": "assets/icons/notification.png",
          "title": "Notification",
          */ /*"link": ""*/ /*
          "link": "/coming-soon"
        },*/
        {
          "imgIcon": "assets/icons/term.png",
          "title": "Privacy Policy and T&C",
          // "link": "/privacy-policy"
          "link": "/privacy-policy-tc"
        },
        {
          "imgIcon": "assets/icons/help.png",
          "title": "Help and Support",
          "link": "openUrl"
          // "link": "/help_support"
        },
        {
          "imgIcon": "assets/icons/star.png",
          "title": "Rate Now",
          "link": "rateNow"
          // "link": "/help_support"
        },
      ],
    },
  ];

  void _openMyPage() {
    if (widget.location == "home") {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  getPrefData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    final token =
        await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken);
    final mobile =
        await SharedPrefProvider.getString(SharedPrefProvider.mobileNumber);
    final profileImage =
        await SharedPrefProvider.getString(SharedPrefProvider.profileImage);
    final fullName =
        await SharedPrefProvider.getString(SharedPrefProvider.fullName);
    /*setState(() {
      if (fullName == " ") {
        _userName = Strings.appName;
      } else {
        _userName = fullName!;
      }

      if (mobile == ""
          "") {
        _userMobile = "N/A";
      } else {
        _userMobile = mobile!;
      }

    });
    print(
        "mobile $mobile  token $token profileImage $profileImage fullName $fullName");*/
  }

  getRevuerDetails() async {
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    if (kDebugMode) {
      print("requestParam profile $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          revuerDetailsModel = RevuerDetailsModel.fromJson(realData);

          if (revuerDetailsModel.revuerData!.firstName == "" ||
              revuerDetailsModel.revuerData!.firstName == null) {
            _revuerName = Strings.appName;
          } else {
            setState(() {
              _revuerName =
                  "${revuerDetailsModel.revuerData!.firstName!.replaceFirst(revuerDetailsModel.revuerData!.firstName![0], revuerDetailsModel.revuerData!.firstName![0].toUpperCase())} ${revuerDetailsModel.revuerData!.lastName!.replaceFirst(revuerDetailsModel.revuerData!.lastName![0], revuerDetailsModel.revuerData!.lastName![0].toUpperCase())}";
            });
          }

          if (revuerDetailsModel.revuerData!.image == "" ||
              revuerDetailsModel.revuerData!.image == null) {
            _revuerImage = "";
          } else {
            setState(() {
              _revuerImage = revuerDetailsModel.revuerData!.image!;
            });
          }

          if (revuerDetailsModel.revuerData?.mobileNo == null) {
            _revuerMobile = "N/A";
          } else {
            setState(() {
              _revuerMobile =
                  revuerDetailsModel.revuerData!.mobileNo!.toString();
            });
          }

          if (kDebugMode) {
            print("real data $realData");
          }
          if (kDebugMode) {
            print("responseSuccess $it");
          }
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          isApiCalled = false;
        });
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

  @override
  void initState() {
    super.initState();
    getPrefData();
    getRevuerDetails();
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
                  EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                          /*Image.asset('assets/icons/search.png',
                              width: 22.0, height: 21.0, fit: BoxFit.fitWidth),*/
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Text(
                        Strings.profile,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 18.0),
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
                                color:
                                    const Color(0xff2A3B53).withOpacity(0.04),
                                spreadRadius: 0,
                                blurRadius: 9.0,
                                offset: const Offset(0, 0),
                              )
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipOval(child: showImage()),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                const SavePersonalInfoScreen()))
                                        .then((value) => getRevuerDetails()),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _revuerName,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          _revuerMobile,
                                          style: const TextStyle(
                                              color: secondaryColor,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/2Xreview.png',
                                    width: 20.0,
                                    height: 20.02,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                    revuerDetailsModel.revuerData?.rank ==
                                                null ||
                                            revuerDetailsModel
                                                    .revuerData!.rank ==
                                                0
                                        ? "N/A"
                                        : "#${revuerDetailsModel.revuerData!.rank}",
                                    style: const TextStyle(
                                      color: secondaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 25.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 25.0),
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
                      child: ListView.separated(
                          itemCount: cat.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(
                                height: 24.0,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            final subCategory =
                                cat[index]["subCategory"] as List;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat[index]['category'].toString(),
                                  style: const TextStyle(
                                      color: secondaryColor,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                ListView.separated(
                                    itemCount: subCategory.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(
                                              height: 1,
                                              color: grayColor,
                                            ),
                                    itemBuilder: (BuildContext context, int i) {
                                      return InkWell(
                                        onTap: () async {
                                          if (subCategory[i]["link"] != "") {
                                            if (subCategory[i]["link"] ==
                                                "openUrl") {
                                              browseInternet(
                                                  "https://mishry.com/contact-us");
                                            } else if (subCategory[i]["link"] ==
                                                "rateNow") {
                                              PackageInfo packageInfo =
                                                  await PackageInfo
                                                      .fromPlatform();
                                              if (Platform.isAndroid ||
                                                  Platform.isIOS) {
                                                final appId = Platform.isAndroid
                                                    ? revuerDetailsModel
                                                        .android!.link!
                                                    : revuerDetailsModel
                                                        .iOS!.ios_link!;
                                                final url = Uri.parse(
                                                  Platform.isAndroid
                                                      ? appId
                                                      : appId,
                                                );
                                                launchUrl(
                                                  url,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            } else {
                                              Navigator.pushNamed(context,
                                                  subCategory[i]["link"]);
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                      subCategory[i]["imgIcon"],
                                                      width: 20.0,
                                                      height: 20.2,
                                                      fit: BoxFit.contain),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    subCategory[i]["title"]
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Icon(
                                                  Icons.arrow_forward_ios_sharp,
                                                  size: 18.0,
                                                  color: secondaryColor),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            );
                          }),
                    ),
                  ),
                  Center(
                      child: appVersion.isNotEmpty
                          ? Text(
                              "Revuer v$appVersion by Mishry",
                              style: const TextStyle(color: secondaryColor),
                            )
                          : const SizedBox())
                ],
              ),
            ),
          ],
        ),
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
        print("image url $_revuerImage");
      }
      if (_revuerImage.isNotEmpty) {
        return Image.network(_revuerImage,
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
            _revuerName[0].toUpperCase(),
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
}
