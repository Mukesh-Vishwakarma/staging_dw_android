import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefProvider {
  static setString(String key, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static setBool(String key, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static clearPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  static const String keepMeLogin = "keepMeLogin";
  static const String uniqueToken = "uniqueToken";
  static const String mobileNumber = "mobileNumber";
  static const String firstName = "firstName";
  static const String fullName = "fullName";
  static const String profileImage = "profileImage";
  static const String campaignToken = "campaignToken";
  static const String brandloginUniqueToken = "brandloginUniqueToken";
  static const String playerId = "playerId";
}
