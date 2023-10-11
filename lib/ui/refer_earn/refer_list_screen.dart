import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:revuer/ui/refer_earn/refer_content_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shaps/src/oval_clipper.dart';
import '../../shared_preference/preference_provider.dart';

class ReferListScreen extends StatefulWidget {
  const ReferListScreen({Key? key}) : super(key: key);

  @override
  State<ReferListScreen> createState() => _ReferListScreenState();
}

class _ReferListScreenState extends State<ReferListScreen> {
  double statusBarHeight = 5.0;

  void _openMyPage() {
    Navigator.of(context).pop();
  }

  bool isApiCalled = true;
  ReferContentModel referContentModel = ReferContentModel();

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
                          "Referral List",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        isApiCalled
                            ? const SizedBox()
                            : TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  backgroundColor: grayColor,
                                ),
                                child: referContentModel.referList != null
                                    ? referContentModel.referList!.isNotEmpty
                                        ? Text(
                                            "Referral Count: ${referContentModel.referList!.length}",
                                            style: const TextStyle(
                                                color: secondaryColor),
                                          )
                                        : const Text(
                                            "Referral Count: 0",
                                            style: TextStyle(
                                                color: secondaryColor),
                                          )
                                    : const SizedBox(),
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
                    margin: const EdgeInsets.only(bottom: 8.0),
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
                        : referContentModel.referList != null
                            ? referContentModel.referList!.isNotEmpty
                                ? ListView.builder(
                                    padding: const EdgeInsets.only(top: 12),
                                    itemCount:
                                        referContentModel.referList!.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            bottom: 12,
                                            top: 0),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xff2A3B53)
                                                    .withOpacity(0.08),
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
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 20,
                                              bottom: 20),
                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipOval(
                                                  child: showImage(
                                                      referContentModel
                                                          .referList![index])),
                                              const SizedBox(
                                                width: 12,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "${referContentModel.referList![index].firstName!} ${referContentModel.referList![index].lastName!}"),
                                                  Text(
                                                    DateFormat('dd MMM yyyy')
                                                        .format(DateTime.parse(
                                                                referContentModel
                                                                    .referList![
                                                                        index]
                                                                    .createdAt!)
                                                            .toLocal())
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const Center(child: Text("No data found"))
                            : const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          /*isApiCalled
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

  Widget showImage(ReferList referList) {
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
      if (referList.revuerImage!.isNotEmpty) {
        return Image.network(referList.revuerImage!,
            width: 50.0,
            height: 50.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 50.0,
              height: 50.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 50.0,
            height: 50.0,
            child: Image.asset(
              width: 50.0,
              height: 50.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 50.0,
          height: 50.0,
          color: primaryColor,
          child: Center(
              child: Text(
            referList.firstName!.isNotEmpty
                ? referList.firstName![0].toUpperCase()
                : "R",
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
