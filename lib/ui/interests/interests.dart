import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({Key? key}) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  bool isSubmitLoading = false;

  double statusBarHeight = 5.0;

  Map<String, bool> interestsList = {};

  Map<String, String> allInterestId = {};

  List<String> idList = [];

  void _openMyPage() {
    Navigator.of(context).pop();
    /* Navigator.of(context)
        .pushNamedAndRemoveUntil('/profile', (Route<dynamic> route) => false);*/
    //Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  void initState() {
    super.initState();
    getInterest();
  }

  void updateInterest(List<String> updateIdList) async {
    setState(() {
      isSubmitLoading = true;
    });
    if (kDebugMode) {
      print("join ${updateIdList.join(",")}");
    }
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "interest_id": updateIdList.join(","),
    };
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiUpdateInterests(map).then((it) {
        if (it.status == "SUCCESS") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseSuccess $it");
          }
          setState(() {
            isSubmitLoading = false;
          });
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          setState(() {
            isSubmitLoading = false;
          });
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        setState(() {
          isSubmitLoading = false;
        });
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseFailure $obj");
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
        isSubmitLoading = false;
      });
    }
  }

  void getInterest() async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken)
    };
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetInterests(map).then((it) {
        if (it.status == "SUCCESS") {
          for (int i = 0; i < it.data!.length; i++) {
            interestsList[it.data![i].name!] = it.data![i].checktype!;
            allInterestId[it.data![i].name!] = it.data![i].id!;
            if (kDebugMode) {
              print("name ${it.data![i].name!} id ${it.data![i].id!}");
            }
          }
          if (kDebugMode) {
            print("responseSuccess $it");
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
          setState(() {
            isLoading = false;
          });
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
          setState(() {
            isLoading = false;
          });
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
                padding: EdgeInsets.fromLTRB(
                    16.0, (statusBarHeight + 15.0), 16.0, 5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
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
                            width: 22.0, height: 21.0, fit: BoxFit.fitWidth),*/
                      ],
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const Text(
                      Strings.interest,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Flexible(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 80.0),
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          16.0, 16.0, 16.0, 14.0),
                                      child: Text(
                                        "Choose your interests:",
                                        style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          11.0, 0.0, 11.0, 2.0),
                                      child: Wrap(
                                        children: interestsList.keys
                                            .map((String key) {
                                          return Container(
                                            margin: const EdgeInsets.fromLTRB(
                                                5.0, 0.0, 5.0, 16.0),
                                            decoration: BoxDecoration(
                                                color: interestsList[key]!
                                                    ? primaryColor
                                                    : Colors.white,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xff2A3B53)
                                                            .withOpacity(0.1),
                                                    spreadRadius: 0,
                                                    blurRadius: 7,
                                                    offset: const Offset(1, 1),
                                                  ),
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xff2A3B53)
                                                            .withOpacity(0.04),
                                                    spreadRadius: 0,
                                                    blurRadius: 9.0,
                                                    offset: const Offset(0, 0),
                                                  )
                                                ]),
                                            child: key != 'Others'
                                                ? InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        interestsList[key] =
                                                            !interestsList[
                                                                key]!;
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 16.0,
                                                          horizontal: 14.0),
                                                      child: Text(
                                                        key,
                                                        style: TextStyle(
                                                            color: interestsList[
                                                                    key]!
                                                                ? Colors.white
                                                                : secondaryColor,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                  )
                                                : InkWell(
                                                    onTap: () {},
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 16.0,
                                                          horizontal: 14.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Image.asset(
                                                              'assets/icons/plus.png',
                                                              width: 20.0,
                                                              height: 20.0,
                                                              fit: BoxFit
                                                                  .contain),
                                                          const SizedBox(
                                                            width: 8.0,
                                                          ),
                                                          const Text(
                                                            "Add Others",
                                                            style: TextStyle(
                                                                color:
                                                                    secondaryColor,
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
              isLoading
                  ? const SizedBox(
                      height: 0,
                    )
                  : Positioned(
                      bottom: 24.0,
                      left: 16.0,
                      right: 16.0,
                      child: isSubmitLoading
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
                                if (interestsList.containsValue(true)) {
                                  for (var i in interestsList.entries) {
                                    if (i.value == true) {
                                      if (kDebugMode) {
                                        print(
                                            "interestsList ${i.key},value ${i.value}");
                                      }
                                      var id = allInterestId.entries
                                          .firstWhere(
                                              (entry) => entry.key == i.key)
                                          .value;

                                      // print('The key for value "Bag" : ${id}');

                                      idList.add(id.toString());
                                    }
                                  }

                                  updateInterest(idList);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please select few interests");
                                }
                                //Navigator.pushReplacementNamed(context, '/social-profiles');
                              },
                            ),
                    ),
            ],
          )),
    );
  }
}
