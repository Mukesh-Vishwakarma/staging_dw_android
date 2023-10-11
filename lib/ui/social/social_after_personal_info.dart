import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/textfield_widget.dart';

class SocialAccountScreenAfterPersonalInfo extends StatefulWidget {
  const SocialAccountScreenAfterPersonalInfo({Key? key}) : super(key: key);

  @override
  State<SocialAccountScreenAfterPersonalInfo> createState() =>
      _SocialAccountScreenAfterPersonalInfoState();
}

class _SocialAccountScreenAfterPersonalInfoState
    extends State<SocialAccountScreenAfterPersonalInfo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey1 = GlobalKey<FormState>();

  double statusBarHeight = 5.0;
  var startInstaUrl = "https://instagram.com/";
  bool isApiCalled = false;

  TextEditingController instagramController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController linkdienController = TextEditingController();
  TextEditingController printrestController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void updateSocialProfile(
    String instagram,
    String facebook,
    String linkedien,
    String printrest,
    String twitter,
    String youtube,
  ) async {
    setState(() {
      isApiCalled = true;
    });
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
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiUpdateSocialLink(map).then((it) {
        if (it.status == "SUCCESS") {
          Fluttertoast.showToast(msg: it.message.toString());
          Navigator.pushReplacementNamed(context, '/welcome');
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          setState(() {
            isApiCalled = false;
          });
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        setState(() {
          isApiCalled = false;
        });
        switch (obj.runtimeType) {
          case DioError:
            // Here's the sample to get the failed response error code and message
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

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
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
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  Strings.socialProfiles,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
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
                                boxShadowColor: Colors.black.withOpacity(0.04),
                                blurRadius: 8.0,
                                placeholder: 'Enter your Instagram handle',
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
                              const LabelWidget(labelText: "Facebook"),
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
                                      Image.asset('assets/icons/facebook-s.png',
                                          width: 20.0,
                                          height: 20.0,
                                          fit: BoxFit.fill),
                                    ],
                                  ),
                                ),
                                boxShadowColor: Colors.black.withOpacity(0.04),
                                blurRadius: 8.0,
                                placeholder: 'Enter your Facebook profile link',
                                maxLength: 256,
                                textController: facebookController,
                                onChanged: (value) {},
                              ),
                              const LabelWidget(labelText: "LinkedIn"),
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
                                boxShadowColor: Colors.black.withOpacity(0.04),
                                blurRadius: 8.0,
                                placeholder: 'Enter your Linkedin profile link',
                                maxLength: 256,
                                textController: linkdienController,
                                onChanged: (value) {},
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
                                      Image.asset('assets/icons/pinterest.png',
                                          width: 20.0,
                                          height: 20.0,
                                          fit: BoxFit.fill),
                                    ],
                                  ),
                                ),
                                boxShadowColor: Colors.black.withOpacity(0.04),
                                blurRadius: 8.0,
                                placeholder:
                                    'Enter your Pinterest profile link',
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
                                boxShadowColor: Colors.black.withOpacity(0.04),
                                blurRadius: 8.0,
                                placeholder: 'Enter your Twitter profile link',
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
                                boxShadowColor: Colors.black.withOpacity(0.04),
                                blurRadius: 8.0,
                                placeholder: 'Enter your Youtube channel link',
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
            child: isApiCalled
                ? ButtonWidget(
                    buttonContent: const Center(
                        child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white))),
                    onPressed: () {},
                  )
                : ButtonWidget(
                    buttonContent: const Text(
                      "SAVE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0),
                    ),
                    onPressed: () {
                      if (_formKey1.currentState!.validate()) {
                        var instaUrl = startInstaUrl +
                            instagramController.text.toString().trim();
                        updateSocialProfile(
                            instaUrl,
                            facebookController.text,
                            linkdienController.text,
                            printrestController.text,
                            twitterController.text,
                            youtubeController.text);
                      }
                      //Navigator.pushReplacementNamed(context, '/social-profiles');
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
