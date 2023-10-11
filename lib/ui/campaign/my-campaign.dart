import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/my_camp_model.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../tabs/bubble_tab_indicator.dart';
import '../search/custom_my_campaign_search.dart';
import 'my-campaign-list.dart';

class MyCampaignScreen extends StatefulWidget {
  const MyCampaignScreen({Key? key}) : super(key: key);

  @override
  State<MyCampaignScreen> createState() => _MyCampaignScreenState();
}

class _MyCampaignScreenState extends State<MyCampaignScreen>
    with TickerProviderStateMixin {
  double statusBarHeight = 5.0;

  final List<Tab> tabs = <Tab>[
    const Tab(text: Strings.ongoingTab),
    const Tab(text: Strings.pendingRequest),
    const Tab(text: Strings.completed)
  ];

  List<MyCampaignModel> myCampaignSearchList = [];

  var _myCampPage = 0;
  List<MyCampaignModel> myCampList = [];

  var _myCampOnGoingPage = 0;
  List<MyCampaignModel> myCampOngoingList = [];

  var _myCampCompletedPage = 0;
  List<MyCampaignModel> myCampCompleteList = [];

  TabController? _tabController;

  final RefreshController _myCampaignRefreshController =
      RefreshController(initialRefresh: true);

  final RefreshController _myOngoingRefreshController =
      RefreshController(initialRefresh: true);

  final RefreshController _myCompletedRefreshController =
      RefreshController(initialRefresh: true);

  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();
  String revuerImage = "";
  var _revuerName = "";
  bool isApiCalled = false;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    getRevuerDetails();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _myCampaignRefreshController.dispose();
    _myOngoingRefreshController.dispose();
    _myCompletedRefreshController.dispose();
    super.dispose();
  }

  getMyCampaign(String s) async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "page": _myCampPage //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetMyCampaignList(map).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          // myCampList.clear();
          if(mounted){
            setState(() {
              if (it.data != null) {
                // myCampList.addAll(it.data!);
                if (s == "refresh") {
                  setState(() {
                    _myCampaignRefreshController.refreshCompleted();
                    myCampList.clear();
                    myCampList.addAll(it.data!);
                    _myCampaignRefreshController.resetNoData();
                  });
                } else if (s == "loading") {
                  myCampList.addAll(it.data!);
                  _myCampaignRefreshController.loadComplete();
                } else {
                  myCampList.clear();
                  myCampList.addAll(it.data!);
                }
              } else {
                if (s == "refresh") {
                  _myCampaignRefreshController.refreshCompleted();
                  myCampList.clear();
                  _myCampaignRefreshController.resetNoData();
                } else if (s == "loading") {
                  Fluttertoast.showToast(msg: it.message!);
                  _myCampaignRefreshController.loadComplete();
                  _myCampaignRefreshController.loadNoData();
                }
              }
            });
            setState(() {
              _enabled = false;
            });
          }

        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
          if (s == "refresh") {
            _myCampaignRefreshController.refreshFailed();
          } else if (s == "loading") {
            _myCampaignRefreshController.loadFailed();
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
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

  getMyOnGoingCampaign(String s) async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "page": _myCampOnGoingPage //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetMyOnGoingCampaignList(map).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          // myCampList.clear();
          if(mounted){
            setState(() {
              if (it.data != null) {
                if (kDebugMode) {
                  print("data :${it.data![0].brandName}");
                }
                // myCampList.addAll(it.data!);
                if (s == "refresh") {
                  setState(() {
                    _myOngoingRefreshController.refreshCompleted();
                    myCampOngoingList.clear();
                    myCampOngoingList.addAll(it.data!);
                    _myOngoingRefreshController.resetNoData();
                  });
                } else if (s == "loading") {
                  myCampOngoingList.addAll(it.data!);
                  _myOngoingRefreshController.loadComplete();
                } else {
                  myCampOngoingList.clear();
                  myCampOngoingList.addAll(it.data!);
                }
              } else {
                if (s == "refresh") {
                  _myOngoingRefreshController.refreshCompleted();
                  myCampOngoingList.clear();
                  _myOngoingRefreshController.resetNoData();
                } else if (s == "loading") {
                  Fluttertoast.showToast(msg: it.message!);
                  _myOngoingRefreshController.loadComplete();
                  _myOngoingRefreshController.loadNoData();
                }
              }
            });
            setState(() {
              _enabled = false;
            });
          }
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
          if (s == "refresh") {
            _myOngoingRefreshController.refreshFailed();
          } else if (s == "loading") {
            _myOngoingRefreshController.loadFailed();
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseExecption $obj");
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

  getMyCompletedCampaign(String s) async {
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
      "page": _myCampCompletedPage //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetMyCompleteCampaignList(map).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          // myCampList.clear();
          if(mounted){
            setState(() {
              if (it.data != null) {
                if (kDebugMode) {
                  print("data :${it.data![0].brandName}");
                }
                // myCampList.addAll(it.data!);
                if (s == "refresh") {
                  setState(() {
                    _myCompletedRefreshController.refreshCompleted();
                    myCampCompleteList.clear();
                    myCampCompleteList.addAll(it.data!);
                    _myCompletedRefreshController.resetNoData();
                  });
                } else if (s == "loading") {
                  myCampCompleteList.addAll(it.data!);
                  _myCompletedRefreshController.loadComplete();
                } else {
                  myCampCompleteList.clear();
                  myCampCompleteList.addAll(it.data!);
                }
              } else {
                if (s == "refresh") {
                  _myCompletedRefreshController.refreshCompleted();
                  myCampCompleteList.clear();
                  _myCompletedRefreshController.resetNoData();
                } else if (s == "loading") {
                  Fluttertoast.showToast(msg: it.message!);
                  _myCompletedRefreshController.loadComplete();
                  _myCompletedRefreshController.loadNoData();
                }
              }
            });
            setState(() {
              _enabled = false;
            });
          }

        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
          if (s == "refresh") {
            _myCompletedRefreshController.refreshFailed();
          } else if (s == "loading") {
            _myCompletedRefreshController.loadFailed();
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
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

  getRevuerDetails() async {
    if(mounted){
      setState(() {
        isApiCalled = true;
      });
    }
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    print("ajhgdvcjkjknjna=>$map");
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) {
        if (it.status == "SUCCESS") {
          if(mounted){
            setState(() {
              isApiCalled = false;
            });
          }
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          revuerDetailsModel = RevuerDetailsModel.fromJson(realData);

          if (revuerDetailsModel.revuerData!.firstName == "" ||
              revuerDetailsModel.revuerData!.firstName == null) {
            _revuerName = Strings.appName;
          } else {
            if(mounted){
              setState(() {
                _revuerName = revuerDetailsModel.revuerData!.firstName!.replaceFirst(
                    revuerDetailsModel.revuerData!.firstName![0],
                    revuerDetailsModel.revuerData!.firstName![0].toUpperCase());
              });
            }
          }

          if (revuerDetailsModel.revuerData!.image == "" ||
              revuerDetailsModel.revuerData!.image == null) {
            revuerImage = "";
          } else {
            if(mounted){
              setState(() {
                revuerImage = revuerDetailsModel.revuerData!.image!;
              });
            }
          }

          if (kDebugMode) {
            print("real data $realData");
          }
          if (kDebugMode) {
            print("responseSuccess $it");
          }
        } else if (it.status == "FAILURE") {
          if(mounted){
            setState(() {
              isApiCalled = false;
            });
          }
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        if(mounted){
          setState(() {
            isApiCalled = false;
          });
        }
        Fluttertoast.showToast(msg: "Something went wrong");
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

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return WillPopScope(
      onWillPop: () async {
        _openMyPage();
        return true;
      },
      child: Stack(
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
            padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 8.0), 16.0, 10),
            child: Column(
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
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/profile');
                          },
                          child: ClipOval(
                            child:
                                showImage() /*Image.asset(
                              'assets/images/dummy_avtar.png',
                              width: 41.0,
                              height: 41.0,
                              fit: BoxFit.cover,
                            )*/,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: (){
                              getSearchedCampaignList();
                              /*Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MyCampaignSearch(),
                                ),
                              );*/
                            },
                            child: Image.asset('assets/icons/search.png',
                                width: 24.0, height: 24.0, fit: BoxFit.fitWidth),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      Strings.myCampaigns,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    /* if data  */
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TabBar(
                            isScrollable: false,
                            unselectedLabelColor: Colors.white,
                            labelColor: Colors.white,
                            labelStyle: TextStyle(
                                fontSize: unitHeightValue * 1.8 > 14.0
                                    ? 14.0
                                    : unitHeightValue * 1.8,
                                fontWeight: FontWeight.w400),
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: const BubbleTabIndicator(
                              indicatorHeight: 34.0,
                              indicatorColor: primaryColor,
                              tabBarIndicatorSize: TabBarIndicatorSize.tab,
                            ),
                            tabs: tabs,
                            controller: _tabController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
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
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        //for onGoing list
                        SmartRefresher(
                          controller: _myOngoingRefreshController,
                          enablePullUp: true,
                          footer: CustomFooter(
                            builder: (BuildContext context, LoadStatus? mode) {
                              Widget body;
                              if (mode == LoadStatus.idle) {
                                body = const Text("pull up load");
                              } else if (mode == LoadStatus.loading) {
                                body = const CupertinoActivityIndicator();
                              } else if (mode == LoadStatus.failed) {
                                body = const Text("Load Failed!Click retry!");
                              } else if (mode == LoadStatus.canLoading) {
                                body = const Text("Release to load more");
                              } else {
                                body = const Text("List ends here..");
                              }
                              return SizedBox(
                                height: 55.0,
                                child: Center(child: body),
                              );
                            },
                          ),
                          onRefresh: () {
                            if(mounted){
                              setState(() {
                                _enabled = true;
                              });
                            }
                           // getRevuerDetails();
                            _myCampOnGoingPage = 0;
                            getMyOnGoingCampaign("refresh");
                          },
                          onLoading: () {
                            _myCampOnGoingPage++;
                            getMyOnGoingCampaign("loading");
                          },
                          child: _enabled
                              ? ListView.builder(
                              itemCount: 6,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                top: 10,
                                  left: 1.0, right: 1.0),
                              itemBuilder: (context, index) {
                                // print('apiData ${apiData.list[index]}');
                                return Shimmer.fromColors(
                                  baseColor:const Color.fromRGBO(
                                      191, 191, 191, 0.5254901960784314),
                                  highlightColor: Colors.white,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            13.0, 12.0, 10.0, 12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                              child: Image.asset(
                                                'assets/images/dummy1.png',
                                                width: 130.0,
                                                height: 130.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 14.0,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Container(
                                                      decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .white,
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(
                                                            Radius.circular(
                                                                20.0),
                                                          )),
                                                      child: Text(
                                                        "Review recent added",
                                                        style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontSize: unitHeightValue *
                                                              1.8 >
                                                              14.0
                                                              ? 14.0
                                                              : unitHeightValue *
                                                              1.8,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Container(
                                                      decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .white,
                                                          borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(
                                                                20.0),
                                                          )),
                                                      child: Text(
                                                        "Shoppers",
                                                        style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontSize: unitHeightValue *
                                                              1.8 >
                                                              14.0
                                                              ? 14.0
                                                              : unitHeightValue *
                                                              1.8,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Container(
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .all(
                                                                Radius.circular(
                                                                    20.0),
                                                              )),
                                                          child: Text(
                                                            "Review recent added",
                                                            style:
                                                            TextStyle(
                                                              color:
                                                              secondaryColor,
                                                              fontSize: unitHeightValue *
                                                                  1.8 >
                                                                  14.0
                                                                  ? 14.0
                                                                  : unitHeightValue *
                                                                  1.8,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Container(
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .all(
                                                                Radius.circular(
                                                                    20.0),
                                                              )),
                                                          child: Text(
                                                            "Review recent added",
                                                            style:
                                                            TextStyle(
                                                              color:
                                                              secondaryColor,
                                                              fontSize: unitHeightValue *
                                                                  1.8 >
                                                                  14.0
                                                                  ? 14.0
                                                                  : unitHeightValue *
                                                                  1.8,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ); //,data: apiData);
                              })
                              :myCampOngoingList.isNotEmpty
                              ? ListView.separated(
                                  itemCount: myCampOngoingList.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(
                                            height: 1,
                                            color: grayColor,
                                          ),
                                  itemBuilder: (context, index) {
                                    return MyCampaignListItem(
                                        screenType: "onGoing",
                                        index: index,
                                        data: myCampOngoingList);
                                  })
                              : noCampaign(),
                        ),

                        //for pending list
                        SmartRefresher(
                          controller: _myCampaignRefreshController,
                          enablePullUp: true,
                          footer: CustomFooter(
                            builder: (BuildContext context, LoadStatus? mode) {
                              Widget body;
                              if (mode == LoadStatus.idle) {
                                body = const Text("pull up load");
                              } else if (mode == LoadStatus.loading) {
                                body = const CupertinoActivityIndicator();
                              } else if (mode == LoadStatus.failed) {
                                body = const Text("Load Failed!Click retry!");
                              } else if (mode == LoadStatus.canLoading) {
                                body = const Text("Release to load more");
                              } else {
                                body = const Text("List ends here..");
                              }
                              return SizedBox(
                                height: 55.0,
                                child: Center(child: body),
                              );
                            },
                          ),
                          onRefresh: () {
                            if(mounted){
                              setState(() {
                                _enabled = true;
                              });
                            }
                            //getRevuerDetails();
                            _myCampPage = 0;
                            getMyCampaign("refresh");
                          },
                          onLoading: () {
                            _myCampPage++;
                            getMyCampaign("loading");
                          },
                          child: _enabled
                              ? ListView.builder(
                              itemCount: 6,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  left: 1.0, right: 1.0),
                              itemBuilder: (context, index) {
                                // print('apiData ${apiData.list[index]}');
                                return Shimmer.fromColors(
                                  baseColor:const Color.fromRGBO(
                                      191, 191, 191, 0.5254901960784314),
                                  highlightColor: Colors.white,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            13.0, 12.0, 10.0, 12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                              child: Image.asset(
                                                'assets/images/dummy1.png',
                                                width: 130.0,
                                                height: 130.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 14.0,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Container(
                                                      decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .white,
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(
                                                            Radius.circular(
                                                                20.0),
                                                          )),
                                                      child: Text(
                                                        "Review recent added",
                                                        style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontSize: unitHeightValue *
                                                              1.8 >
                                                              14.0
                                                              ? 14.0
                                                              : unitHeightValue *
                                                              1.8,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Container(
                                                      decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .white,
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(
                                                            Radius.circular(
                                                                20.0),
                                                          )),
                                                      child: Text(
                                                        "Shoppers",
                                                        style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontSize: unitHeightValue *
                                                              1.8 >
                                                              14.0
                                                              ? 14.0
                                                              : unitHeightValue *
                                                              1.8,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Container(
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .all(
                                                                Radius.circular(
                                                                    20.0),
                                                              )),
                                                          child: Text(
                                                            "Review recent added",
                                                            style:
                                                            TextStyle(
                                                              color:
                                                              secondaryColor,
                                                              fontSize: unitHeightValue *
                                                                  1.8 >
                                                                  14.0
                                                                  ? 14.0
                                                                  : unitHeightValue *
                                                                  1.8,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Container(
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .all(
                                                                Radius.circular(
                                                                    20.0),
                                                              )),
                                                          child: Text(
                                                            "Review recent added",
                                                            style:
                                                            TextStyle(
                                                              color:
                                                              secondaryColor,
                                                              fontSize: unitHeightValue *
                                                                  1.8 >
                                                                  14.0
                                                                  ? 14.0
                                                                  : unitHeightValue *
                                                                  1.8,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ); //,data: apiData);
                              })
                              : myCampList.isNotEmpty
                              ? ListView.separated(
                                  itemCount: myCampList.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(
                                            height: 1,
                                            color: grayColor,
                                          ),
                                  itemBuilder: (context, index) {
                                    return MyCampaignListItem(
                                      screenType: "pending",
                                      index: index,
                                      data: myCampList,
                                    );
                                  })
                              : noPendingCampaign(),
                        ),

                        //for completed
                        SmartRefresher(
                          controller: _myCompletedRefreshController,
                          enablePullUp: true,
                          footer: CustomFooter(
                            builder: (BuildContext context, LoadStatus? mode) {
                              Widget body;
                              if (mode == LoadStatus.idle) {
                                body = const Text("pull up load");
                              } else if (mode == LoadStatus.loading) {
                                body = const CupertinoActivityIndicator();
                              } else if (mode == LoadStatus.failed) {
                                body = const Text("Load Failed!Click retry!");
                              } else if (mode == LoadStatus.canLoading) {
                                body = const Text("Release to load more");
                              } else {
                                body = const Text("List ends here..");
                              }
                              return SizedBox(
                                height: 55.0,
                                child: Center(child: body),
                              );
                            },
                          ),
                          onRefresh: () {
                            if(mounted){
                              setState(() {
                                _enabled = true;
                              });
                            }
                            // getRevuerDetails();
                            _myCampCompletedPage = 0;
                            getMyCompletedCampaign("refresh");
                          },
                          onLoading: () {
                            _myCampCompletedPage++;
                            getMyCompletedCampaign("loading");
                          },
                          child: _enabled
                              ? ListView.builder(
                              itemCount: 6,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 1.0, right: 1.0),
                              itemBuilder: (context, index) {
                                // print('apiData ${apiData.list[index]}');
                                return Shimmer.fromColors(
                                  baseColor:const Color.fromRGBO(
                                      191, 191, 191, 0.5254901960784314),
                                  highlightColor: Colors.white,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            13.0, 12.0, 10.0, 12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                              child: Image.asset(
                                                'assets/images/dummy1.png',
                                                width: 130.0,
                                                height: 130.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 14.0,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Container(
                                                      decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .white,
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(
                                                            Radius.circular(
                                                                20.0),
                                                          )),
                                                      child: Text(
                                                        "Review recent added",
                                                        style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontSize: unitHeightValue *
                                                              1.8 >
                                                              14.0
                                                              ? 14.0
                                                              : unitHeightValue *
                                                              1.8,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Container(
                                                      decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .white,
                                                          borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(
                                                                20.0),
                                                          )),
                                                      child: Text(
                                                        "Shoppers",
                                                        style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontSize: unitHeightValue *
                                                              1.8 >
                                                              14.0
                                                              ? 14.0
                                                              : unitHeightValue *
                                                              1.8,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Container(
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .all(
                                                                Radius.circular(
                                                                    20.0),
                                                              )),
                                                          child: Text(
                                                            "Review recent added",
                                                            style:
                                                            TextStyle(
                                                              color:
                                                              secondaryColor,
                                                              fontSize: unitHeightValue *
                                                                  1.8 >
                                                                  14.0
                                                                  ? 14.0
                                                                  : unitHeightValue *
                                                                  1.8,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Container(
                                                          decoration:
                                                          const BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .all(
                                                                Radius.circular(
                                                                    20.0),
                                                              )),
                                                          child: Text(
                                                            "Review recent added",
                                                            style:
                                                            TextStyle(
                                                              color:
                                                              secondaryColor,
                                                              fontSize: unitHeightValue *
                                                                  1.8 >
                                                                  14.0
                                                                  ? 14.0
                                                                  : unitHeightValue *
                                                                  1.8,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                            ),
                                                          )),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ); //,data: apiData);
                              })
                              :myCampCompleteList.isNotEmpty
                              ? ListView.separated(
                              itemCount: myCampCompleteList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                              const Divider(
                                height: 1,
                                color: grayColor,
                              ),
                              itemBuilder: (context, index) {
                                return MyCampaignListItem(
                                    screenType: "onGoing",
                                    index: index,
                                    data: myCampCompleteList);
                              })
                              : noCompletedCampaign(),
                        ),
                      ],
                    ),
                  ),
                ),
                /*Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(16.0),
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
                        ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/speaker.png',
                          width: 58.3,
                          height: 45.5,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16.5,),
                        const Text(
                          "My campaign is empty...",
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8.0,),
                        const Text(
                          "You haven’t applied in an any\ncampaign yet...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget noCampaign() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/campaign-a.png',
            width: 40.00,
            height: 40.00,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Text(
            "Ongoing campaign is empty...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "You haven't any active campaign in your account...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget noCompletedCampaign() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/campaign-a.png',
            width: 40.00,
            height: 40.00,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Text(
            "Completed campaign is empty...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "You haven't any completed campaign in your account...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget noPendingCampaign() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/campaign-a.png',
            width: 40.00,
            height: 40.00,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10.0,
          ),
          const Text(
            "Pending campaign is empty...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "You haven't applied in any campaign yet...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
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
      if (kDebugMode) {
        print("image url $revuerImage");
      }
      if (revuerImage.isNotEmpty) {
        return Image.network(revuerImage,
            width: 41.0,
            height: 41.0,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
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
            },
            errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            width: 41.0,
            height: 41.0,
            child: Image.asset(
              width: 41.0,
              height: 41.0,
              'assets/images/error_image.png',
              fit: BoxFit.cover,
            ),
          );
        });
      } else {
        return Container(
          width: 41.0,
          height: 41.0,
          color: primaryColor,
          child: Center(
              child: Text(
            _revuerName.isNotEmpty ? _revuerName[0].toUpperCase() : "R",
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

  getSearchedCampaignList() async {
    Map<String, dynamic> map = {
      "revuer_token":
      await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken),
    };
    if (kDebugMode) {
      print("requestParam $map");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetMyCampaignSearchList(map).then((it) {
        if (it.status == "SUCCESS") {
          if (kDebugMode) {
            print("responseSuccess search campaign ${it.data}");
          }
          if (mounted) {
            setState(() {
              if (it.data != null) {
                myCampaignSearchList.clear();
                myCampaignSearchList.addAll(it.data!);
                showSearch(
                    context: context,
                    delegate: CustomMyCampaignSearchDelegate(myCampaignSearchList)
                );
              } else {

              }
            });
          }
        } else if (it.status == "FAILURE") {
          if (kDebugMode) {
            print("responseFailure get notice ${it.data}");
          }
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException get notice $obj");
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

}
