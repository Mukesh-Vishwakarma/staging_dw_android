import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/DataEncryption.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../../dropdown/find_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../networking/api_client.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/button_widget.dart';

import 'package:flutter/services.dart';

import '../social/social_after_personal_info.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey1 = GlobalKey<FormState>();
  var statesKey = GlobalKey<FindDropdownState>();
  var citiesKey = GlobalKey<FindDropdownState>();
  var _state = "";
  var _stateDropdownError = "";
  var _city = "";
  var _cityDropdownError = "";

  double statusBarHeight = 5.0;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController referCodeController = TextEditingController();

  int _gender = 0;
  var _genderDropdownError = "";
  bool isValidCode = false;
  bool isShowIcon = false;
  String referralName = "";
  String referralRevuerToken = "";

  final emojiRegex =
      '(\ud83c|[\udf00-\udfff]|\ud83d|[\udc00-\ude4f]|\ud83d|[\ude80-\udeff])';

  // for pick image from gallery or camera ------->>
  File? selectedImage;
  String base64Image = "";
  String imageName = "";
  String imageUrl = "";
  bool isApiCalled = true;

  Future<void> chooseImage(type) async {
    // ignore: prefer_typing_uninitialized_variables
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

  /*final stateList = <StateData>[];*/
  final List<String> stateList = [];
  final List<String> stateIdList = [];
  final List<String> cityList = [];
  final List<String> cityIdList = [];
  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();
  int referLength = 6;

  int stateIndex = 0;
  int cityIndex = 0;

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

  apiGetCity(int stateIndex) async {
    var stateId = stateIdList[stateIndex];
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
          // Fluttertoast.showToast(msg: it.message.toString());
        } else if (it.status == "FAILURE") {
          cityList.clear();
          cityIdList.clear();
          Fluttertoast.showToast(msg: it.message.toString());
        }
        print("responseSuccess $it");
      }).catchError((Object obj) {
        cityList.clear();
        cityIdList.clear();
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

  getRevuerDetails() async {
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          revuerDetailsModel = RevuerDetailsModel.fromJson(realData);

          if (revuerDetailsModel.revuerData!.firstName!.isNotEmpty) {
            setState(() {
              firstNameController.text =
                  revuerDetailsModel.revuerData!.firstName!.replaceFirst(
                      revuerDetailsModel.revuerData!.firstName![0],
                      revuerDetailsModel.revuerData!.firstName![0]
                          .toUpperCase());
            });
          }

          if (revuerDetailsModel.revuerData!.lastName!.isNotEmpty) {
            setState(() {
              lastNameController.text = revuerDetailsModel.revuerData!.lastName!
                  .replaceFirst(
                      revuerDetailsModel.revuerData!.lastName![0],
                      revuerDetailsModel.revuerData!.lastName![0]
                          .toUpperCase());
            });
          }

          if (revuerDetailsModel.revuerData!.image != "" ||
              revuerDetailsModel.revuerData!.image != null) {
            setState(() {
              imageUrl = revuerDetailsModel.revuerData!.image!;
            });
          }

          if (revuerDetailsModel.revuerData?.refer_length != null) {
            setState(() {
              referLength =
                  int.parse(revuerDetailsModel.revuerData!.refer_length!);
            });
          }

          print("real data $realData");
          print("responseSuccess $it");
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          print("responseFailure $it");
        }
      }).catchError((Object obj) {
        setState(() {
          isApiCalled = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption ${obj}");
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

  verifyReferCode(String referCode) async {
    Map<String, dynamic> map = {
      "refer_code": referCode //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiVerifyReferCode(map).then((it) {
        if (it.status == "SUCCESS") {
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          setState(() {
            isValidCode = true;
            isShowIcon = true;
            referralName = realData["revuer_name"];
            referralRevuerToken = realData["revuer_token"];
          });
          print("real data refer code $realData");
          print("responseSuccess refer code $it");
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          setState(() {
            isValidCode = false;
            isShowIcon = true;
            referralName = "";
          });
          print("responseFailure refer code $it");
        }
      }).catchError((Object obj) {
        setState(() {
          isApiCalled = false;
          referralName = "";
          isValidCode = false;
          isShowIcon = true;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption refer code ${obj}");
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
    apiGetState();
    getRevuerDetails();
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: ClipPath(
                          clipper: OvalClipper(),
                          child: Container(
                            width: double.infinity,
                            height: 242.0,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      /*Positioned(
                        top: statusBarHeight + 24.0,
                        right: 16.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/welcome');
                          },
                          child: const Text(
                            'SKIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),*/
                      Padding(
                        /*top: 90.0,
                        left: 16.0,
                        right: 16.0,*/
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 90.0, 16.0, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              Strings.personalInfoTitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: const AutoSizeText(
                                Strings.personalInfoSubTitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Container(
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
                              child: Form(
                                key: _formKey1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                            padding: const EdgeInsets.all(8.0),
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
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                                    .toString()
                                                    .trim()
                                                    .length <
                                                2) {
                                              return "First name should have at-least two character";
                                            } else if (value
                                                .contains(RegExp(emojiRegex))) {
                                              return "Emojis not acceptable";
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                          textCaps:
                                              TextCapitalization.sentences,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          textController: firstNameController,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          onChanged: (value) {},
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                                    .toString()
                                                    .trim()
                                                    .length <
                                                2) {
                                              return "Last name should have at-least two character";
                                            } else if (value
                                                .contains(RegExp(emojiRegex))) {
                                              return "Emojis not acceptable";
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                          textCaps:
                                              TextCapitalization.sentences,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          textController: lastNameController,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          onChanged: (value) {},
                                        ),
                                      ],
                                    ),
                                    const LabelWidget(
                                        labelText: Strings.address),
                                    const SizedBox(
                                      height: 6.0,
                                    ),
                                    CustomTextField(
                                      validator: (value) {
                                        if (value!.toString().trim().isEmpty) {
                                          return null;
                                        } else if (value
                                            .contains(RegExp(emojiRegex))) {
                                          return "Emojis not acceptable";
                                        } else {
                                          return null;
                                        }
                                      },
                                      keyboardType: TextInputType.text,
                                      boxShadowColor:
                                          Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      textController: addressController,
                                      placeholder: 'Type here',
                                      maxLength: 256,
                                    ),
                                    const LabelWidget(labelText: Strings.state),
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
                                        apiGetCity(stateIndex);
                                        _stateDropdownError = "";
                                        // print('state ${statesKey.currentState?.widget.selectedItem}');
                                        citiesKey.currentState
                                            ?.setSelectedItem(null);
                                        _city = "";
                                      },
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
                                    // const SizedBox(height: 15.0,),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  cityIndex = cityList
                                                      .indexWhere((element) =>
                                                          element == item);
                                                },
                                                showSearchBox: true,
                                                backgroundColor: Colors.white,
                                                placeholder: 'Select City',
                                                label: 'Select City',
                                                labelVisible: false,
                                                boxShadowColor: Colors.black
                                                    .withOpacity(0.04),
                                                blurRadius: 8.0,
                                              ),
                                              setCityError(),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const LabelWidget(
                                                labelText: Strings.pinCode),
                                            const SizedBox(
                                              height: 6.0,
                                            ),
                                            CustomTextField(
                                              validator: (value) {
                                                if (value!
                                                    .toString()
                                                    .trim()
                                                    .isEmpty) {
                                                  return null;
                                                } else if (value.length < 6) {
                                                  return "* Invalid";
                                                } else if (value.contains(
                                                    RegExp(emojiRegex))) {
                                                  return "Emojis not acceptable";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              boxShadowColor: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 8.0,
                                              textController: pinCodeController,
                                              placeholder: 'Type here',
                                              maxLength: 6,
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                    // const SizedBox(height: 15.0,),
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
                                          //DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
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
                                                        fontWeight: _gender == 1
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
                                                        fontWeight: _gender == 2
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
                                                        fontWeight: _gender == 3
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const LabelWidget(
                                            labelText: Strings.referCode),
                                        LabelWidget(labelText: referralName)
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6.0,
                                    ),
                                    CustomTextField(
                                        validator: (value) {
                                          if (value!
                                              .toString()
                                              .trim()
                                              .isEmpty) {
                                            return null;
                                          } else if (value.length <
                                              referLength) {
                                            return "Enter a valid code";
                                          } else if (value
                                              .contains(RegExp(emojiRegex))) {
                                            return "Emojis not acceptable";
                                          } else if (isShowIcon &&
                                              !isValidCode) {
                                            return "Enter a valid code";
                                          } else {
                                            return null;
                                          }
                                        },
                                        onChanged: (value) {
                                          if (value.trim().length ==
                                              referLength) {
                                            verifyReferCode(value);
                                          } else {
                                            setState(() {
                                              isShowIcon = false;
                                              referralName = "";
                                            });
                                          }
                                        },
                                        keyboardType: TextInputType.text,
                                        boxShadowColor:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8.0,
                                        textController: referCodeController,
                                        placeholder: 'Type here',
                                        textCaps: TextCapitalization.characters,
                                        maxLength: referLength,
                                        isSuffixImg: isShowIcon,
                                        imgSuffixIcon: isValidCode
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              )
                                            : const Icon(Icons.cancel,
                                                color: Colors.red)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 28.0,
                            ),
                            isApiCalled
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
                                    buttonText: "SUBMIT",
                                    onPressed: () {
                                      if (_formKey1.currentState!.validate() &&
                                          checkState() &&
                                          checkCity() &&
                                          checkGender()) {
                                        print(
                                            "printed ${firstNameController.text}");
                                        print(
                                            "printed ${lastNameController.text}");
                                        print("printed ${_state}");
                                        print("printed ${_city}");
                                        print("printed ${dobController.text}");
                                        print("printed ${_gender}");
                                        updateProfileViaApi(
                                            firstNameController.text.trim(),
                                            lastNameController.text.trim(),
                                            addressController.text.trim(),
                                            stateIdList[stateIndex],
                                            cityIdList[cityIndex],
                                            dobController.text.trim(),
                                            pinCodeController.text.trim(),
                                            _gender,
                                            base64Image,
                                            imageName);
                                      } else {
                                        heavyImpact();
                                        Fluttertoast.showToast(
                                            msg:
                                                "Please fill all required fields");
                                      }
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
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
              const SizedBox(width: 25),
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
      return const SizedBox(height: 16.0);
    }
  }

  Widget showImage() {
    print("image url ${imageUrl}");
    print("image url base64 ${base64Image}");
    if (isApiCalled) {
      return Shimmer.fromColors(
        baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
        highlightColor: Colors.white,
        child: Container(
          width: 78.0,
          height: 78.0,
          color: Colors.grey,
        ),
      );
    } else {
      if (imageUrl.isNotEmpty) {
        return Image.network(imageUrl,
            width: 78.0,
            height: 78.0,
            fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Shimmer.fromColors(
            baseColor: const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
            highlightColor: Colors.white,
            child: Container(
              width: 41.0,
              height: 41.0,
              color: Colors.grey,
            ),
          );
        }, errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 78.0,
            height: 78.0,
            child: Image.asset(
              width: 78.0,
              height: 78.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else if (selectedImage != null) {
        return Image.file(
          selectedImage!,
          width: 78.0,
          height: 78.0,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          'assets/images/dummy_avtar.png',
          width: 78.0,
          height: 78.0,
          fit: BoxFit.cover,
        );
      }
    }
  }

  void updateProfileViaApi(
      String firstName,
      String lastName,
      String address,
      String stateId,
      String cityId,
      String dob,
      String pinCode,
      int gender,
      String base64image,
      String imageName) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken), //from share preference
      "image": base64Image,
      "image_name": imageName,
      "first_name": firstName,
      "last_name": lastName,
      "address": address,
      "state_id": stateId,
      "city_id": cityId,
      "pincode": pinCode,
      "dob": dob,
      "gender": gender,
      "children": 0,
      "refer_code": referCodeController.text.toString().trim(),
      "refer_revuer_token": referralRevuerToken,
      "mobile_no": await SharedPrefProvider.getString(
          SharedPrefProvider.mobileNumber), //from share preference
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
          SharedPrefProvider.setString(
              SharedPrefProvider.firstName, "${realData["first_name"]}");
          SharedPrefProvider.setString(SharedPrefProvider.fullName,
              "${realData["first_name"]} ${realData["last_name"]}");
          SharedPrefProvider.setString(
              SharedPrefProvider.profileImage, realData["image"]);
          /*Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                const SocialAccountScreenAfterPersonalInfo()),
          );*/
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/social-account-after-personal-info',
              (Route<dynamic> route) => false);
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          setState(() {
            isApiCalled = false;
          });
        }
        print("responseSuccess $it");
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        setState(() {
          isApiCalled = false;
        });
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
      setState(() {
        isApiCalled = false;
      });
    }
  }
}
