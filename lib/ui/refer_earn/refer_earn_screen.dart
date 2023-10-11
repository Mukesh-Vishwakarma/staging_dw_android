import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/ui/refer_earn/refer_content_model.dart';
import 'package:revuer/ui/refer_earn/refer_list_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shaps/src/oval_clipper.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({Key? key}) : super(key: key);

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  double statusBarHeight = 5.0;
  bool isApiCalled = true;

  ReferContentModel referContentModel = ReferContentModel();

  void _openMyPage() {
    Navigator.of(context).pop();
  }

  getReferContent() async {
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetReferContent(map).then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          referContentModel = ReferContentModel.fromJson(realData);
          if (kDebugMode) {
            print("real data refer content $realData");
          }
          if (kDebugMode) {
            print("responseSuccess refer content $it");
          }
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure refer content $it");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          isApiCalled = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException refer content $obj");
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

  Future<void> share(String message) async {
    await FlutterShare.share(
        title: 'Share',
        text: '$message.',
        //linkUrl: "https://blog.ruloans.com/wp-content/uploads/2021/07/refer-Earn-Banner.jpg",
        chooserTitle: 'Share');
  }

  @override
  void initState() {
    super.initState();
    getReferContent();
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Refer & Earn",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const ReferListScreen()));
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: grayColor,
                          ),
                          child: const Text(
                            "Referral List",
                            style: TextStyle(color: secondaryColor),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
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
                    child: isApiCalled
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : SingleChildScrollView(
                            child: referContentModel.referData?.referCode !=
                                    null
                                ? Column(
                                    children: [
                                      showImage(),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      Text(referContentModel
                                          .referData!.referContent!,style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 16.0,
                                      ),textAlign: TextAlign.justify,),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(4)),
                                                    border: Border.all(
                                                        color: Colors.grey)),
                                                child: Text(referContentModel
                                                    .referData!.referCode!
                                                    .toUpperCase()),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                        text: referContentModel
                                                            .referData!
                                                            .referCode!))
                                                    .then((value) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Copied to Clipboard");
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: secondaryColor,
                                              ),
                                              child: const Text(
                                                "Copy",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                  ),
                ),
                isApiCalled
                    ? const SizedBox()
                    : ButtonWidget(
                        buttonText: "SHARE",
                        onPressed: () {
                          share(referContentModel.referData!.referMessage!);
                        },
                      ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ),
          /* isApiCalled
              ? Positioned(
                  top: 100.0,
                  child: Container(
                    width: width,
                    height: height,
                    color: const Color.fromRGBO(255, 255, 255, 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: secondaryColor,
                      ),
                    ),
                  ),
                )
              : const SizedBox()*/
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
      if (referContentModel.referData!.image!.isNotEmpty) {
        return Image.network(referContentModel.referData!.image!,
            height: 175,
            fit: BoxFit.contain, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              height: 175,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            height: 175,
            child: Image.asset(
              height: 175,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return SizedBox(
          height: 175,
          child: Image.asset(
            height: 175,
            'assets/images/error_image.png',
            fit: BoxFit.cover,
          ),
        );
      }
    }
  }
}
