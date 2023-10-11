import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/models/api_response_model.dart';
import 'package:revuer/networking/models/campaign_details_model.dart';

import '../networking/DataEncryption.dart';
import '../networking/api_client.dart';
import '../networking/models/camp_trending_model.dart';

class CampTrendingProvider extends ChangeNotifier {
  List<CampaignData> list = [];

  Future<CampTrendingListModel> getCampTrendingData(
      Map<String, dynamic> body) async {
    print("req params home list :=> $body");
    CampTrendingListModel data = CampTrendingListModel();
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      try {
        final response = await ApiClient.getClient().apiGetCampaignList(body);
        print("bhdfsjkzxch SUCCESS ===> ${response.toString()}");
        if (response.status == "SUCCESS") {
          list.clear();
          if (response.data != null) {
            list.addAll(response.data!.campaignData!);
          }
          data = response;
          notifyListeners();
        } else if (response.status == "FAILURE") {
          // Fluttertoast.showToast(msg: response.message.toString());
          print('failure ${response.message.toString()}');
        }
        if (kDebugMode) {
          print("responseSuccess==> $response");
        }
        return data;
      } catch (error, stackTrace) {
        print("bhdfsjkzxch Failed ===> $error");
        Fluttertoast.showToast(msg: "Something went wrong");
        if (kDebugMode) {
          print("responseFailure $error");
          print("Stack Trace: $stackTrace");
        }
        // non-200 error goes here.
        if (error is DioError) {
          final res = error.response;
          print("status ${res?.statusCode}");
          print("status ${res?.statusMessage}");
          print("status ${res?.data}");
        }
        return data;
      }
    } else {
      Fluttertoast.showToast(msg: "No Internet Available");
      return data;
    }
  }
}

class CampRecentListProvider extends ChangeNotifier {
  List<CampaignData> list = [];

  Future<CampTrendingListModel> getCampRecentData(
      Map<String, dynamic> body) async {
    print("req params home list : $body");
    CampTrendingListModel data = CampTrendingListModel();

    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient().apiGetCampaignList(body).then((it) {
        if (it.status == "SUCCESS") {

          print("wdkfsgahkl==> ${it.data!.campaignData!}");
          list.clear();
          // print('printData ${it.data.toString()}');
          if (it.data != null) {
            list.addAll(it.data!.campaignData!);
          }
          data = it;
          notifyListeners();
        } else if (it.status == "FAILURE") {
          // Fluttertoast.showToast(msg: it.message.toString());
          print('failure ${it.message.toString()}');
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

    return data;
  }
}

class CampAllListProvider extends ChangeNotifier {
  List<CampaignData> list = [];

  Future<CampTrendingListModel> getCampAllData(
      Map<String, dynamic> body) async {
    print("req params home list : $body");
    CampTrendingListModel data = CampTrendingListModel();

    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient().apiGetCampaignList(body).then((it) {
        if (it.status == "SUCCESS") {
          list.clear();
          print('printData ${it.data.toString()}');
          if (it.data != null) {
            list.addAll(it.data!.campaignData!);
          }
          data = it;
          notifyListeners();
        } else if (it.status == "FAILURE") {
          // Fluttertoast.showToast(msg: it.message.toString());
          print('failure ${it.message.toString()}');
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

    return data;
  }
}

class CampaignDetailsProvider extends ChangeNotifier {
  //for consumer data
  CampaignDetailsModel campaignDetailsModel = CampaignDetailsModel();

  Future<CampaignDetailsModel> getCampaignDetails(
      Map<String, dynamic> body) async {
    //for get api data
    CampaignDetailsModel data = CampaignDetailsModel();

    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetCampaignDetails(body).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it["message"].toString());
          print("responseSuccess $it");
          print("responseSuccess ${it.data.toString()}");
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          print("details data ${realData.toString()}");
          campaignDetailsModel = CampaignDetailsModel.fromJson(realData);
          data = campaignDetailsModel;
          // Navigator.pushReplacementNamed(context, '/welcome');
          notifyListeners();
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

    return data;
  }
}
