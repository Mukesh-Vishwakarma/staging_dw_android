import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:revuer/shared_preference/preference_provider.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../provider_helper/campaign_provider.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/button_widget.dart';
import '../../ui/otp/verification.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isChecked = true;
  bool isApiCalled = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneNumberController = TextEditingController();

  String phoneNumber = '';

  savePlayerId() async {
    final status = await OneSignal.shared.getDeviceState();
    final String? playerId = status?.userId;
    debugPrint("player id login:- $playerId");
    SharedPrefProvider.setString(SharedPrefProvider.playerId, playerId!);
  }

  facebookLogin() async {
    if (kDebugMode) {
      print("FaceBook");
    }
    try {
      final result =
          await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.i.getUserData();
        if (kDebugMode) {
          print('user data $userData');
        }
        var name = userData["name"];
        var email = userData["email"];
        var url = userData["picture"]["data"]["url"];
        if (kDebugMode) {
          print("FaceBook data name :- $name email:- $email url:- $url");
        }
        loginViaGoogleOrFb(name == "" ? "" : name!, email == "" ? "" : email!,
            url ?? "");
      } else {
        if (kDebugMode) {
          print('failure');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('error $error');
      }
    }
  }

  googleLogin() async {
    if (kDebugMode) {
      print("googleLogin method Called");
    }
    final googleSignIn = GoogleSignIn();
    try {
      var result = await googleSignIn.signIn();
      var name = result?.displayName;
      var email = result?.email;
      var url = result?.photoUrl;
      if (result == null) {
        if (kDebugMode) {
          print("error occurred In login");
        }
      } else {
        loginViaGoogleOrFb(name == "" ? "" : name!, email == "" ? "" : email!,
            url ?? "");
      }
      if (kDebugMode) {
        print("google data $result");
      }
    } catch (error) {
      if (kDebugMode) {
        print("google error$error");
      }
    }
  }

  loginViaGoogleOrFb(String name, String email, String imageUrl) async {
    Map<String, dynamic> map = {
      "name": name,
      "email": email,
      "image": imageUrl,
      "type": 2,
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiLoginViaFbGoogle(DataEncryption.getEncryptedData(map))
          .then((it) {
        if (it.status == "SUCCESS") {
          final googleSignIn = GoogleSignIn();
          googleSignIn.signOut();
          FacebookAuth.instance.logOut();
          Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          savePlayerId();
          logLogin(email);
          SharedPrefProvider.setString(
              SharedPrefProvider.uniqueToken, realData["revuer_token"]);
          SharedPrefProvider.setString(
              SharedPrefProvider.mobileNumber,
              realData["mobile_no"] == null
                  ? ""
                  : realData["mobile_no"].toString());
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              "${realData["first_name"]} ${realData["last_name"]}");
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          SharedPrefProvider.setBool(SharedPrefProvider.keepMeLogin, true);

          if (kDebugMode) {
            print("login_type ${realData["login_type"]}");
          }

          realData["profile_setup_status"] == true
              ? realData["social_status"] == true
                  ? Navigator.pushReplacementNamed(context, '/main')
                  : Navigator.pushReplacementNamed(
                      context, '/social-account-after-personal-info')
              : Navigator.pushReplacementNamed(context, '/personalinfo');

          /*if(realData["login_type"]==1) {
            Navigator.pushReplacementNamed(context, '/main');
          }else{
            Navigator.pushReplacementNamed(context, '/personalinfo');
          }*/

          Map<String, dynamic> trendingBody = {"type": 1, "page": 0};
          if (kDebugMode) {
            print("requestParam $trendingBody");
          }

          Map<String, dynamic> recentBody = {"type": 2, "page": 0};
          if (kDebugMode) {
            print("requestParam $recentBody");
          }

          Map<String, dynamic> allBody = {"type": 3, "page": 0};
          if (kDebugMode) {
            print("requestParam $recentBody");
          }

          Provider.of<CampTrendingProvider>(context, listen: false)
              .getCampTrendingData(trendingBody);
          Provider.of<CampRecentListProvider>(context, listen: false)
              .getCampRecentData(recentBody);
          Provider.of<CampAllListProvider>(context, listen: false)
              .getCampAllData(allBody);
          if (kDebugMode) {
            print("real data $realData");
          }
          if (kDebugMode) {
            print("responseSuccess $it");
          }
        } else if (it.status == "FAILURE") {
          if (kDebugMode) {
            print("responseFailure $it");
          }
          final googleSignIn0 = GoogleSignIn();
          googleSignIn0.signOut();
          Fluttertoast.showToast(msg: it.message.toString());
        }
      }).catchError((Object obj) {
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

  loginViaApi(int mobile) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {"mobile_no": mobile};
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiLogin(map).then((it) {
        if (it.status == "SUCCESS") {

          print("askdfgch===>${it.data}");

          SharedPrefProvider.setBool(SharedPrefProvider.keepMeLogin, isChecked);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return VerificationScreen(
                location: "login", phoneNumber: phoneNumber);
          }));
         /* setState(() {
            isApiCalled = false;
          });*/
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          setState(() {
            isApiCalled = false;
          });
        }
        if (kDebugMode) {
          print("responseSuccess $it");
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        setState(() {
          isApiCalled = false;
        });
        // non-200 error goes here.
        if (kDebugMode) {
          print("response exception $obj");
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
      setState(() {
        isApiCalled = false;
      });
    }
  }

  logLogin(String email) async {
    await FirebaseAnalytics.instance.logLogin(loginMethod: email);
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      return primaryColor;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Stack(
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
                              height: 242.0,
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
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            Strings.loginTitle,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          const Text(
                            Strings.loginSubTitle,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: thirdColor,
                            ),
                          ),
                          const SizedBox(
                            height: 28.0,
                          ),
                          const LabelWidget(labelText: Strings.phoneNoLabel),
                          const SizedBox(
                            height: 10.0,
                          ),
                          CustomTextField(
                            textController: phoneNumberController,
                            isImg: true,
                            imgIcon: Container(
                              margin: const EdgeInsets.only(left: 15.0),
                              padding:
                                  const EdgeInsets.fromLTRB(5.0, 0, 5.0, 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('assets/icons/phone.png',
                                      width: 20.0,
                                      height: 20.0,
                                      fit: BoxFit.fill),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  const Text(
                                    '+91',
                                    style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            placeholder: 'Enter Phone Number',
                            digitOnly: true,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            boxShadowColor: Colors.black.withOpacity(0.04),
                            blurRadius: 8.0,
                            onChanged: (value) {
                              phoneNumber = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Phone number';
                              } else if (value.length < 10) {
                                return 'Please enter 10 digit phone number';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 25.0,
                                height: 25.0,
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isChecked = !isChecked;
                                  });
                                },
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 4.0,
                                    ),
                                    Text(
                                      'Keep me logged in',
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 28.0,
                          ),
                          isApiCalled
                              ? ButtonWidget(
                                  buttonContent: const Center(child: SizedBox(
                                      height: 20,width: 20,
                                      child: CircularProgressIndicator(color: Colors.white))),
                                  onPressed: () {
                                  },
                                )
                              : ButtonWidget(
                                  buttonText: "LOGIN",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      loginViaApi(int.parse(phoneNumber));
                                      /*Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return VerificationScreen(
                                      location: "login",
                                      phoneNumber: phoneNumber);
                                }));*/
                                    }
                                  },
                                ),
                          const SizedBox(height: 40.0),
                          Row(children: const [
                            Expanded(
                                child: Divider(
                              color: thirdColor,
                            )),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                              color: thirdColor,
                            )),
                          ]),
                          const SizedBox(height: 40.0),
                          Row(
                            children: [
                              Expanded(
                                child: ButtonWidget(
                                  isShadow: false,
                                  buttonColor: grayColor,
                                  buttonContent: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/facebook.png",
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      const Text(
                                        'Facebook',
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    //facebook sign method
                                    // Navigator.pushNamed(context, '/coming-soon');
                                    facebookLogin();
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 14.0,
                              ),
                              Expanded(
                                child: ButtonWidget(
                                  isShadow: false,
                                  buttonColor: grayColor,
                                  buttonContent: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/google.png",
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      const Text(
                                        'Google',
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    if (kDebugMode) {
                                      print("clicked google button");
                                    }
                                    googleLogin();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                Strings.dntHaveAccount,
                                style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(
                                    context, '/signup'),
                                child: const Text(
                                  'Signup',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
