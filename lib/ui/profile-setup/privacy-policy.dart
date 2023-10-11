import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/ui/main/main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final String location;
  final int patmentMethod;

  const PrivacyPolicyScreen(
      {Key? key, this.patmentMethod = 1, required this.location})
      : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;
  bool isApiCalled = false;
  String htmlData = "";
  bool isChecked = true;

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/social-profiles');
    /* Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/payment-mode-profile'),
        builder: (context) => PaymentModeProfileScreen(
            location: "paymentModeProfile",
            patmentMethod: widget.patmentMethod),
      ),
    );*/
  }

  void getPrivacyPolicy(BuildContext context) async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "campaign_token": await SharedPrefProvider.getString(
          SharedPrefProvider.campaignToken), //from share preference
      "brandlogin_unique_token": await SharedPrefProvider.getString(
          SharedPrefProvider.brandloginUniqueToken), //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiPrivacyPolicy(map).then((it) {
        if (it.status == "SUCCESS") {
          Fluttertoast.showToast(msg: it.message.toString());
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => showPrivacyDialog(),
          );
          print("responseSuccess ${it}");
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          print("responseFailure $it");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseFailure ${obj}");
        switch (obj.runtimeType) {
          case DioError:
            // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            print("status ${res?.statusCode}");
            print("status ${res?.statusMessage}");
            print("status ${res?.data}");
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
    getPrivacyPolicyData();
    super.initState();
  }

  getPrivacyPolicyData() async {
    setState(() {
      isApiCalled = true;
    });
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetPrivacyPolicy().then((it) {
        if (it["status"] == "SUCCESS") {
          setState(() {
            isApiCalled = false;
          });
          htmlData = it["data"]["content"];
          printMsg("responseSuccess $it");
        } else if (it["status"] == "FAILURE") {
          toastMsg(it["message"].toString());
          printMsg("responseFailure $it");
        }
      }).catchError((Object obj) {
        toastMsg("Something went wrong");
        // non-200 error goes here.
        printMsg("responseException $obj");
        switch (obj.runtimeType) {
          case DioError:
            // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            printMsg("status ${res?.statusCode}");
            printMsg("status ${res?.statusMessage}");
            printMsg("status ${res?.data}");
            break;
          default:
            break;
        }
      });
    } else {
      toastMsg("No Internet Available");
    }
  }

  toastMsg(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  printMsg(String msg) {
    if (kDebugMode) {
      print(msg);
    }
  }

  FutureOr<bool> openUrl(String url) async {
    try {
      printMsg("url is:$url");
      if (!await launchUrl(Uri.parse(url))) {
        throw 'Could not launch $url';
      }
      return true;
    } catch (error) {
      printMsg("url is error :$error");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      return primaryColor;
    }

    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
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
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _openMyPage(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                      child: Image.asset(
                        'assets/icons/back.png',
                        width: 23.0,
                        height: 23.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    Strings.privacyPolicy,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 80.0),
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
                      child: SingleChildScrollView(
                        child: isApiCalled
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : SingleChildScrollView(
                                child: Center(
                                  child: HtmlWidget(
                                    // the first parameter (`html`) is required
                                    htmlData,
                                    onTapUrl: (url) => openUrl(url),
                                    isSelectable: true,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 24.0,
              left: 16.0,
              right: 16.0,
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/social-profiles');
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                color: thirdColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ButtonWidget(
                          buttonText: "AGREE",
                          onPressed: () {
                            if (!isChecked) {
                              Fluttertoast.showToast(
                                  msg: "Please accept Privacy policy and T&c");
                            } else {
                              getPrivacyPolicy(context);
                            }
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showPrivacyDialog() {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: CustomDialog(
        Child: Stack(
          children: [
            Positioned(
              right: 19.0,
              top: 19.0,
              child: InkWell(
                onTap: () => Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => MainScreen(),
                  ),
                  (route) =>
                      false, //if you want to disable back feature set to false
                ),
                child: Image.asset(
                  'assets/icons/close2.png',
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    width: 90.0,
                    height: 90.0,
                    decoration: const BoxDecoration(
                      color: primaryColorAlpha1,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/check-dark.png',
                        width: 28.8,
                        height: 30.6,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  const Text(
                    "Your profile is  complete!\nIt's successfully submitted for review...",
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
