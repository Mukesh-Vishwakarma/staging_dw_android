import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/src/oval_clipper.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/textfield_widget.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double statusBarHeight = 5.0;

  void _openMyPage() {
    Navigator.of(context).pop();
  }

  final emojiRegex =
      '(\ud83c|[\udf00-\udfff]|\ud83d|[\udc00-\ude4f]|\ud83d|[\ude80-\udeff])';
  final _formKey1 = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();

  String? name = "";
  String? email = "";
  String? phone = "";

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
                  EdgeInsets.fromLTRB(0.0, (statusBarHeight + 15.0), 0.0, 5),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          Strings.helpSupport,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Column(
                          children: [
                            Container(
                              /*margin: const EdgeInsets.only(bottom: 80.0),*/
                              margin: const EdgeInsets.only(bottom: 20.0),
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
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: [
                                  Form(
                                    key: _formKey1,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          validator: (value) {
                                            if (value!
                                                .toString()
                                                .trim()
                                                .isEmpty) {
                                              return Strings.requiredStr;
                                            } else if (value
                                                .contains(RegExp(emojiRegex))) {
                                              return "Emojis not acceptable";
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                          textCaps:
                                              TextCapitalization.sentences,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          textController: nameController,
                                          placeholder: 'Name',
                                          maxLength: 256,
                                          onChanged: (value) {
                                            name = value;
                                          },
                                        ),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textController: phoneNoController,
                                          isImg: true,
                                          isSuffixImg: true,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Phone',
                                          digitOnly: true,
                                          keyboardType: TextInputType.number,
                                          maxLength: 10,
                                          onChanged: (value) {
                                            phone = value;
                                          },
                                          validator: (value) {
                                            if (value!
                                                .toString()
                                                .trim()
                                                .isEmpty) {
                                              return Strings.requiredStr;
                                            } else if (value
                                                    .toString()
                                                    .trim()
                                                    .length <
                                                10) {
                                              return "* Please enter a valid number";
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textController: emailController,
                                          isSuffixImg: true,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Email',
                                          maxLength: 256,
                                          onChanged: (value) {
                                            email = value;
                                          },
                                          validator: (value) {
                                            if (value!
                                                .toString()
                                                .trim()
                                                .isEmpty) {
                                              return Strings.requiredStr;
                                            } else if (!RegExp(
                                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                                .hasMatch(value)) {
                                              return 'Please enter a valid Email';
                                            } else {
                                              return null;
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        ButtonWidget(
                                          buttonContent: const Text(
                                            "SEND MESSAGE",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.0),
                                          ),
                                          onPressed: () {
                                            if (_formKey1.currentState!
                                                .validate()) {
                                            } else {
                                              heavyImpact();
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Please fill all required fields");
                                            }
                                            //Navigator.pushReplacementNamed(context, '/social-profiles');
                                          },
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        const Text(
                                          "Get to know us better!",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                                "assets/images/facebook.png",width: 35,height: 35,),
                                            const SizedBox(width: 16,),
                                            const Text(
                                              "Never miss a review",
                                              style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),

                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/images/facebook.png",width: 35,height: 35,),
                                            const SizedBox(width: 16,),
                                            const Expanded(
                                              child: Text(
                                                "Follow for latest contests and campaigns",
                                                style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),

                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/images/facebook.png",width: 35,height: 35,),
                                            const SizedBox(width: 16,),
                                            const Text(
                                              "Watch our in-depth review videos",
                                              style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),

                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/images/facebook.png",width: 35,height: 35,),
                                            const SizedBox(width: 16,),
                                            const Expanded(
                                              child: Text(
                                                "Join our community of awesome mums!",
                                                style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),

                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/images/facebook.png",width: 35,height: 35,),
                                            const SizedBox(width: 16,),
                                            InkWell(
                                              onTap: (){
                                                browseInternet('mailto:mishryreviews@gmail.com');
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: const [
                                                  Text("Write to us at", style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),),
                                                  Text("mishryreviews@gmail.com", style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12.0,
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
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> heavyImpact() async {
    await SystemChannels.platform.invokeMethod<void>('HapticFeedback.vibrate');
  }
}
