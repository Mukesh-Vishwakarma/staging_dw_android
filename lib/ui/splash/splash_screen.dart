import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:revuer/shared_preference/preference_provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Image logo;
  late Widget text;

  @override
  void initState() {
    super.initState();
    logo = Image.asset(
      "assets/images/logo3.png",
      width: 80,
      fit: BoxFit.contain,
    );

    text = Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: const Color.fromRGBO(191, 191, 191, 0.4),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            Strings.appName,
            style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            "by Mishry",
            style: TextStyle(
              height: 0.5,
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
    if (kDebugMode) {
      print("base url :- ${Strings.baseUrl}");
    }
    getPrefData();
  }

  savePlayerId() async {
    final status = await OneSignal.shared.getDeviceState();
    final String? playerId = status?.userId;
    debugPrint("player id otp:- $playerId");
    SharedPrefProvider.setString(SharedPrefProvider.playerId, playerId!);
  }

  getPrefData() async {
    final token =
        await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken);
    final mobile =
        await SharedPrefProvider.getString(SharedPrefProvider.mobileNumber);
    final keepLogin =
        await SharedPrefProvider.getBool(SharedPrefProvider.keepMeLogin);
    if (token != null) {
      savePlayerId();
      if (keepLogin == true) {
     /*   Map<String, dynamic> trendingBody = {"type": 1, "page": 0};
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
        getRevuerDetails(token);
      } else {
        hideScreen();
      }
    } else {
      hideScreen();
    }
    if (kDebugMode) {
      print("mobile $mobile  token $token keepLogin $keepLogin");
    }
  }

  getRevuerDetails(String token) async {
    Map<String, dynamic> map = {
      "revuer_token": token //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          log("real data0 ${it.data}");
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          log("real data1 ${jsonEncode(realData)}");
          var revuerDetailsModel = RevuerDetailsModel.fromJson(realData);
          if (kDebugMode) {
            print("real data2 ${revuerDetailsModel.revuerData}");
          }
          if(revuerDetailsModel.revuerData!.profileSetupStatus!){
            if(revuerDetailsModel.revuerData!.socialStatus!){
              homeScreen();
            }else{
              Navigator.pushReplacementNamed(context, '/social-account-after-personal-info');
            }
          }else{
            Navigator.pushReplacementNamed(context, '/personalinfo');
          }
          if (kDebugMode) {
            print("real data3 $realData");
          }
          if (kDebugMode) {
            print("responseSuccess $it");
          }
        } else if (it.status == "FAILURE") {
         // Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
       // Fluttertoast.showToast(msg: "Something went wrong");
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
  void didChangeDependencies() {
    precacheImage(logo.image, context);
    super.didChangeDependencies();
  }

  Future<void> hideScreen() async {
    Future.delayed(const Duration(milliseconds: 2400), () async {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  Future<void> homeScreen() async {
    Future.delayed(const Duration(milliseconds: 2400), () async {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    print("screen called splash");
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            text
          ],
        ),
      ),
    );
  }

}
