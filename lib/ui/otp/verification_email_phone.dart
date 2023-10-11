import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/DataEncryption.dart';

import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import 'lib/otp_text_field.dart';

class VerificationEmailPhoneScreen extends StatefulWidget {
  String location;
  String emailPhone;

  VerificationEmailPhoneScreen(
      {Key? key, this.emailPhone = '', required this.location})
      : super(key: key);

  @override
  State<VerificationEmailPhoneScreen> createState() =>
      _VerificationEmailPhoneScreenState();
}

class _VerificationEmailPhoneScreenState
    extends State<VerificationEmailPhoneScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool clearText = false;
  bool isApiCalled = false;
  void _openMyPage() {
    Navigator.of(context).pop();
  }

  late Timer _timer;
  int _start = 25;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          print("timer if");
          setState(() {
            print("timer stopped");
            timer.cancel();
          });
        } else {
          print("timer else");
          setState(() {
            print("timer minus");
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  verifyEmailOtp(int type, String otp, String email) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": type,
      "email": email,
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "otp": int.parse(otp),
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient()
          .apiEmailVerify(DataEncryption.getEncryptedData(map))
          .then((it) {
        if (it.status == "SUCCESS") {
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          print("real data $realData");
          Fluttertoast.showToast(msg: it.message.toString());
          Navigator.of(context).pop();
          /*SharedPrefProvider.setString(
              SharedPrefProvider.uniqueToken, realData["revuer_token"]);
          SharedPrefProvider.setString(SharedPrefProvider.mobileNumber,
              realData["mobile_no"].toString());
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              "${realData["first_name"]} ${realData["last_name"]}");
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          widget.location == "signup"
              ? Navigator.pushReplacementNamed(context, '/personalinfo')
              : Navigator.pushReplacementNamed(context, '/main');

          Map<String, dynamic> trendingBody = {"type": 1, "page": 0};
          print("requestParam ${trendingBody}");

          Map<String, dynamic> recentBody = {"type": 2, "page": 0};
          print("requestParam ${recentBody}");

          Map<String, dynamic> allBody = {"type": 3, "page": 0};
          print("requestParam ${recentBody}");

          Provider.of<CampTrendingProvider>(context, listen: false)
              .getCampTrendingData(trendingBody);
          Provider.of<CampRecentListProvider>(context, listen: false)
              .getCampRecentData(recentBody);
          Provider.of<CampAllListProvider>(context, listen: false)
              .getCampAllData(allBody);*/
        } else if (it.status == "FAILURE") {
          setState(() {
            clearText = true;
            isApiCalled = false;
          });
          Fluttertoast.showToast(msg: it.message.toString());
        }
        if (kDebugMode) {
          print("responseSuccess ${it}");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        setState(() {
          isApiCalled = false;
        });
        if (kDebugMode) {
          print("responseFailure $obj");
        }
        // non-200 error goes here.
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
      setState(() {
        isApiCalled = false;
      });
    }
  }

  verifyPhoneOtp(int type, String otp, String phone) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": type,
      "mobile_no": int.parse(phone),
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "otp": int.parse(otp),
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient()
          .apiMobileNumberVerify(DataEncryption.getEncryptedData(map))
          .then((it) {
        if (it.status == "SUCCESS") {
          // var realData = DataEncryption.getDecryptedData(
          //     it.data!.reqKey.toString(), it.data!.reqData.toString());
          print("real data ${it.message}");
          Fluttertoast.showToast(msg: it.message.toString());
          Navigator.of(context).pop();
          /*SharedPrefProvider.setString(
              SharedPrefProvider.uniqueToken, realData["revuer_token"]);
          SharedPrefProvider.setString(SharedPrefProvider.mobileNumber,
              realData["mobile_no"].toString());
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              "${realData["first_name"]} ${realData["last_name"]}");
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          widget.location == "signup"
              ? Navigator.pushReplacementNamed(context, '/personalinfo')
              : Navigator.pushReplacementNamed(context, '/main');

          Map<String, dynamic> trendingBody = {"type": 1, "page": 0};
          print("requestParam ${trendingBody}");

          Map<String, dynamic> recentBody = {"type": 2, "page": 0};
          print("requestParam ${recentBody}");

          Map<String, dynamic> allBody = {"type": 3, "page": 0};
          print("requestParam ${recentBody}");

          Provider.of<CampTrendingProvider>(context, listen: false)
              .getCampTrendingData(trendingBody);
          Provider.of<CampRecentListProvider>(context, listen: false)
              .getCampRecentData(recentBody);
          Provider.of<CampAllListProvider>(context, listen: false)
              .getCampAllData(allBody);*/
        } else if (it.status == "FAILURE") {
          setState(() {
            clearText = true;
            isApiCalled = false;
          });
          Fluttertoast.showToast(msg: it.message.toString());
        }
        if (kDebugMode) {
          print("responseSuccess ${it}");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        setState(() {
          isApiCalled = false;
        });
        if (kDebugMode) {
          print("responseFailure $obj");
        }
        // non-200 error goes here.
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
      setState(() {
        isApiCalled = false;
      });
    }
  }

  /*resendOtp(int mobile) async {
    Map<String, dynamic> map = {"mobile_no": mobile};
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient().apiResendOtp(map).then((it) {
        if (it.status == "SUCCESS") {
          Fluttertoast.showToast(msg: it.message.toString());
          _start = 25;
          startTimer();
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
        }
        if (kDebugMode) {
          print("responseSuccess ${it}");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        if (kDebugMode) {
          print("responseFailure $obj");
        }
        // non-200 error goes here.
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

    */ /* Map<String, dynamic> map = {"mobile_no": mobile};
    print("req ${map}");
    try {
      var posResponse = await ApiClient.getClient().apiLogin(map);
      print('resp  ${posResponse.toJson()}');
    } catch (e) {
      print("exp $e");
    }*/ /*
  }*/

  @override
  Widget build(BuildContext context) {
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
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              reverse: true,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: ClipPath(
                            clipper: OvalClipper(),
                            child: Container(
                              width: double.infinity,
                              /*height: MediaQuery.of(context).size.height * 0.28,*/
                              height: 242.0,
                              /*constraints: BoxConstraints(
                                minHeight: 242.0,
                                minWidth: double.infinity,
                                maxHeight: MediaQuery.of(context).size.height * 0.28
                            ),*/
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        /*Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: Image.asset(
                            "assets/images/shape1.png",
                            width: 187.0,
                            fit: BoxFit.contain,
                          ),
                        ),*/
                        Positioned(
                          /*top: (MediaQuery.of(context).size.height * 0.28) - 64,*/
                          top: 175.0,
                          left: 20,
                          child: Image.asset(
                            "assets/images/logo2.png",
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0,
                          MediaQuery.of(context).size.height * 0.08,
                          16.0,
                          10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            Strings.verificationTitle,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          FittedBox(
                            child: Row(
                              children: [
                                const Text(
                                  Strings.verificationSubTitle,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: thirdColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                widget.location == "email"
                                    ? Text(
                                        widget.emailPhone,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryColor,
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis
                                      )
                                    : Text(
                                        "+91${widget.emailPhone}",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryColor,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          SizedBox(
                            child: OtpTextField(
                              numberOfFields: 6,
                              clearText: clearText,
                              borderColor: thirdColor,
                              focusedBorderColor: thirdColor,
                              showFieldAsBox: true,
                              borderWidth: 1.0,
                              onCodeChanged: (String code) {
                                clearText = false;
                              },
                              onSubmit: (String verificationCode) {
                                if (kDebugMode) {
                                  print('verificationCode $verificationCode');
                                }
                                /*widget.location == "signup"
                                    ? Navigator.pushReplacementNamed(context, '/personalinfo')
                                    : Navigator.pushReplacementNamed(context, '/main');*/
                                print("email ${widget.emailPhone}");
                                widget.location == "email"?
                                verifyEmailOtp(2, verificationCode, widget.emailPhone.toString()):
                                verifyPhoneOtp(2, verificationCode, widget.emailPhone.toString());
                              }, // end onSubmit
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),

                          //for resend otp
                          /*Row(
                            children: [
                              const Text(
                                "Didn't receive the OTP?",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: thirdColor,
                                ),
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                              _start == 0
                                  ? GestureDetector(
                                      onTap: () {
                                        // resendOtp(int.parse(widget.phoneNumber));
                                      },
                                      child: const Text(
                                        'Resend OTP',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Resend in 00:${_start.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                        decoration: TextDecoration.underline,
                                      )),
                              *//*GestureDetector(
                                onTap: () {
                                  resendOtp(int.parse(widget.phoneNumber));
                                },
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),*//*
                            ],
                          ),*/
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if(isApiCalled)
              SafeArea(
                child: Container(color: Colors.black26,child: const Center(
                  child: SizedBox(
                      child: CircularProgressIndicator(color: secondaryColor,)),
                ),),
              )
          ],
        ),
      ),
    );
  }

  Widget showTimer(bool isRunning, int start) {
    return isRunning == false
        ? GestureDetector(
            onTap: () {
              // resendOtp(int.parse(widget.phoneNumber));
            },
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        : Text(
            "Resend in 00:${start.toString()}",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              decoration: TextDecoration.underline,
            ),
          );
  }
}
