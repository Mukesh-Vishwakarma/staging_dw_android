import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:revuer/networking/models/wallet_history_model.dart';
import 'package:revuer/networking/models/wallet_model.dart';
import 'package:revuer/ui/task/withdraw_full_image_screen.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';
import '../withdraw/withdraw-earnings.dart';
import 'data_repository.dart';
import '../../res/bar_chart_component.dart';

class MyEarningsScreen extends StatefulWidget {
  final String location;

  const MyEarningsScreen({Key? key, this.location = ""}) : super(key: key);

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;

  MyEarningWalletModel walletModel = MyEarningWalletModel();
  WalletHistoryModel walletHistoryModel = WalletHistoryModel();

  List<double> amountData = [];

  List<String> labels = [];

  bool loaded = false;

  String dropdownValueMonths = 'select';
  List<String> dropItemsMonths = [
    'Select Month',
  ];

  String dropdownValueYear = 'selectYear';
  List<String> dropItemsYear = [
    'Select Year',
  ];

  bool isAmountApiCalled = true;
  bool isWalletHistoryCalled = true;

  final RefreshController walletHistoryController =
  RefreshController(initialRefresh: false);

  getWalletAmount() async {
    setState(() {
      isAmountApiCalled = true;
    });
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    if (kDebugMode) {
      print("requestParam WalletAmount$map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetWalletAmount(map).then((it) {
        setState(() {
          isAmountApiCalled = false;
        });
        if (it.status == "SUCCESS") {
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          walletModel = MyEarningWalletModel.fromJson(realData);
          if (walletModel.chartData!.isNotEmpty) {
            labels.clear();
            amountData.clear();
            dropItemsMonths.clear();
            dropItemsYear.clear();
            for (int i = 0; i < walletModel.chartData!.length; i++) {
              var year = walletModel.chartData![i].monthName!.split("~")[1].substring(2, 4);
              labels.add("${walletModel.chartData![i].monthName!.substring(0, 3)} $year");
              amountData.add((walletModel.chartData![i].amount!).toDouble());
            }
            for (int i = 0; i < walletModel.yearName!.length; i++) {
              dropItemsYear.add(walletModel.yearName![i]);
            }
            for (int i = 0; i < walletModel.monthName!.length; i++) {
              dropItemsMonths.add(walletModel.monthName![i].substring(0, 3));
            }
            setState(() {
              dropdownValueMonths = getMonth();
              dropdownValueYear = dropItemsYear[dropItemsYear.length - 1];
            });
            getWalletHistory();
            if (kDebugMode) {
              print("drop_items :- $dropItemsMonths");
            }
            if (kDebugMode) {
              print(
                "chart array:- $amountData , lables:- $labels, length:- ${walletModel.chartData!.length}");
            }
          }
          if (kDebugMode) {
            print("real data WalletAmount$realData");
          }
          if (kDebugMode) {
            print("responseSuccess WalletAmount$it");
          }
        } else if (it.status == "FAILURE") {
          amountData.clear();
          getWalletHistory();
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure WalletAmount$it");
          }
        }
      }).catchError((Object obj) {
        amountData.clear();
        setState(() {
          isAmountApiCalled = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException WalletAmount$obj");
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

  getWalletHistory() async {
    setState(() {
      isWalletHistoryCalled = true;
    });
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken), //from share preference
      "type": getType(),
      "year_name": dropdownValueYear
    };
    if (kDebugMode) {
      print("requestParam WalletHistory $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetWalletHistory(map).then((it) {
        setState(() {
          isWalletHistoryCalled = false;
        });
        if (it.status == "SUCCESS") {
          walletHistoryController.refreshCompleted();
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          walletHistoryModel = WalletHistoryModel.fromJson(realData);
          if (kDebugMode) {
            print("real data WalletHistory $realData");
          }
          if (kDebugMode) {
            print("responseSuccess WalletHistory $it");
          }
        } else if (it.status == "FAILURE") {
          walletHistoryController.refreshCompleted();
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure WalletHistory $it");
          }
        }
      }).catchError((Object obj) {
        walletHistoryController.refreshCompleted();
        setState(() {
          isWalletHistoryCalled = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException WalletHistory $obj");
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

  String getType() {
    if (dropdownValueMonths == "Jan") {
      return "01";
    } else if (dropdownValueMonths == "Feb") {
      return "02";
    } else if (dropdownValueMonths == "Mar") {
      return "03";
    } else if (dropdownValueMonths == "Apr") {
      return "04";
    } else if (dropdownValueMonths == "May") {
      return "05";
    } else if (dropdownValueMonths == "Jun") {
      return "06";
    } else if (dropdownValueMonths == "Jul") {
      return "07";
    } else if (dropdownValueMonths == "Aug") {
      return "08";
    } else if (dropdownValueMonths == "Sep") {
      return "09";
    } else if (dropdownValueMonths == "Oct") {
      return "10";
    } else if (dropdownValueMonths == "Nov") {
      return "11";
    } else {
      return "12";
    }
  }

  String getMonth() {
    var month = DateTime.now().month;
    if (month == 1 ) {
      return "Jan";
    } else if (month == 2 ) {
      return "Feb";
    }else if (month == 3 ) {
      return "Mar";
    } else if (month == 4 ) {
      return "Apr";
    }else if (month == 5 ) {
      return "May";
    } else if (month == 6 ) {
      return "Jun";
    }else if (month == 7 ) {
      return "Jul";
    } else if (month == 8 ) {
      return "Aug";
    } else if (month == 9 ) {
      return "Sep";
    } else if (month == 10 ) {
      return "Oct";
    } else if (month == 11 ) {
      return "Nov";
    } else if (month == 12 ) {
      return "Dec";
    }else{
      return "";
    }
  }

  @override
  void initState() {
    super.initState();
    getWalletAmount();
    // getWalletHistory();
    /*setState(() {
      data = DataRepository.getData();
      labels = DataRepository.getLabels();
    });*/
  }

  void _openMyPage() {
    if (widget.location == "inbox") {
      Navigator.pop(context);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/profile', (Route<dynamic> route) => false);
    }
    //Navigator.pushReplacementNamed(context, '/profile');
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
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16.0, (statusBarHeight + 15.0), 16.0, 0),
                  child: Column(
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
                        Strings.myEarnings,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SmartRefresher(
                    controller: walletHistoryController,
                    onRefresh: () {
                      getWalletHistory();
                      getWalletAmount();
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 20.0),
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/icons/2Xwallet.png',
                                            width: 36.0,
                                            height: 36.0,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(
                                            width: 15.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Your Balance",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 13.0,
                                                    fontWeight:
                                                    FontWeight.w400),
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              isAmountApiCalled
                                                  ? const Text(
                                                "\u{20B9}0",
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              )
                                                  : walletModel.walletBalance ==
                                                  null
                                                  ? const Text(
                                                "\u{20B9}0",
                                                style: TextStyle(
                                                    color:
                                                    secondaryColor,
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .w600),
                                              )
                                                  : Text(
                                                "\u{20B9}${walletModel.walletBalance}",
                                                style: const TextStyle(
                                                    color:
                                                    secondaryColor,
                                                    fontSize: 20.0,
                                                    fontWeight:
                                                    FontWeight
                                                        .w600),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      ButtonWidget(
                                        buttonColor: thirdColor,
                                        width: 130.0,
                                        buttonText: "WITHDRAW",
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const WithdrawEarningsScreen()),
                                          ).then((value) {
                                            getWalletAmount();
                                            getWalletHistory();
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  isAmountApiCalled
                                      ? const SizedBox(
                                    height: 185.0,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    ),
                                  )
                                      : amountData.isNotEmpty
                                      ? SizedBox(
                                    height: 185.0,
                                    child: BarChart(
                                      data: amountData,
                                      labels: labels,
                                      labelStyle: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w400),
                                      valueStyle: const TextStyle(
                                          color: secondaryColor,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w600),
                                      displayValue: true,
                                      reverse: true,
                                      getColor:
                                      DataRepository.getColor,
                                      barWidth: 42,
                                      barSeparation: 16,
                                      animationDuration:
                                      const Duration(
                                          milliseconds: 1000),
                                      animationCurve:
                                      Curves.easeInOutSine,
                                      itemRadius: 4.0,
                                      iconHeight: 24,
                                      footerHeight: 24,
                                      headerValueHeight: 16,
                                      roundValuesOnText: true,
                                      lineGridColor:
                                      Colors.transparent,
                                    ),
                                  )
                                      : noChart()
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Earning History",
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                                dropdownValueYear == 'selectYear'
                                    ? const SizedBox()
                                    : Container(
                                  height: 45.0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                      border: Border.all(
                                          color: grayColor,
                                          style: BorderStyle.solid,
                                          width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              .withOpacity(0.05),
                                          spreadRadius: 0,
                                          blurRadius: 8.0,
                                          offset: const Offset(0, 0),
                                        )
                                      ]),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      value: dropdownValueYear,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down),
                                      items: dropItemsYear
                                          .map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValueYear = newValue!;
                                          getWalletHistory();
                                          if (kDebugMode) {
                                            print("newValue $newValue");
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                dropdownValueMonths == 'select'
                                    ? const SizedBox()
                                    : Container(
                                  height: 45.0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                      border: Border.all(
                                          color: grayColor,
                                          style: BorderStyle.solid,
                                          width: 1.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xff000000)
                                              .withOpacity(0.05),
                                          spreadRadius: 0,
                                          blurRadius: 8.0,
                                          offset: const Offset(0, 0),
                                        )
                                      ]),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      value: dropdownValueMonths,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down),
                                      items: dropItemsMonths
                                          .map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValueMonths = newValue!;
                                          getWalletHistory();
                                          if (kDebugMode) {
                                            print("newValue $newValue");
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            isWalletHistoryCalled
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                                : walletHistoryModel.walletHistory != null &&
                                walletHistoryModel
                                    .walletHistory!.isNotEmpty
                                ? ListView.separated(
                                itemCount: walletHistoryModel
                                    .walletHistory!.length,
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                padding:
                                const EdgeInsets.only(bottom: 12.0),
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                const Divider(
                                  height: 1,
                                  color: grayColor,
                                ),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      if (walletHistoryModel
                                          .walletHistory![index]
                                          .withdrawType ==
                                          1) {
                                        if (walletHistoryModel
                                            .walletHistory![
                                        index]
                                            .status ==
                                            "1" ||
                                            walletHistoryModel
                                                .walletHistory![
                                            index]
                                                .status ==
                                                "2") {
                                          if (walletHistoryModel
                                              .walletHistory![
                                          index]
                                              .message !=
                                              "" ||
                                              walletHistoryModel
                                                  .walletHistory![
                                              index]
                                                  .attachFile !=
                                                  "") {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext
                                              context) =>
                                                  showWithdrawDialog(
                                                      walletHistoryModel
                                                          .walletHistory![
                                                      index]
                                                          .status,
                                                      walletHistoryModel
                                                          .walletHistory![
                                                      index]
                                                          .message,
                                                      walletHistoryModel
                                                          .walletHistory![
                                                      index]
                                                          .attachFile),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          minHeight: 100.0),
                                      margin: const EdgeInsets.only(
                                          top: 10.0),
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 13.0,
                                          horizontal: 20.0),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          const BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                  0xff2A3B53)
                                                  .withOpacity(0.1),
                                              spreadRadius: 0,
                                              blurRadius: 7,
                                              offset:
                                              const Offset(1, 1),
                                            ),
                                            BoxShadow(
                                              color: const Color(
                                                  0xff2A3B53)
                                                  .withOpacity(0.08),
                                              spreadRadius: 0,
                                              blurRadius: 20.0,
                                              offset:
                                              const Offset(0, 0),
                                            )
                                          ]),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          ClipOval(
                                            child: walletHistoryModel
                                                .walletHistory![
                                            index]
                                                .withdrawType ==
                                                1
                                                ? Image.asset(
                                              "assets/images/cash_withdrawal.png",
                                              width: 40.0,
                                              height: 40.0,
                                              fit: BoxFit.cover,
                                            )
                                                : Image.network(
                                                walletHistoryModel
                                                    .walletHistory![
                                                index]
                                                    .image!,
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error,
                                                    stackTrace) {
                                                  return SizedBox(
                                                    width: 41.0,
                                                    height: 41.0,
                                                    child:
                                                    Image.asset(
                                                      width: 41.0,
                                                      height: 41.0,
                                                      'assets/images/error_image.png',
                                                      fit: BoxFit
                                                          .cover,
                                                    ),
                                                  );
                                                }),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text(
                                                  walletHistoryModel
                                                      .walletHistory![
                                                  index]
                                                      .campaignName!,
                                                  style:
                                                  const TextStyle(
                                                    color:
                                                    secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                showStatusWidget(
                                                    walletHistoryModel
                                                        .walletHistory![
                                                    index]),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  walletHistoryModel
                                                      .walletHistory![
                                                  index]
                                                      .date!,
                                                  style:
                                                  const TextStyle(
                                                    color: thirdColor,
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          showAmountWidget(
                                              walletHistoryModel
                                                  .walletHistory![
                                              index])
                                          /* walletHistoryModel
                                                        .walletHistory![index]
                                                        .withdrawStatus ==
                                                    0
                                                ? Text(
                                                    "+ \u{20B9}${walletHistoryModel.walletHistory![index].amount!.toString()}",
                                                    style: const TextStyle(
                                                        color: completedColor,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                : Text(
                                                    "\u{20B9}${walletHistoryModel.walletHistory![index].amount!.toString()}",
                                                    style: const TextStyle(
                                                        color: rejectDarkColor,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),*/
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                : walletHistoryModel.walletHistory == null
                                ? const SizedBox()
                                : noHistory(),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget showStatusWidget(WalletHistory walletHistory) {
    if (walletHistory.withdrawType == 1) {
      if (walletHistory.status == "0") {
        return const Text(
          "Pending for admin action",
          style: TextStyle(
            color: secondaryColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        );
      } else if (walletHistory.status == "1") {
        return const Text(
          "Payment Transferred",
          style: TextStyle(
            color: secondaryColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        );
      } else {
        return const Text(
          "Request Rejected",
          style: TextStyle(
            color: secondaryColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        );
      }
    } else {
      return Text(
        walletHistory.brandName!,
        style: const TextStyle(
          color: secondaryColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
      );
    }
  }

  Widget showAmountWidget(WalletHistory walletHistory) {
    if (walletHistory.withdrawStatus == 1) {
      if (walletHistory.status == "0") {
        return Text(
          "\u{20B9}${walletHistory.amount!.toString()}",
          style: const TextStyle(
              color: secondaryColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600),
        );
      } else if (walletHistory.status == "1") {
        return Text(
          "\u{20B9}${walletHistory.amount!.toString()}",
          style: const TextStyle(
              color: primaryColor, fontSize: 14.0, fontWeight: FontWeight.w600),
        );
      } else {
        return Text(
          "\u{20B9}${walletHistory.amount!.toString()}",
          style: const TextStyle(
              color: rejectDarkColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600),
        );
      }
    } else {
      return Text(
        "+ \u{20B9}${walletHistory.amount!.toString()}",
        style: const TextStyle(
            color: completedColor, fontSize: 14.0, fontWeight: FontWeight.w600),
      );
    }
  }

  Widget noChart() {
    return SizedBox(
      height: 185.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/bar_chart.png',
              width: 40.00,
              height: 40.00,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Transaction chart is Empty",
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 0.0),
            const Text(
              "You don't have any transaction yet..",
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget noHistory() {
    return SizedBox(
      height: 185.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/transaction.png',
              width: 40.00,
              height: 40.00,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              "Transaction is Empty",
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600),
            ),
            const Text(
              "You don't have any transaction..",
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget showWithdrawDialog(
      String? status, String? message, String? attachFile) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20.0),
      backgroundColor: Colors.transparent,
      child: status == "1"
          ? CustomDialog(
        Child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  attachFile != ""
                      ? InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                WithdrawFullImageScreen(
                                  url: attachFile!,
                                )),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                          width: 150.0,
                          height: 150.0,
                          attachFile!, errorBuilder:
                          (context, error, stackTrace) {
                        return SizedBox(
                          child: Image.asset(
                            width: 150.0,
                            height: 150.0,
                            'assets/images/error_image.png',
                          ),
                        );
                      }),
                    ),
                  )
                      : Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/icons/check.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  message != ""
                      ? Column(
                    children: [
                      Text(
                        "$message",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: secondaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                    ],
                  )
                      : const SizedBox(),
                  ButtonWidget(
                      buttonText: "OK",
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          ],
        ),
      )
          : CustomDialog(
        Child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/icons/close.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  Text(
                    "$message",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  ButtonWidget(
                      buttonText: "OK",
                      onPressed: () {
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
