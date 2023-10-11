import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';

class PrivacyPolicyTcScreen extends StatefulWidget {
  const PrivacyPolicyTcScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyTcScreen> createState() => _PrivacyPolicyTcScreenState();
}

class _PrivacyPolicyTcScreenState extends State<PrivacyPolicyTcScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;
  bool isApiCalled = false;
  String htmlData = "";

  void _openMyPage() {
    Navigator.of(context).pop();
    /*Navigator.of(context)
        .pushNamedAndRemoveUntil('/profile', (Route<dynamic> route) => false);*/
    //Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  void initState() {
    getPrivacyPolicy();
    super.initState();
  }

  getPrivacyPolicy() async {
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
                  EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
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
                    height: 24.0,
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
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text(
                              "Privacy Policy",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10.0,),
                            Text(
                              "Nec cursus tristique convallis in justo. Etiam porttitor sed egestas ornare porttitor risus nisl ac. Eget nunc hac vitae viverra massa. Lectus sem egestas facilisis tristique quis proin feugiat. Blandit tincidunt augue dui, at nam nunc. Diam phasellus mi hac sed. Tempor, sed fermentum in dolor sit blandit tincidunt donec. Iaculis sagittis, iaculis dictum libero, amet ornare adipiscing lectus lorem. Scelerisque neque gravida etiam neque nibh diam id.",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            SizedBox(height: 15.0,),
                            Text(
                              "Terms and Conditions",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10.0,),
                            Text(
                              "Nec cursus tristique convallis in justo. Etiam porttitor sed egestas ornare porttitor risus nisl ac. Eget nunc hac vitae viverra massa. Lectus sem egestas facilisis tristique quis proin feugiat. Blandit tincidunt augue dui, at nam nunc. ",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 24.0,),
                            Text(
                              "Porta nisl risus amet, duis. Faucibus gravida risus, aenean mi, neque. Auctor arcu, consectetur integer tincidunt interdum. Ut nulla ut amet nibh nulla dolor, mauris, sit lacinia. Faucibus fames nulla non sem faucibus netus vulputate cras. Lectus sem egestas facilisis tristique quis proin feugiat",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            SizedBox(height: 24.0,),
                            Text(
                              "Tincidunt purus consequat nam quis. Tortor tempus, et eget pellentesque id nam. Porta aliquet varius sem lectus odio at eu. Mattis iaculis quisque eget mauris aliquet. Tortor mattis eget rhoncus erat sed ac. ",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),



                          ],
                        )*/
