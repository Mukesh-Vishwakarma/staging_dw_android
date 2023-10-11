import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:revuer/networking/models/api_response_model.dart';

import '../res/constants.dart';
import 'models/camp_trending_model.dart';
import 'models/campaign_type_list.dart';
import 'models/get_interest_data.dart';
import 'models/get_state_model.dart';
import 'models/my_camp_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: Strings.baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  static ApiClient getClient() {
    return ApiClient(Dio(BaseOptions(contentType: "application/json")));
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @POST("api/login")
  Future<ApiResponseModel> apiLogin(@Body() Map<String, dynamic> map);

  @POST("api/sign-up")
  Future<ApiResponseModel> apiSignUp(@Body() Map<String, dynamic> map);

  @POST("api/otp")
  Future<ApiResponseModel> apiOtp(@Body() Map<String, dynamic> map);

  @POST("api/resend-otp")
  Future<ApiResponseModel> apiResendOtp(@Body() Map<String, dynamic> map);

  @POST("api/state")
  Future<GetStateModel> apiState();

  @POST("api/city")
  Future<GetStateModel> apiCity(@Body() Map<String, dynamic> map);

  @POST("api/save-details")
  Future<ApiResponseModel> apiSaveDetails(@Body() Map<String, dynamic> map);

  @POST("api/get-profile")
  Future<ApiResponseModel> apiGetProfile(@Body() Map<String, dynamic> map);

  @POST("api/get-campaign-list")
  Future<CampTrendingListModel> apiGetCampaignList(
      @Body() Map<String, dynamic> map);

  @POST("api/google-register")
  Future<ApiResponseModel> apiLoginViaFbGoogle(
      @Body() Map<String, dynamic> map);

  @POST("api/email-verify")
  Future<ApiResponseModel> apiEmailVerify(@Body() Map<String, dynamic> map);

  @POST("api/mobile-number-verify")
  Future<ApiResponseModel> apiMobileNumberVerify(
      @Body() Map<String, dynamic> map);

  @POST("api/update-social-link")
  Future<ApiResponseModel> apiUpdateSocialLink(
      @Body() Map<String, dynamic> map);

  @POST("api/get-social-link")
  Future<ApiResponseModel> apiGetSocialLink(@Body() Map<String, dynamic> map);

  @POST("api/get-interest")
  Future<GetInterestData> apiGetInterests(@Body() Map<String, dynamic> map);

  @POST("api/update-interest")
  Future<ApiResponseModel> apiUpdateInterests(@Body() Map<String, dynamic> map);

  @POST("api/privacy-policy")
  Future<ApiResponseModel> apiPrivacyPolicy(@Body() Map<String, dynamic> map);

  @POST("api/check-privacy-policy")
  Future<dynamic> apiCheckPrivacyPolicy(@Body() Map<String, dynamic> map);

  @POST("api/get-campaign-details")
  Future<ApiResponseModel> apiGetCampaignDetails(
      @Body() Map<String, dynamic> map);

  @POST("api/get-revuer")
  Future<ApiResponseModel> apiGetRevuerDetails(
      @Body() Map<String, dynamic> map);

  @POST("api/campaign-apply")
  Future<dynamic> apiCampaignApply(@Body() Map<String, dynamic> map);

  @POST("api/get-privacy-policy")
  Future<dynamic> apiGetPrivacyPolicy();

  @POST("api/get-my-campaign-list")
  Future<MyCampListModel> apiGetMyCampaignList(
      @Body() Map<String, dynamic> map);

  @POST("api/get-my-campaign-approve-list")
  Future<MyCampListModel> apiGetMyOnGoingCampaignList(
      @Body() Map<String, dynamic> map);

  @POST("api/get-my-campaign-complete-list")
  Future<MyCampListModel> apiGetMyCompleteCampaignList(
      @Body() Map<String, dynamic> map);

  @POST("api/get-task-list")
  Future<ApiResponseModel> apiGetTaskList(@Body() Map<String, dynamic> map);

  @POST("api/get-task-details")
  Future<ApiResponseModel> apiGetTaskDetails(@Body() Map<String, dynamic> map);

  @POST("api/save-task")
  @MultiPart()
  Future<dynamic> apiSaveTask(
      @Part(name: 'image') File file,
      @Part(name: 'task_token') String taskToken,
      @Part(name: 'revuer_token') String revuerToken,
      @Part(name: 'task_desc') String taskDesc);

  @POST("api/save-task")
  @MultiPart()
  Future<dynamic> apiSaveTextTask(
      @Part(name: 'task_token') String taskToken,
      @Part(name: 'revuer_token') String revuerToken,
      @Part(name: 'task_desc') String taskDesc,
      @Part(name: 'ratings') String ratings);

  @POST("api/store-bank")
  Future<dynamic> apiSaveBankDetails(@Body() Map<String, dynamic> map);

  @POST("api/store-upi")
  Future<dynamic> apiSaveUpiDetails(@Body() Map<String, dynamic> map);

  @POST("api/get-feed-option")
  Future<ApiResponseModel> apiGetFeedOption(@Body() Map<String, dynamic> map);

  @POST("api/get-wallet-amount")
  Future<ApiResponseModel> apiGetWalletAmount(@Body() Map<String, dynamic> map);

  @POST("api/get-wallet-historie-list")
  Future<ApiResponseModel> apiGetWalletHistory(
      @Body() Map<String, dynamic> map);

  @POST("api/withdraw")
  Future<dynamic> apiWithdrawRequest(@Body() Map<String, dynamic> map);

  @POST("api/get-campaign-type-list")
  Future<CampaignTypeList> apiCampaignTypeList();

  @POST("api/get-analytics")
  Future<ApiResponseModel> apiGetAnalytics(@Body() Map<String, dynamic> map);

  @POST("/api/check-task-url")
  Future<dynamic> apiCheckValidUrl(@Body() Map<String, dynamic> map);

  @POST("/api/logout")
  Future<dynamic> apiUserLogout(@Body() Map<String, dynamic> map);

  @POST("/api/get-notification-list")
  Future<ApiResponseModel> apiGetNotificationList(
      @Body() Map<String, dynamic> map);

  @POST("/api/search-campaign-list")
  Future<CampTrendingListModel> apiGetCampaignSearchList(
      @Body() Map<String, dynamic> map);

  @POST("/api/my-search-campaign-list")
  Future<MyCampListModel> apiGetMyCampaignSearchList(
      @Body() Map<String, dynamic> map);

  @POST("/api/check-refer-code")
  Future<ApiResponseModel> apiVerifyReferCode(@Body() Map<String, dynamic> map);

  @POST("/api/get-refer-content")
  Future<ApiResponseModel> apiGetReferContent(@Body() Map<String, dynamic> map);

  @POST("/api/add-tracker")
  Future<ApiResponseModel> apiAdsTracker(@Body() Map<String, dynamic> map);
}
