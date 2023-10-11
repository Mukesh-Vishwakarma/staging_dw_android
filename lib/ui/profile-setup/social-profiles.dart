import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/step-indicator.dart';

class SocialProfilesScreen extends StatefulWidget {
  const SocialProfilesScreen({Key? key}) : super(key: key);

  @override
  State<SocialProfilesScreen> createState() => _SocialProfilesScreenState();
}

class _SocialProfilesScreenState extends State<SocialProfilesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey1 = GlobalKey<FormState>();

  double statusBarHeight = 5.0;

  TextEditingController instagramController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController linkdienController = TextEditingController();
  TextEditingController printrestController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/setup-profile');
  }

  @override
  void initState() {
    super.initState();
    getSocialProfile();
  }

  void updateSocialProfile(
    String instagram,
    String facebook,
    String linkedien,
    String printrest,
    String twitter,
    String youtube,
  ) async {
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken), //from share preference
      "instagram_url": instagram,
      "facebook_url": facebook,
      "linkedin_url": linkedien,
      "pinterest_url": printrest,
      "twitter_url": twitter,
      "youtube_url": youtube,
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiUpdateSocialLink(map).then((it) {
        if (it.status == "SUCCESS") {
          Fluttertoast.showToast(msg: it.message.toString());
          print("responseSuccess $it");
          Navigator.pushReplacementNamed(context, '/privacy-policy');
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

  void getSocialProfile() async {
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken), //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetSocialLink(map).then((it) {
        if (it.status == "SUCCESS") {
         // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          instagramController.text = realData["instagram_url"];
          facebookController.text = realData["facebook_url"];
          linkdienController.text = realData["linkedin_url"];
          printrestController.text = realData["pinterest_url"];
          twitterController.text = realData["twitter_url"];
          youtubeController.text = realData["youtube_url"];
          print("responseSuccess insta:- ${realData}");
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
                    Strings.setupProfile,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 7.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Step 2 : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "Social Profiles",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  StepIndicator(totalStep: 3, step: 2),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50.0),
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
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          Form(
                            key: _formKey1,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const LabelWidget(
                                    labelText: "Instagram", mandatory: true),
                                const SizedBox(
                                  height: 6.0,
                                ),
                                CustomTextField(
                                  isImg: true,
                                  imgIcon: Container(
                                    height: 50.0,
                                    margin: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/icons/instagram-s.png',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.fill),
                                      ],
                                    ),
                                  ),
                                  boxShadowColor:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8.0,
                                  placeholder: 'Type here',
                                  maxLength: 256,
                                  textController: instagramController,
                                  validator: (value) {
                                    if (value == "") {
                                      return Strings.requiredStr;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onChanged: (value) {},
                                ),
                                const LabelWidget(
                                    labelText: "Facebook"),
                                const SizedBox(
                                  height: 6.0,
                                ),
                                CustomTextField(
                                  isImg: true,
                                  imgIcon: Container(
                                    height: 50.0,
                                    margin: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/icons/facebook-s.png',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.fill),
                                      ],
                                    ),
                                  ),
                                  boxShadowColor:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8.0,
                                  placeholder: 'Type here',
                                  maxLength: 256,
                                  textController: facebookController,
                                  onChanged: (value) {},
                                ),
                                const LabelWidget(
                                    labelText: "LinkedIn"),
                                const SizedBox(
                                  height: 6.0,
                                ),
                                CustomTextField(
                                  isImg: true,
                                  imgIcon: Container(
                                    height: 50.0,
                                    margin: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/linkedin.png',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.fill),
                                      ],
                                    ),
                                  ),
                                  boxShadowColor:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8.0,
                                  placeholder: 'Type here',
                                  maxLength: 256,
                                  textController: linkdienController,
                                  onChanged: (value) {

                                  },
                                ),
                                const LabelWidget(labelText: "Pinterest"),
                                const SizedBox(
                                  height: 6.0,
                                ),
                                CustomTextField(
                                  isImg: true,
                                  imgIcon: Container(
                                    height: 50.0,
                                    margin: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'assets/icons/pinterest.png',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.fill),
                                      ],
                                    ),
                                  ),
                                  boxShadowColor:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8.0,
                                  placeholder: 'Type here',
                                  maxLength: 256,
                                  textController: printrestController,
                                  onChanged: (value) {},
                                ),
                                const LabelWidget(labelText: "Twitter"),
                                const SizedBox(
                                  height: 6.0,
                                ),
                                CustomTextField(
                                  isImg: true,
                                  imgIcon: Container(
                                    height: 50.0,
                                    margin: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/twitter.png',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.fill),
                                      ],
                                    ),
                                  ),
                                  boxShadowColor:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8.0,
                                  placeholder: 'Type here',
                                  maxLength: 256,
                                  textController: twitterController,
                                  onChanged: (value) {},
                                ),
                                const LabelWidget(labelText: "Youtube"),
                                const SizedBox(
                                  height: 6.0,
                                ),
                                CustomTextField(
                                  isImg: true,
                                  imgIcon: Container(
                                    height: 50.0,
                                    margin: const EdgeInsets.only(
                                        left: 15.0, right: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/youtube.png',
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.fill),
                                      ],
                                    ),
                                  ),
                                  boxShadowColor:
                                      Colors.black.withOpacity(0.04),
                                  blurRadius: 8.0,
                                  placeholder: 'Type here',
                                  maxLength: 256,
                                  textController: youtubeController,
                                  onChanged: (value) {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24.0,
              left: 16.0,
              right: 16.0,
              child: ButtonWidget(
                buttonContent: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SAVE & NEXT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Image.asset(
                      "assets/icons/arrow-right.png",
                      width: 22,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                onPressed: () {
                  if (_formKey1.currentState!.validate()) {
                    updateSocialProfile(
                        instagramController.text,
                        facebookController.text,
                        linkdienController.text,
                        printrestController.text,
                        twitterController.text,
                        youtubeController.text);
                    print("validated true");
                  }
                  //  Navigator.pushReplacementNamed(context, '/subscription');
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  bool hasValidUrl(String value) {
   /* return RegExp(
            '/(?:(?:http|https):\/\/)?(?:www.)?(?:instagram.com|instagr.am|instagr.com)\/(\w+)/igm')
        .hasMatch(value);
     return RegExp("/[~!@#\$%^&<>]/").hasMatch(value);*/
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    }
    else if (!regExp.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

}
