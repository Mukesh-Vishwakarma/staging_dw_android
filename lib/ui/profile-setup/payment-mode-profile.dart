import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/ui/profile-setup/privacy-policy.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';
import '../../widgets/label_widget.dart';
import '../../widgets/step-indicator.dart';
import '../../widgets/textfield_widget.dart';

class PaymentModeProfileScreen extends StatefulWidget {
  final String location;
  final int patmentMethod;

  PaymentModeProfileScreen(
      {Key? key, this.patmentMethod = 1, required this.location})
      : super(key: key);

  @override
  State<PaymentModeProfileScreen> createState() =>
      _PaymentModeProfileScreenState();
}

class _PaymentModeProfileScreenState extends State<PaymentModeProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;
  bool upiReadOnly = false;
  bool bankReadOnly = false;

  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
      TextEditingController();
  final TextEditingController ifcCodeController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final _bankFormKey = GlobalKey<FormState>();
  final _upiFormKey = GlobalKey<FormState>();

  void _openMyPage() {
    widget.location == "paymentModeProfile"
        ? Navigator.pushReplacementNamed(context, '/payment-mode')
        : Navigator.pushReplacementNamed(context, '/withdraw-earnings');
  }

  bool isApiCalled = false;
  String upiToken = "";
  String bankToken = "";

  // upi details --------------->>>>
  verifyUpiDetails(String upiId) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": "1",
      "upi_id": upiId,
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveUpiDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseSuccess Upi id $it");
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure  Upi id $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption  Upi id ${obj}");
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

  saveUpiDetails(String upiId) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": "1",
      "upi_id": upiId,
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveUpiDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseSuccess Upi id $it");
          getUpiDetails();
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure  Upi id $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption  Upi id ${obj}");
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

  getUpiDetails() async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": "3",
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveUpiDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          // Fluttertoast.showToast(msg: it["message"].toString());
          if (it["data"] != null) {
            var realData = DataEncryption.getDecryptedData(
                it["data"]["reqKey"], it["data"]["reqData"]);
            setState(() {
              if (realData["upi_id"].toString() != "") {
                upiIdController.text = realData["upi_id"];
                upiToken = realData["upi_token"];
                upiReadOnly = true;
              }
            });
            print("responseSuccess real data Upi id $realData");
          }
          print("responseSuccess Upi id $it");
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure  Upi id $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption  Upi id ${obj}");
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

  updateUpiDetails(String upiId, String upiToken) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": "2",
      "upi_id": upiId,
      "upi_token": upiToken,
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveUpiDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: it["message"].toString());
          getUpiDetails();
          print("responseSuccess Upi id $it");
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure  Upi id $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption  Upi id ${obj}");
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

  // Bank details --------------->>>>
  saveBankDetails(String accHolderName, int accountNumber, String ifcCode,
      String bankName) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "bank_name": bankName,
      "name": accHolderName,
      "account_number": accountNumber,
      "ifsc_code": ifcCode,
      "type": "0",
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveBankDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseSuccess bank details $it");
          getBankDetails();
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure bank details $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption bank details  ${obj}");
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

  getBankDetails() async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "type": "2",
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveBankDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          //  Fluttertoast.showToast(msg: it["message"].toString());
          if (it["data"] != null) {
            var realData = DataEncryption.getDecryptedData(
                it["data"]["reqKey"], it["data"]["reqData"]);
            accountHolderNameController.text = realData["bank_holder_name"];
            accountNumberController.text =
                realData["bank_account_number"].toString();
            confirmAccountNumberController.text =
                realData["bank_account_number"].toString();
            ifcCodeController.text = realData["ifsc_code"];
            bankNameController.text = realData["bank_name"];
            setState(() {
              bankToken = realData["bank_token"];
              bankReadOnly = true;
            });
            print("responseSuccess real data bank $realData");
          }
          print("responseSuccess bank details $it");
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure bank details $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption bank details  ${obj}");
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

  updateBankDetails(String accHolderName, int accountNumber, String ifcCode,
      String bankName, String bankToken) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "bank_name": bankName,
      "name": accHolderName,
      "account_number": accountNumber,
      "ifsc_code": ifcCode,
      "type": "1",
      "bank_token": bankToken,
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient()
          .apiSaveBankDetails(DataEncryption.getEncryptedData(map))
          .then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: it["message"].toString());
          getBankDetails();
          print("responseSuccess bank details $it");
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure bank details $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption bank details  ${obj}");
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

  withdrawRequest(String type) async {
    setState(() {
      isApiCalled = true;
    });
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken), //from share preference
      "type": type
    };
    print("requestParam ${map}");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiWithdrawRequest(map).then((it) {
        setState(() {
          isApiCalled = false;
        });
        if (it["status"] == "SUCCESS") {
          Fluttertoast.showToast(msg: it["message"].toString());
          Navigator.pushReplacementNamed(context, '/earning-history');
          // getUpiDetails();
          /*if(it["data"] !=null){
            var realData = DataEncryption.getDecryptedData(
                it["data"]["reqKey"], it["data"]["reqData"]);
            setState(() {
              if(realData["upi_id"].toString() != ""){
                upiIdController.text = realData["upi_id"];
                upiToken = realData["upi_token"];
                upiReadOnly = true;
              }
            });
            print("responseSuccess real data Upi id $realData");
          }
          print("responseSuccess Upi id $it");*/
        } else if (it["status"] == "FAILURE") {
          Fluttertoast.showToast(msg: it["message"].toString());
          print("responseFailure  withdraw $it");
        }
      }).catchError((Object obj) {
        /*setState(() {
          isApiCalled = false;
        });*/
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        print("responseExecption  Upi id ${obj}");
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
    if (widget.patmentMethod == 1) {
      getUpiDetails();
    } else {
      getBankDetails();
    }
    super.initState();
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _openMyPage(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
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
                  Text(
                    widget.location == "paymentModeProfile"
                        ? Strings.setupProfile
                        : widget.patmentMethod == 1
                            ? Strings.upiDetails
                            : Strings.bankDetails,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  widget.location == "paymentModeProfile"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 7.0),
                              child: Text(
                                "Step 3 : 3",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: StepIndicator(totalStep: 3, step: 3),
                            ),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50.0),
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
                      child: widget.patmentMethod == 1
                          ? Form(
                              key: _upiFormKey,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Enter your new UPI details below: ",
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const LabelWidget(
                                            labelText: Strings.upiId),
                                        upiReadOnly
                                            ? GestureDetector(
                                                child: const Text(
                                                  "EDIT",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                      decoration: TextDecoration
                                                          .underline),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    upiReadOnly = false;
                                                  });
                                                },
                                              )
                                            : const SizedBox(width: 0.0)
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6.0,
                                    ),
                                    CustomTextField(
                                      boxShadowColor:
                                          Colors.black.withOpacity(0.04),
                                      blurRadius: 8.0,
                                      textController: upiIdController,
                                      readOnly: upiReadOnly,
                                      placeholder: 'Type here',
                                      maxLength: 256,
                                      onChanged: (value) {},
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "Please enter UPI Id";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    /* Center(
                                      child: ButtonWidget(
                                        width: 190.0,
                                        buttonText: "VERIFY",
                                        onPressed: () {},
                                      ),
                                    ),*/
                                  ],
                                ),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: [
                                Form(
                                  key: _bankFormKey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Enter your bank details below:",
                                          style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const LabelWidget(
                                                labelText:
                                                    Strings.accHolderName),
                                            bankReadOnly
                                                ? GestureDetector(
                                                    child: const Text(
                                                      "EDIT",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .deepPurpleAccent,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        bankReadOnly = false;
                                                      });
                                                    },
                                                  )
                                                : const SizedBox(width: 0.0)
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textCaps:
                                              TextCapitalization.sentences,
                                          textController:
                                              accountHolderNameController,
                                          readOnly: bankReadOnly,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          onChanged: (value) {},
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return "Please enter account holder's name";
                                            }
                                            return null;
                                          },
                                        ),
                                        const LabelWidget(
                                            labelText: Strings.accNumber),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textController:
                                              accountNumberController,
                                          readOnly: bankReadOnly,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          onChanged: (value) {},
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please enter account number';
                                            }
                                            return null;
                                          },
                                        ),
                                        const LabelWidget(
                                            labelText:
                                                Strings.confirmAccNumber),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textController:
                                              confirmAccountNumberController,
                                          readOnly: bankReadOnly,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {},
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please confirm account number';
                                            } else if (accountNumberController
                                                    .text
                                                    .trim() !=
                                                confirmAccountNumberController
                                                    .text
                                                    .trim()) {
                                              return 'Account number not matches';
                                            }
                                            return null;
                                          },
                                        ),
                                        const LabelWidget(
                                            labelText: Strings.ifscCode),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textCaps:
                                              TextCapitalization.sentences,
                                          textController: ifcCodeController,
                                          readOnly: bankReadOnly,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          onChanged: (value) {},
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please enter IFSC code';
                                            }
                                            return null;
                                          },
                                        ),
                                        const LabelWidget(
                                            labelText: Strings.bankName),
                                        const SizedBox(
                                          height: 6.0,
                                        ),
                                        CustomTextField(
                                          textCaps:
                                              TextCapitalization.sentences,
                                          textController: bankNameController,
                                          readOnly: bankReadOnly,
                                          boxShadowColor:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8.0,
                                          placeholder: 'Type here',
                                          maxLength: 256,
                                          onChanged: (value) {},
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please enter Bank Name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
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
              child: widget.location == "paymentModeProfile"
                  ? ButtonWidget(
                      buttonContent: const Text(
                        "PAY \u{20B9}199",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            settings:
                                const RouteSettings(name: '/privacy-policy'),
                            builder: (context) => PrivacyPolicyScreen(
                                location: "paymentModeProfile",
                                patmentMethod: widget.patmentMethod),
                          ),
                        );
                      },
                    )
                  : isApiCalled
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : chooseButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget chooseButton() {
    if (widget.patmentMethod == 1 && upiReadOnly) {
      return ButtonWidget(
        buttonContent: const Text(
          "SUBMIT",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0),
        ),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => showAppliedCampaignDialog("1"),
          );
          //Navigator.pushReplacementNamed(context, '/social-profiles');
        },
      );
    } else if (widget.patmentMethod == 2 && bankReadOnly) {
      return ButtonWidget(
        buttonContent: const Text(
          "SUBMIT",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0),
        ),
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => showAppliedCampaignDialog("0"),
          );
          //Navigator.pushReplacementNamed(context, '/social-profiles');
        },
      );
    } else {
      return ButtonWidget(
        buttonContent: const Text(
          "SAVE",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0),
        ),
        onPressed: () {
          if (widget.patmentMethod == 1) {
            if (upiToken == "") {
              if (_upiFormKey.currentState!.validate()) {
                saveUpiDetails(upiIdController.text.trim());
              }
            } else {
              if (_upiFormKey.currentState!.validate()) {
                updateUpiDetails(upiIdController.text.trim(), upiToken);
              }
            }
          } else {
            if (bankToken == "") {
              if (_bankFormKey.currentState!.validate()) {
                saveBankDetails(
                    accountHolderNameController.text.trim(),
                    int.parse(accountNumberController.text.trim()),
                    ifcCodeController.text.trim(),
                    bankNameController.text.trim());
              }
            } else {
              if (_bankFormKey.currentState!.validate()) {
                updateBankDetails(
                    accountHolderNameController.text.trim(),
                    int.parse(accountNumberController.text.trim()),
                    ifcCodeController.text.trim(),
                    bankNameController.text.trim(),
                    bankToken);
              }
            }
          }
          //Navigator.pushReplacementNamed(context, '/social-profiles');
        },
      );
    }
  }

  Widget showAppliedCampaignDialog(String type) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: CustomDialog(
        Child: Stack(
          children: [
            Positioned(
              right: 19.0,
              top: 19.0,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset(
                  'assets/icons/close2.png',
                  width: 24.0,
                  height: 24.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    width: 73.0,
                    height: 73.0,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/icons/withdraw.png',
                        width: 35.0,
                        height: 35.0,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  const Text(
                    "Are You sure you want to withdraw\nyour amount...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  /*const Text(
                    "We will notify you as soon as possible",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: thirdColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400),
                  ),*/
                  ButtonWidget(
                      buttonText: "OK",
                      onPressed: () {
                        withdrawRequest(type);
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
