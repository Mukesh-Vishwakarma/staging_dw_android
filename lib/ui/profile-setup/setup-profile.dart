import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../dropdown/find_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/get_profile_model.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/step-indicator.dart';
import '../otp/verification_email_phone.dart';

import 'package:flutter/services.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({Key? key}) : super(key: key);

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey1 = GlobalKey<FormState>();
  var statesKey = GlobalKey<FindDropdownState>();
  var citiesKey = GlobalKey<FindDropdownState>();

  var isLoading = false;
  var _state = "";
  var _stateDropdownError = "";
  var _city = "";
  var _cityDropdownError = "";
  var imageUrl = "";

  GetProfileModel getProfileModel = GetProfileModel();

  double statusBarHeight = 5.0;

  final emojiRegex =
      '(\ud83c|[\udf00-\udfff]|\ud83d|[\udc00-\ude4f]|\ud83d|[\ude80-\udeff])';

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  int _gender = 0;
  String isChildren = "";

  var _genderDropdownError = "";

  final List<String> stateList = [];
  final List<String> stateIdList = [];
  final List<String> cityList = [];
  final List<String> cityIdList = [];

  int stateIndex = 0;
  int cityIndex = 0;
  var stateId = "";
  var cityId = "";
  String? _selectedstate = "";
  String? _selectedcity = "";
  String? firstName = "";
  String? lastName = "";
  String? address = "";
  String? pinCode = "";
  String? dob = "";
  String? email = "";
  String? mobile = "";
  String? haveChild = "";
  bool stateCityCheck = true;

  var getProfileCalled = false;

  // for pick image from gallery or camera ------->>
  File? selectedImage;
  String base64Image = "";
  String imageName = "";

  Future<void> chooseImage(type) async {
    var image;
    if (type == "camera") {
      image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 25,
          maxHeight: 600,
          maxWidth: 900);
    } else {
      image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 25,
          maxHeight: 600,
          maxWidth: 900);
    }
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        imageUrl = "";
        base64Image = base64Encode(selectedImage!.readAsBytesSync());
        imageName = selectedImage!.path.split('/').last;
        print("base 64 ${base64Image.length}");
        // won't have any error now
      });
    }
  }

  // <<------ for pick image from gallery or camera...

  /* String getSelectedState() {
    if (getProfileModel.stateId != "" || getProfileModel.stateId != null) {
      var index = stateIdList.indexOf(getProfileModel.stateId!);
      var state = stateList[index];
      _selectedstate = state;
      setState(() {
        if (getProfileModel.stateId != null) {
          var index = stateIdList.indexOf(getProfileModel.stateId!);
          var state = stateList[index];
          _selectedstate = state;
          _state = state;
          print("selected ${_selectedstate}");
        }
      });
    }
    return _selectedstate!;
  }

  String getSelectedCity() {
    if (getProfileModel.cityId != "" || getProfileModel.cityId != null) {
      var index = cityIdList.indexOf(getProfileModel.cityId!);
      var city = cityList[index];
      _selectedcity = city;
      */ /*setState(() {
      });*/ /*
    }
    return _selectedcity!;
  }*/

  bool checkState() {
    if (_state == "") {
      setState(() {
        _stateDropdownError = Strings.requiredStr;
      });
      return false;
    } else {
      setState(() {
        _stateDropdownError = "";
      });
      return true;
    }
  }

  bool checkCity() {
    print("_city ${_city}");
    if (_city == "") {
      setState(() {
        _cityDropdownError = Strings.requiredStr;
      });
      return false;
    } else {
      setState(() {
        _cityDropdownError = "";
      });
      return true;
    }
  }

  bool checkGender() {
    if (_gender == 0) {
      setState(() {
        _genderDropdownError = Strings.requiredStr;
      });
      return false;
    } else {
      setState(() {
        _genderDropdownError = "";
      });
      return true;
    }
  }

  apiGetState() async {
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiState().then((it) {
        if (it.status == "SUCCESS") {
          print("response data${it.data}");
          for (int i = 0; i < it.data!.length; i++) {
            stateList.add(it.data![i].name!);
            stateIdList.add(it.data![i].id!);
          }

          if (stateCityCheck) {
            if (getProfileModel.stateId != null) {
              var index = stateIdList.indexOf(getProfileModel.stateId!);
              var state = stateList[index];
              _selectedstate = state;
              _state = state;
              print("selected ${_selectedstate}");
            }
          } else {
            if (stateId != "") {
              var index = stateIdList.indexOf(stateId);
              var state = stateList[index];
              _selectedstate = state;
              _state = state;
              print("selected after  ${_selectedstate}");
            }
          }
          apiGetCity(stateId);
          // Fluttertoast.showToast(msg: it.message.toString());
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
        }

        print("responseSuccess $it");
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

  apiGetCity(String stateId) async {
    print("requeststateId ${stateId}");
    Map<String, dynamic> map = {
      "state_id": stateId,
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiCity(map).then((it) {
        if (it.status == "SUCCESS") {
          cityList.clear();
          cityIdList.clear();
          for (int i = 0; i < it.data!.length; i++) {
            cityList.add(it.data![i].name!);
            cityIdList.add(it.data![i].id!);
          }
          setState(() {
            isLoading = false;
            print("responsegetprofile $getProfileCalled");
            if (getProfileCalled == true) {
              // showData();
              if (stateCityCheck) {
                if (getProfileModel.cityId != null) {
                  var index = cityIdList.indexOf(getProfileModel.cityId!);
                  var city = cityList[index];
                  _selectedcity = city;
                  _city = city;
                  print("selected ${_selectedcity}");
                }
              } else {
                if (cityId != "") {
                  var index = cityIdList.indexOf(cityId);
                  var city = cityList[index];
                  _selectedcity = city;
                  _city = city;
                  print("selected after ${_selectedcity}");
                }
              }
              getProfileCalled = false;
            } else {
              setState(() {
                _selectedcity = "";
                cityId = "";
              });
              print("on else");
            }
          });
          //  Fluttertoast.showToast(msg: it.message.toString());
        } else if (it.status == "FAILURE") {
          cityList.clear();
          cityIdList.clear();
          setState(() {
            isLoading = false;
          });
          getProfileCalled == false;
          // Fluttertoast.showToast(msg: it.message.toString());
          // Fluttertoast.showToast(msg: "city failure caleed $getProfileCalled");
        }
        print("responseSuccess $it");
      }).catchError((Object obj) {
        cityList.clear();
        cityIdList.clear();
        setState(() {
          isLoading = false;
        });
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

  getProfileViaApi() async {
    getProfileCalled = true;
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetProfile(map).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());

          getProfileModel = GetProfileModel.fromJson(realData);

          if (stateCityCheck) {
            if (getProfileModel.stateId == "" ||
                getProfileModel.stateId == null) {
              stateId = "";
              cityId = "";
            } else {
              setState(() {
                stateId = getProfileModel.stateId!;
                cityId = getProfileModel.cityId!;

                print("selected stateid before $stateId");
                print("selected cityid before $cityId");
              });
            }
          } else {
            print("selected stateid after $stateId");
            print("selected cityid after $cityId");
          }

          if (firstName!.isNotEmpty) {
            firstNameController.text = firstName!;
          } else if (getProfileModel.firstName == "" ||
              getProfileModel.firstName == null) {
            firstNameController.text = "";
          } else {
            firstNameController.text = getProfileModel.firstName!.replaceFirst(
                getProfileModel.firstName![0],
                getProfileModel.firstName![0].toUpperCase());
          }

          if (lastName!.isNotEmpty) {
            lastNameController.text = lastName!;
          } else if (getProfileModel.lastName == "" ||
              getProfileModel.lastName == null) {
            lastNameController.text = "";
          } else {
            lastNameController.text = getProfileModel.lastName!.replaceFirst(
                getProfileModel.lastName![0],
                getProfileModel.lastName![0].toUpperCase());
          }

          if (address!.isNotEmpty) {
            addressController.text = address!;
          } else if (getProfileModel.address == "" ||
              getProfileModel.address == null) {
            addressController.text = "";
          } else {
            addressController.text = getProfileModel.address!;
          }

          if (pinCode!.isNotEmpty) {
            pinCodeController.text = pinCode!;
          } else if (getProfileModel.pincode == "" ||
              getProfileModel.pincode == null) {
            pinCodeController.text = "";
          } else {
            pinCodeController.text = getProfileModel.pincode!;
          }

          if (dob!.isNotEmpty) {
            dobController.text = dob!;
          } else if (getProfileModel.dob == null || getProfileModel.dob == "") {
            dobController.text = "";
          } else {
            dobController.text = getProfileModel.dob!;
          }

          if (email!.isNotEmpty) {
            emailController.text = email!;
            print("value if ${email}");
          } else if (getProfileModel.email == "" ||
              getProfileModel.email == null) {
            emailController.text = "";
            print("value else if ${getProfileModel.email}");
          } else {
            emailController.text = getProfileModel.email!;
          }

          if (mobile!.isNotEmpty) {
            phoneNoController.text = mobile!;
          } else if (getProfileModel.mobileNo == "" ||
              getProfileModel.mobileNo == null) {
            phoneNoController.text = "";
          } else {
            phoneNoController.text = getProfileModel.mobileNo.toString();
          }

          if (getProfileModel.gender != null) {
            var genderTYpe = getProfileModel.gender;
            _gender = genderTYpe!;
          }

          if (haveChild!.isNotEmpty) {
            isChildren = haveChild!;
          } else if (getProfileModel.children != "" ||
              getProfileModel.children != null) {
            var children = getProfileModel.children.toString();
            isChildren = children;
          }

          if (getProfileModel.image != "") {
            imageUrl = getProfileModel.image!;
          }

          apiGetState();
          print("real data $realData");
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
        }
        print("responseSuccess $it");
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

  emailVerify(int type, String email) async {
    Map<String, dynamic> map = {
      "type": type,
      "email": email,
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "otp": "",
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient()
          .apiEmailVerify(DataEncryption.getEncryptedData(map))
          .then((it) {
        if (it.status == "SUCCESS") {
          // var realData = DataEncryption.getDecryptedData(
          //     it.data!.reqKey.toString(), it.data!.reqData.toString());
          print("real data ${it.message}");

          FocusScope.of(context).unfocus();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VerificationEmailPhoneScreen(
                location: "email", emailPhone: email);
          })).then((value) {
            //do something after resuming screen
            print("selected stateid then $stateId");
            print("selected cityid then $cityId");

            stateCityCheck = false;

            print("selected stateCityCheck then $stateCityCheck");
            getProfileViaApi();
          });
          ;

          /*SharedPrefProvider.setString(
              SharedPrefProvider.uniqueToken, realData["revuer_token"]);
          SharedPrefProvider.setString(SharedPrefProvider.mobileNumber,
              realData["mobile_no"].toString());
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              "${realData["first_name"]} ${realData["last_name"]}");
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          widget.location == "signup"
              ? Navigator.pushReplacementNamed(context, '/personalinfo')
              : Navigator.pushReplacementNamed(context, '/main');

          Map<String, dynamic> trendingBody = {"type": 1, "page": 0};
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
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
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
  }

  phoneVerify(int type, String phone) async {
    Map<String, dynamic> map = {
      "type": type,
      "mobile_no": phone,
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "otp": "",
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      await ApiClient.getClient()
          .apiMobileNumberVerify(DataEncryption.getEncryptedData(map))
          .then((it) {
        if (it.status == "SUCCESS") {
          // var realData = DataEncryption.getDecryptedData(
          //     it.data!.reqKey.toString(), it.data!.reqData.toString());
          print("real data ${it.message}");

          FocusScope.of(context).unfocus();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VerificationEmailPhoneScreen(
                location: "phone", emailPhone: phone);
          })).then((value) {
            //do something after resuming screen
            print("then called");
            print("selected stateid then $stateId");
            print("selected cityid then $cityId");

            stateCityCheck = false;

            print("selected stateCityCheck then $stateCityCheck");
            getProfileViaApi();
          });
          ;

          /*SharedPrefProvider.setString(
              SharedPrefProvider.uniqueToken, realData["revuer_token"]);
          SharedPrefProvider.setString(SharedPrefProvider.mobileNumber,
              realData["mobile_no"].toString());
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              "${realData["first_name"]} ${realData["last_name"]}");
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          widget.location == "signup"
              ? Navigator.pushReplacementNamed(context, '/personalinfo')
              : Navigator.pushReplacementNamed(context, '/main');

          Map<String, dynamic> trendingBody = {"type": 1, "page": 0};
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
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
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
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getProfileViaApi();
  }

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/campaign-details');
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
              child: isLoading == false
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              "Step 1 : ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              "Revuer Details",
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
                        StepIndicator(totalStep: 3, step: 1),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 80.0),
                            padding: const EdgeInsets.all(16.0),
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
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: [
                                Form(
                                  key: _formKey1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ClipOval(child: showImage()),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                const Flexible(
                                                  child: Text(
                                                    "Capture or select an image from gallery",
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: secondaryColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8.0,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: ((builder) =>
                                                      bottomSheetImage()));
                                            },
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/icons/camera.png',
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.firstName),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      CustomTextField(
                                        validator: (value) {
                                          if (value!
                                              .toString()
                                              .trim()
                                              .isEmpty) {
                                            return Strings.requiredStr;
                                          } else if (value
                                              .contains(RegExp(emojiRegex))) {
                                            return "Emojis not acceptable";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        textCaps: TextCapitalization.sentences,
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                        textController: firstNameController,
                                        placeholder: 'Type here',
                                        maxLength: 256,
                                        onChanged: (value) {
                                          firstName = value;
                                        },
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.lastName),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      CustomTextField(
                                        validator: (value) {
                                          if (value!
                                              .toString()
                                              .trim()
                                              .isEmpty) {
                                            return Strings.requiredStr;
                                          } else if (value
                                              .contains(RegExp(emojiRegex))) {
                                            return "Emojis not acceptable";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        textCaps: TextCapitalization.sentences,
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                        textController: lastNameController,
                                        placeholder: 'Type here',
                                        maxLength: 256,
                                        onChanged: (value) {
                                          lastName = value;
                                        },
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.address),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      CustomTextField(
                                        validator: (value) {
                                          if (value!
                                              .toString()
                                              .trim()
                                              .isEmpty) {
                                            return Strings.requiredStr;
                                          } else if (value.contains(
                                              RegExp(emojiRegex))) {
                                            return "Emojis not acceptable";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType:
                                        TextInputType.text,
                                        boxShadowColor: Colors.black
                                            .withOpacity(0.04),
                                        blurRadius: 8.0,
                                        textController:
                                        addressController,
                                        placeholder: 'Type here',
                                        maxLength: 256,
                                        onChanged: (value) {
                                          address = value;
                                        },
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.state),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      FindDropdown(
                                        key: statesKey,
                                        items: stateList,
                                        onChanged: (item) {
                                          _state = item.toString();
                                          print('state ${_state}');
                                          stateIndex = stateList.indexWhere(
                                              (element) => element == item);
                                          print('state index ${stateIndex}');
                                          stateId = stateIdList[stateIndex];
                                          apiGetCity(stateId);
                                          _stateDropdownError = "";
                                          citiesKey.currentState
                                              ?.setSelectedItem(null);
                                          _city = "";
                                        },
                                        selectedItem: _selectedstate == ""
                                            ? null
                                            : _selectedstate,
                                        showSearchBox: true,
                                        backgroundColor: Colors.white,
                                        placeholder: 'Select State',
                                        label: 'Select State',
                                        labelVisible: false,
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                      ),
                                      setStateError(),
                                      Row(children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                            const LabelWidget(
                                                labelText: Strings.city),
                                            const SizedBox(
                                              height: 4.0,
                                            ),
                                            FindDropdown(
                                              key: citiesKey,
                                              items: cityList,
                                              onChanged: (item) {
                                                _city = item.toString();
                                                _cityDropdownError = "";
                                                // citiesKey.currentState
                                                //     ?.setSelectedItem(<String>[]);
                                                cityIndex = cityList.indexWhere(
                                                        (element) => element == item);
                                                cityId = cityIdList[cityIndex];
                                              },
                                              selectedItem: _selectedcity == ""
                                                  ? null
                                                  : _selectedcity,
                                              showSearchBox: true,
                                              backgroundColor: Colors.white,
                                              placeholder: 'Select City',
                                              label: 'Select City',
                                              labelVisible: false,
                                              boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                              blurRadius: 8.0,
                                            ),
                                            setCityError(),
                                          ],),
                                        ),
                                        const SizedBox(width: 10.0,),
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                const LabelWidget(
                                                    labelText:
                                                    Strings.pinCode),
                                                const SizedBox(
                                                  height: 6.0,
                                                ),
                                                CustomTextField(
                                                  validator: (value) {
                                                    if (value!
                                                        .toString()
                                                        .trim()
                                                        .isEmpty) {
                                                      return Strings
                                                          .requiredStr;
                                                    } else if (value.length < 6) {
                                                      return "* Invalid";
                                                    } else if (value
                                                        .contains(RegExp(
                                                        emojiRegex))) {
                                                      return "Emojis not acceptable";
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  keyboardType:
                                                  TextInputType
                                                      .number,
                                                  boxShadowColor: Colors
                                                      .black
                                                      .withOpacity(0.04),
                                                  blurRadius: 8.0,
                                                  textController:
                                                  pinCodeController,
                                                  placeholder:
                                                  'Type here',
                                                  maxLength: 6,
                                                  onChanged: (value) {
                                                    pinCode = value;
                                                  },
                                                ),
                                              ],
                                            )
                                        )
                                      ],),
                                      const LabelWidget(labelText: Strings.dob),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      CustomTextField(
                                        isSuffixImg: true,
                                        imgSuffixIcon: Container(
                                          margin:
                                              const EdgeInsets.only(right: 1.0),
                                          padding: const EdgeInsets.all(14.0),
                                          child: Image.asset(
                                              'assets/icons/calendar.png',
                                              width: 16.2,
                                              height: 18.0,
                                              fit: BoxFit.fill),
                                        ),
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                        textController: dobController,
                                        placeholder: 'Select Date',
                                        validator: (value) {
                                          if (value == "") {
                                            return Strings.requiredStr;
                                          } else if (isAdult(value!) < 15) {
                                            return "You are under age";
                                          } else {
                                            return null;
                                          }
                                        },
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1950),
                                            //DateTime.now() - not to allow to choose before today.
                                            lastDate: DateTime.now(),
                                            builder: (context, child) {
                                              return Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                    primary: primaryColor,
                                                    // <-- SEE HERE
                                                    onPrimary: Colors.white,
                                                    // <-- SEE HERE
                                                    onSurface:
                                                        secondaryColor, // <-- SEE HERE
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      primary:
                                                          secondaryColor, // button text color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedDate != null) {
                                            print(
                                                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                            String formattedDate =
                                                DateFormat('MMMM d, y')
                                                    .format(pickedDate);
                                            print(
                                                formattedDate); //formatted date output using intl package =>  2021-03-16
                                            setState(() {
                                              dob = formattedDate;
                                              dobController.text =
                                                  formattedDate; //set output date to TextField value.
                                            });
                                          } else {}
                                        },
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.gender),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  setState(() => _gender = 1),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: _gender == 1
                                                          ? primaryColor
                                                          : grayColor,
                                                      width:
                                                          1, //                   <--- border width here
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.04),
                                                        spreadRadius: 0,
                                                        blurRadius: 8.0,
                                                        offset:
                                                            const Offset(0, 0),
                                                      )
                                                    ]),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'assets/icons/male.png',
                                                        width: 18.0,
                                                        height: 18.0,
                                                        fit: BoxFit.fitWidth),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                      'Male',
                                                      style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight: _gender ==
                                                                  1
                                                              ? FontWeight.w500
                                                              : FontWeight.w400,
                                                          color: _gender == 1
                                                              ? secondaryColor
                                                              : thirdColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  setState(() => _gender = 2),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: _gender == 2
                                                          ? primaryColor
                                                          : grayColor,
                                                      width:
                                                          1, //                   <--- border width here
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.04),
                                                        spreadRadius: 0,
                                                        blurRadius: 8.0,
                                                        offset:
                                                            const Offset(0, 0),
                                                      )
                                                    ]),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'assets/icons/female.png',
                                                        width: 18.0,
                                                        height: 18.0,
                                                        fit: BoxFit.fitWidth),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                      'Female',
                                                      style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight: _gender ==
                                                                  2
                                                              ? FontWeight.w500
                                                              : FontWeight.w400,
                                                          color: _gender == 2
                                                              ? secondaryColor
                                                              : thirdColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () =>
                                                  setState(() => _gender = 3),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: _gender == 3
                                                          ? primaryColor
                                                          : grayColor,
                                                      width:
                                                          1, //                   <--- border width here
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.04),
                                                        spreadRadius: 0,
                                                        blurRadius: 8.0,
                                                        offset:
                                                            const Offset(0, 0),
                                                      )
                                                    ]),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'assets/icons/other.png',
                                                        width: 18.0,
                                                        height: 18.0,
                                                        fit: BoxFit.fitWidth),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(
                                                      'Other',
                                                      style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight: _gender ==
                                                                  3
                                                              ? FontWeight.w500
                                                              : FontWeight.w400,
                                                          color: _gender == 3
                                                              ? secondaryColor
                                                              : thirdColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      setGenderError(),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      const Text(
                                        "Contact Info",
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 16.0,
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.emailAddress),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      CustomTextField(
                                        textController: emailController,
                                        isSuffixImg: true,
                                        imgSuffixIcon: GestureDetector(
                                          onTap: () {},
                                          child: getEmailVerification(),
                                        ),
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                        placeholder: 'Type here',
                                        maxLength: 256,
                                        onChanged: (value) {
                                          email = value;
                                        },
                                        validator: (value) {
                                          if (value!
                                              .toString()
                                              .trim()
                                              .isEmpty) {
                                            return Strings.requiredStr;
                                          } else if (!RegExp(
                                                  "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                              .hasMatch(value)) {
                                            return 'Please enter a valid Email';
                                          } else {
                                            return null;
                                          }
                                        },
                                        readOnly:
                                            getProfileModel.emailVerifyStatus ==
                                                    1
                                                ? true
                                                : false,
                                      ),
                                      const LabelWidget(
                                          labelText: Strings.phoneNoLabel),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      CustomTextField(
                                        textController: phoneNoController,
                                        isImg: true,
                                        imgIcon: Container(
                                          height: 50.0,
                                          margin:
                                              const EdgeInsets.only(left: 15.0),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0),
                                          child: const Text(
                                            '+91 ',
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        isSuffixImg: true,
                                        imgSuffixIcon: GestureDetector(
                                            onTap: () {},
                                            child:
                                                getPhoneVerification() /*Container(
                                      height: 50.0,
                                      margin: const EdgeInsets.only(right: 15.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/icons/check.png',
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.fill
                                          ),
                                          const SizedBox(width: 8.0,),
                                          const Text(
                                            'Verified',
                                            style: TextStyle(color: secondaryColor, fontSize: 14.0, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),*/
                                            ),
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                        placeholder: 'Type here',
                                        digitOnly: true,
                                        keyboardType: TextInputType.number,
                                        maxLength: 10,
                                        onChanged: (value) {
                                          mobile = value;
                                        },
                                        validator: (value) {
                                          if (value!
                                              .toString()
                                              .trim()
                                              .isEmpty) {
                                            return Strings.requiredStr;
                                          } else if (value
                                                  .toString()
                                                  .trim()
                                                  .length <
                                              10) {
                                            return "* Please enter a valid number";
                                          } else {
                                            return null;
                                          }
                                        },
                                        readOnly: getProfileModel
                                                    .mobileVerifyStatus ==
                                                1
                                            ? true
                                            : false,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
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
                  if (_formKey1.currentState!.validate() &&
                      checkState() &&
                      checkCity() &&
                      checkGender()) {
                    print("printed ${firstNameController.text}");
                    print("printed ${lastNameController.text}");
                    print("printed ${_state}");
                    print("printed ${_city}");
                    print("printed ${dobController.text}");
                    print("printed ${_gender}");
                    updateProfileViaApi(
                        firstNameController.text.trim(),
                        lastNameController.text.trim(),
                        addressController.text.trim(),
                        stateId,
                        cityId,
                        pinCodeController.text.trim(),
                        dobController.text,
                        _gender,
                        emailController.text.trim(),
                        int.parse(isChildren),
                        base64Image,
                        imageName);
                  } else {
                    heavyImpact();
                    Fluttertoast.showToast(
                        msg: "Please fill all required fields");
                  }
                  // Navigator.pushReplacementNamed(context, '/social-profiles');
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget showImage() {
    print("image url ${imageUrl}");
    print("image url base64 ${base64Image}");
    if (imageUrl != "") {
      return Image.network(
        imageUrl,
        width: 78.0,
        height: 78.0,
        fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return SizedBox(
              width: 78.0,
              height: 78.0,
              child: Image.asset(
                width: 78.0,
                height: 78.0,
                'assets/images/error_image.png',
                fit: BoxFit.cover,),
            );}
      );
    } else if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        width: 78.0,
        height: 78.0,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 78.0,
        height: 78.0,
        color: primaryColor,
        child: Center(
            child: getProfileModel.firstName!.isNotEmpty
                ? Text(
                    "${getProfileModel.firstName![0].toUpperCase()}",
                    style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 45,
                        fontFamily: "Poppins"),
                  )
                : Text(
                    "R",
                    style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 45,
                        fontFamily: "Poppins"),
                  )),
      );
      /*Image.asset(
        'assets/images/dummy_avtar.png',
        width: 78.0,
        height: 78.0,
        fit: BoxFit.cover,
      );*/
    }
  }

  static Future<void> heavyImpact() async {
    await SystemChannels.platform.invokeMethod<void>('HapticFeedback.vibrate');
  }

  double isAdult(String enteredAge) {
    var birthDate = DateFormat('MMMM d, yyyy').parse(enteredAge);
    print("set state: $birthDate");
    var today = DateTime.now();

    final difference = today.difference(birthDate).inDays;
    print(difference);
    final year = difference / 365;
    print(year);
    return year;
  }

  Widget bottomSheetImage() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  chooseImage("camera");
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.camera_alt,
                      color: secondaryColor,
                    ),
                    SizedBox(width: 8),
                    Text("Camera")
                  ],
                ),
              ),
              SizedBox(width: 25),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  chooseImage("Gallery");
                },
                child: Row(
                  children: const [
                    Icon(
                      Icons.image,
                      color: secondaryColor,
                    ),
                    SizedBox(width: 8),
                    Text("Gallery")
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget setCityError() {
    if (_city == "") {
      return Text(
        _cityDropdownError,
        style: const TextStyle(color: Colors.red),
      );
    } else {
      return const SizedBox(height: 15.0);
    }
  }

  Widget setStateError() {
    if (_state == "") {
      return Text(
        _stateDropdownError,
        style: const TextStyle(color: Colors.red),
      );
    } else {
      return const SizedBox(height: 15.0);
    }
  }

  Widget setGenderError() {
    if (_gender == 0) {
      return Text(
        _genderDropdownError,
        style: const TextStyle(color: Colors.red),
      );
    } else {
      return const SizedBox(height: 0.0);
    }
  }

  Widget getEmailVerification() {
    if (getProfileModel.emailVerifyStatus == 1) {
      return Container(
        height: 50.0,
        margin: const EdgeInsets.only(right: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/icons/check.png',
                width: 20.0, height: 20.0, fit: BoxFit.fill),
            const SizedBox(
              width: 8.0,
            ),
            const Text(
              'Verified',
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 50.0,
        margin: const EdgeInsets.only(right: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                print("email setup ${emailController.text.toString()}");

                if (emailController.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter email");
                } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                    .hasMatch(emailController.text.toString())) {
                  Fluttertoast.showToast(msg: "Please enter a valid email");
                } else {
                  emailVerify(1, emailController.text.trim().toString());
                }
              },
              child: const Text("Verify Now",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            )
          ],
        ),
      );
    }
  }

  Widget getPhoneVerification() {
    if (getProfileModel.mobileVerifyStatus == 1) {
      return Container(
        height: 50.0,
        margin: const EdgeInsets.only(right: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/icons/check.png',
                width: 20.0, height: 20.0, fit: BoxFit.fill),
            const SizedBox(
              width: 8.0,
            ),
            const Text(
              'Verified',
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 50.0,
        margin: const EdgeInsets.only(right: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                print("email setup ${emailController.text.toString()}");

                if (phoneNoController.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter phone number");
                } else if (phoneNoController.text.length < 10) {
                  Fluttertoast.showToast(msg: "Please enter a valid number");
                } else {
                  phoneVerify(1, phoneNoController.text.trim().toString());
                }
              },
              child: const Text("Verify Now",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            )
          ],
        ),
      );
    }
  }

  void updateProfileViaApi(
      String firstName,
      String lastName,
      String address,
      String stateId,
      String cityId,
      String pinCode,
      String dob,
      int gender,
      String email,
      int children,
      String imageUrl,
      String imageName) async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      //from share preference
      "image": imageUrl,
      "image_name": imageName,
      "first_name": firstName,
      "last_name": lastName,
      "address": address,
      "state_id": stateId,
      "city_id": cityId,
      "pincode": pinCode,
      "dob": dob,
      "gender": gender,
      "email": email,
      "children": children,
      "mobile_no": phoneNoController.text.trim().toString(),
      //from share preference
    };

    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        if (it.status == "SUCCESS") {
          Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          print("real data $realData");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              realData["first_name"] + " " + realData["last_name"]);
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          // Navigator.pushReplacementNamed(context, '/welcome');
          Navigator.pushReplacementNamed(context, '/social-profiles');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
        }
        print("responseSuccess $it");
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
}
