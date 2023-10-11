import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:revuer/networking/models/revuer_details_model.dart';
import 'package:revuer/ui/home/campaign-tranding-list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/camp_trending_model.dart';
import '../../provider_helper/campaign_provider.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../shared_preference/preference_provider.dart';
import '../../tabs/bubble_tab_indicator.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom-dialog.dart';
import '../search/custom_campaign_search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double statusBarHeight = 5.0;
  var _revuerName = "";
  var _revuerImage = "";
  int verifyStatus = 0;
  String token = "";

  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  final RefreshController _recentRefreshController =
      RefreshController(initialRefresh: true);

  final RefreshController _allRefreshController =
      RefreshController(initialRefresh: true);

  List<CampaignData> campaignSearchList = [];
  List<CampaignData> trendingResponseList = [];
  List<CampaignData> recentResponseList = [];
  List<CampaignData> allResponseList = [];

  /* List<AdvertisementData> advertiseData = [];*/
  int advertiseIndexT = 0;
  int advertiseIndexR = 0;
  int advertiseIndexA = 0;
  List<String> advertiseData1 = [
    'https://imaging.nikon.com/lineup/dslr/df/img/sample/img_01.jpg',
    'https://imaging.nikon.com/lineup/dslr/df/img/sample/img_02.jpg',
    'https://imaging.nikon.com/lineup/dslr/df/img/sample/img_04.jpg',
    'https://imaging.nikon.com/lineup/dslr/df/img/sample/img_05.jpg',
    'https://imaging.nikon.com/lineup/dslr/df/img/sample/img_06.jpg',
  ];

  final List<Tab> tabs = <Tab>[
    const Tab(text: Strings.trending),
    const Tab(text: Strings.recentlyAdded),
    const Tab(text: Strings.allCampaign)
  ];

  TabController? _tabController;

  int _type = 1;
  int _page = 0;
  int newAdValue = 0;

  Map<String, dynamic> get trendingBody => {
        "type": _type,
        "page": _page,
        "revuer_token": token,
        "campaign_type_id": dropdownId,
        "new_adv_value": newAdValue
      };

  bool isApiCalled = false;
  bool isRevuerApiCalled = false;

  final List<String> dropItems = [];
  final List<String> dropId = [];

  String dropdownValue = "All Campaign";
  String dropdownId = "1";
  bool isMaintenance = true;
  bool isUpdate = true;

  void _showPopupMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      initialValue: dropdownValue,
      position: const RelativeRect.fromLTRB(50, 50, 15, 200),
      items: dropItems.map((String popupRoute) {
        return PopupMenuItem<String>(
          value: popupRoute,
          child: ListTile(
              title: Text(popupRoute),
              onTap: () {
                setState(() {
                  if (kDebugMode) {
                    print("onTap [$popupRoute] ");
                  }
                  dropdownValue = popupRoute;
                  //dropdownId = (dropItems.indexOf(dropdownValue)+1).toString();
                  var index = dropItems.indexOf(dropdownValue);
                  dropdownId = dropId.elementAt(index);
                  filteredDataCall();
                  if (kDebugMode) {
                    print("selected filter:- $dropdownValue");
                  }
                  Navigator.pop(context);
                });
              }),
        );
      }).toList(),
    );
  }

  filteredDataCall() async {
    if (_type == 1) {
      setState(() {
        _enabled = true;
      });
      //getRevuerDetails();
      _type = 1;
      _page = 0;
      newAdValue = 0;
      var data = await Provider.of<CampTrendingProvider>(context, listen: false)
          .getCampTrendingData(trendingBody);
      if (data.status == "SUCCESS") {
        setState(() {
          _enabled = false;
        });
        setState(() {
          _refreshController.refreshCompleted();
          trendingResponseList.clear();
          trendingResponseList.addAll(data.data!.campaignData!);
          newAdValue = data.data!.newAdValue!;
          _refreshController.resetNoData();
        });
      } else {
        setState(() {
          _enabled = false;
        });
        _refreshController.refreshFailed();
      }
    } else if (_type == 2) {
      setState(() {
        _enabled = true;
      });
      //  getRevuerDetails();
      _type = 2;
      _page = 0;
      newAdValue = 0;
      var data =
          await Provider.of<CampRecentListProvider>(context, listen: false)
              .getCampRecentData(trendingBody);
      if (data.status == "SUCCESS") {
        setState(() {
          _enabled = false;
        });
        setState(() {
          _recentRefreshController.refreshCompleted();
          recentResponseList.clear();
          recentResponseList.addAll(data.data!.campaignData!);
          newAdValue = data.data!.newAdValue!;
          _recentRefreshController.refreshCompleted();
          _recentRefreshController.resetNoData();
        });
      } else {
        setState(() {
          _enabled = false;
        });
        _recentRefreshController.refreshFailed();
      }
    }
    if (_type == 3) {
      setState(() {
        _enabled = true;
      });
      // getRevuerDetails();
      _type = 3;
      _page = 0;
      newAdValue = 0;
      var data = await Provider.of<CampAllListProvider>(context, listen: false)
          .getCampAllData(trendingBody);
      if (data.status == "SUCCESS") {
        setState(() {
          _enabled = false;
        });
        setState(() {
          _allRefreshController.refreshCompleted();
          allResponseList.clear();
          allResponseList.addAll(data.data!.campaignData!);
          newAdValue = data.data!.newAdValue!;
          _allRefreshController.refreshCompleted();
          _allRefreshController.resetNoData();
        });
      } else {
        setState(() {
          _enabled = false;
        });
        _allRefreshController.refreshFailed();
      }
    }
  }

  getCampaignTypeList() async {
    if (mounted) {
      setState(() {
        isApiCalled = true;
      });
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiCampaignTypeList().then((it) {
        if (mounted) {
          setState(() {
            isApiCalled = false;
          });
        }
        if (it.status == "SUCCESS") {
          if (kDebugMode) {
            print("real data campaign type $it");
          }
          dropItems.clear();
          dropId.clear();
          for (int i = 0; i < it.data!.length; i++) {
            dropItems.add(it.data![i].name!);
            dropId.add(it.data![i].id!);
          }
          setState(() {
            dropdownValue = dropItems[0];
          });
          if (kDebugMode) {
            print("drop value $dropItems");
          }
          if (kDebugMode) {
            print("drop id $dropId");
          }

          if (kDebugMode) {
            print("responseSuccess campaign type $it");
          }
        } else if (it.status == "FAILURE") {
          Fluttertoast.showToast(msg: it.message.toString());
          if (kDebugMode) {
            print("responseFailure campaign type$it");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          isApiCalled = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong");
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException campaign type $obj");
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      // navigation bar color
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      //status bar brigtness
      statusBarIconBrightness: Brightness.light,
      //status barIcon Brightness
      systemNavigationBarDividerColor: Colors.transparent,
      //Navigation bar divider color
      systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
    ));
    if (kDebugMode) {
      print("print");
    }
    _tabController = TabController(vsync: this, length: tabs.length);
    getRevuerDetails();
    getPrefData();
    getCampaignTypeList();
    screenSetFirebase();
  }

  screenSetFirebase() async {
    await FirebaseAnalytics.instance
        .setCurrentScreen(screenName: 'Main Screen');
    var fullName =
        await SharedPrefProvider.getString(SharedPrefProvider.fullName);
    await FirebaseAnalytics.instance.setUserId(id: fullName);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _refreshController.dispose();
    _allRefreshController.dispose();
    _recentRefreshController.dispose();
    super.dispose();
  }

  getPrefData() async {
    token =
        (await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken))!;
  }

  getRevuerDetails() async {
    if (mounted) {
      setState(() {
        isRevuerApiCalled = true;
      });
    }
    Map<String, dynamic> map = {
      "revuer_token":
          await SharedPrefProvider.getString(SharedPrefProvider.uniqueToken), //from share preference
      "player_id":
          await SharedPrefProvider.getString(SharedPrefProvider.playerId)
    };
    if (kDebugMode) {
      print("requestParam home revuer details$map");
      print("requestParam home revuer details${await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken)}");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) async {
        if (mounted) {
          setState(() {
            isRevuerApiCalled = false;
          });
        }
        print("skfjksncknjkv==> ${it.status}");
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          revuerDetailsModel = RevuerDetailsModel.fromJson(realData);

          print("skfjksncknjkv==> $revuerDetailsModel");

          if (revuerDetailsModel.revuerData!.revuerApproveStatus != null) {
            if (revuerDetailsModel.revuerData!.revuerApproveStatus! == 2) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => showRejectDialog(),
              );
            }
            setState(() {
              verifyStatus =
                  revuerDetailsModel.revuerData!.revuerApproveStatus!;
            });
          }

          if (revuerDetailsModel.revuerData!.firstName == "" ||
              revuerDetailsModel.revuerData!.firstName == null) {
            _revuerName = Strings.appName;
          } else {
            setState(() {
              _revuerName = revuerDetailsModel.revuerData!.firstName!
                  .replaceFirst(
                      revuerDetailsModel.revuerData!.firstName![0],
                      revuerDetailsModel.revuerData!.firstName![0]
                          .toUpperCase());
            });

            print("skfjksncknjkv==> $_revuerName");
          }

          if (revuerDetailsModel.revuerData!.image == "" ||
              revuerDetailsModel.revuerData!.image == null) {
            _revuerImage = "";
          } else {
            setState(() {
              _revuerImage = revuerDetailsModel.revuerData!.image!;
            });
          }

          if (revuerDetailsModel.maintenance!.messageStatus != null) {
            if (revuerDetailsModel.maintenance!.messageStatus == 1) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => showAppMaintenanceDialog(
                    revuerDetailsModel.maintenance!.maintenanceMessage!),
              );
            }
          }

          PackageInfo packageInfo = await PackageInfo.fromPlatform();
          String appVersion = packageInfo.version;
          if (Platform.isAndroid) {
            String currentVersion = revuerDetailsModel.android!.currentVersion!;
            int appVersionA = int.parse(appVersion.replaceAll(".", ""));

            int currentVersionA = int.parse(currentVersion.replaceAll(".", ""));
            if (kDebugMode) {
              print(
                  "app version :- ${packageInfo.version} current version :- ${revuerDetailsModel.android!.currentVersion!}");
            }
            if (currentVersionA > appVersionA) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    showAppUpdateDialog(revuerDetailsModel.android!.message!),
              );
            }
          } else {
            String iosCurrentVersion =
                revuerDetailsModel.iOS!.iosCurrentVersion!;
            int appVersionA = int.parse(appVersion.replaceAll(".", ""));
            int currentVersionA =
                int.parse(iosCurrentVersion.replaceAll(".", ""));
            if (kDebugMode) {
              print(
                  "app version :- ${packageInfo.version} current version :- ${revuerDetailsModel.iOS!.iosCurrentVersion!}");
            }
            if (currentVersionA > appVersionA) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    showAppUpdateDialog(revuerDetailsModel.android!.message!),
              );
            }
          }

          if (kDebugMode) {
            print("real data ${json.encode(realData)}");
          }
          if (kDebugMode) {
            print("responseSuccess revuer details home $it");
          }
        } else if (it.status == "FAILURE") {
          // Fluttertoast.showToast(msg: it.message.toString());

          print("skfjksncknjkv==> ${it.status}");
          print("skfjksncknjkv==> ${it.message}");
          print("skfjksncknjkv==> ${it.data}");
          if (kDebugMode) {
            print("responseFailure ${it.data}");
          }
        }
      }).catchError((Object obj) {
        setState(() {
          isRevuerApiCalled = false;
        });
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

  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    if (kDebugMode) {
      print("selected filter:- $dropdownValue");
    }
    return WillPopScope(
      onWillPop: showExitPopup,
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
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16.0, (statusBarHeight + 8.0), 16.0, 16.0),
                child: Column(
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
                                Navigator.pushReplacementNamed(
                                    context, '/profile');
                              },
                              child: ClipOval(child: showImage()),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  getSearchedCampaignList();
                                  /* Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CampaignSearch(),
                                    ),
                                  );*/
                                },
                                child: Image.asset('assets/icons/search.png',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.fitWidth),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: unitHeightValue * 2.8 > 22.0
                                    ? 22.0
                                    : unitHeightValue * 2.8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _revuerName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: unitHeightValue * 2.8 > 22.0
                                    ? 22.0
                                    : unitHeightValue * 2.8,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TabBar(
                                isScrollable: true,
                                unselectedLabelColor: Colors.white,
                                labelColor: Colors.white,
                                labelStyle: TextStyle(
                                    fontSize: unitHeightValue * 1.8 > 14.0
                                        ? 14.0
                                        : unitHeightValue * 1.8,
                                    fontWeight: FontWeight.w400),
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 18.0),
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: const BubbleTabIndicator(
                                  indicatorHeight: 34.0,
                                  indicatorColor: primaryColor,
                                  tabBarIndicatorSize: TabBarIndicatorSize.tab,
                                  // Other flags
                                  // indicatorRadius: 1,
                                  // insets: EdgeInsets.all(1),
                                  // padding: EdgeInsets.all(10)
                                ),
                                tabs: tabs,
                                controller: _tabController,
                              ),
                            ),
                            const SizedBox(
                              width: 18.0,
                            ),
                            InkWell(
                              onTap: () {
                                _showPopupMenu(context);
                              },
                              child: Image.asset('assets/icons/filter.png',
                                  width: 19.0,
                                  height: 14.0,
                                  fit: BoxFit.fitWidth),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    //for trending data
                    SmartRefresher(
                        controller: _refreshController,
                        enablePullUp: true,
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus? mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = const Text(
                                "pull up load",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else if (mode == LoadStatus.loading) {
                              body = const CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = const Text(
                                "Load Failed!Click retry!",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else if (mode == LoadStatus.canLoading) {
                              body = const Text(
                                "Release to load more",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else {
                              body = const Text(
                                "List ends here..",
                                style: TextStyle(color: secondaryColor),
                              );
                            }
                            return SizedBox(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        onRefresh: () async {
                          setState(() {
                            _enabled = true;
                          });
                          //getRevuerDetails();
                          _type = 1;
                          _page = 0;
                          newAdValue = 0;
                          var data = await Provider.of<CampTrendingProvider>(
                                  context,
                                  listen: false)
                              .getCampTrendingData(trendingBody);
                          if (data.status == "SUCCESS") {
                            print("sjhdbcjkxbzhjbknas===>");

                            setState(() {
                              _enabled = false;
                            });
                            setState(() {
                              _refreshController.refreshCompleted();
                              trendingResponseList.clear();
                              trendingResponseList
                                  .addAll(data.data!.campaignData!);
                              newAdValue = data.data!.newAdValue!;
                              _refreshController.resetNoData();
                            });
                          } else {
                            _enabled = false;
                            /* setState(() {
                              _enabled = false;
                            });*/
                            _refreshController.refreshFailed();
                          }
                        },
                        onLoading: () async {
                          _type = 1;
                          _page++;
                          if (kDebugMode) {
                            print("_page $_page");
                          }
                          var data = await Provider.of<CampTrendingProvider>(
                                  context,
                                  listen: false)
                              .getCampTrendingData(trendingBody);
                          if (data.status == "SUCCESS") {
                            setState(() {
                              if (data.data != null &&
                                  data.data!.campaignData!.isNotEmpty) {
                                trendingResponseList
                                    .addAll(data.data!.campaignData!);
                                newAdValue = data.data!.newAdValue!;
                                _refreshController.loadComplete();
                              } else {
                                Fluttertoast.showToast(msg: data.message!);
                                _refreshController.loadComplete();
                                _refreshController.loadNoData();
                              }
                            });
                          } else {
                            _refreshController.loadFailed();
                          }
                        },
                        child: _enabled
                            ? ListView.builder(
                                itemCount: 6,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                itemBuilder: (context, index) {
                                  if (kDebugMode) {
                                    print(
                                        'apiData ${trendingResponseList.length}');
                                  }
                                  // print('apiData ${apiData.list[index]}');
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16.0),
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
                                                .withOpacity(0.04),
                                            spreadRadius: 0,
                                            blurRadius: 9.0,
                                            offset: const Offset(0, 0),
                                          )
                                        ]),
                                    child: Shimmer.fromColors(
                                      baseColor: const Color.fromRGBO(
                                          191, 191, 191, 0.5254901960784314),
                                      highlightColor: Colors.white,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 8.0,
                                            right: 8.0,
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              padding:
                                                  const EdgeInsets.all(11.0),
                                              decoration: const BoxDecoration(
                                                color: grayColorD,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/icons/instagram.png',
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                13.0, 17.0, 10.0, 18.0),
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
                                    ),
                                  ); //,data: apiData);
                                })
                            : trendingResponseList.isNotEmpty
                                ? ListView.builder(
                                    itemCount: trendingResponseList.length,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    itemBuilder: (context, index) {
                                      if (kDebugMode) {
                                        print('index builder $index');
                                      }
                                      if (kDebugMode) {
                                        print(
                                            'apiData ${trendingResponseList.length}');
                                      }
                                      // print('apiData ${apiData.list[index]}');
                                      return CampaignTrendingListItem(
                                          index: index,
                                          verifyStatus: verifyStatus,
                                          data:
                                              trendingResponseList); //,data: apiData);
                                    },
                                  )
                                : noCampaign()),
                    //for recent added data
                    SmartRefresher(
                        controller: _recentRefreshController,
                        enablePullUp: true,
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus? mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = const Text(
                                "pull up load",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else if (mode == LoadStatus.loading) {
                              body = const CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = const Text(
                                "Load Failed!Click retry!",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else if (mode == LoadStatus.canLoading) {
                              body = const Text(
                                "Release to load more",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else {
                              body = const Text(
                                "List ends here..",
                                style: TextStyle(color: secondaryColor),
                              );
                            }
                            return SizedBox(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        onRefresh: () async {
                          setState(() {
                            _enabled = true;
                          });
                          //  getRevuerDetails();
                          _type = 2;
                          _page = 0;
                          newAdValue = 0;
                          var data = await Provider.of<CampRecentListProvider>(
                                  context,
                                  listen: false)
                              .getCampRecentData(trendingBody);
                          if (data.status == "SUCCESS") {
                            setState(() {
                              _enabled = false;
                            });
                            setState(() {
                              _recentRefreshController.refreshCompleted();
                              recentResponseList.clear();
                              recentResponseList
                                  .addAll(data.data!.campaignData!);
                              newAdValue = data.data!.newAdValue!;
                              _recentRefreshController.refreshCompleted();
                              _recentRefreshController.resetNoData();
                            });
                          } else {
                            _enabled = false;
                            _recentRefreshController.refreshFailed();
                          }
                        },
                        onLoading: () async {
                          _type = 2;
                          _page++;
                          if (kDebugMode) {
                            print("_page $_page");
                          }
                          var data = await Provider.of<CampRecentListProvider>(
                                  context,
                                  listen: false)
                              .getCampRecentData(trendingBody);
                          if (data.status == "SUCCESS") {
                            setState(() {
                              if (data.data != null &&
                                  data.data!.campaignData!.isNotEmpty) {
                                recentResponseList
                                    .addAll(data.data!.campaignData!);
                                newAdValue = data.data!.newAdValue!;
                                _recentRefreshController.loadComplete();
                              } else {
                                Fluttertoast.showToast(msg: data.message!);
                                _recentRefreshController.loadComplete();
                                _recentRefreshController.loadNoData();
                              }
                            });
                          } else {
                            _recentRefreshController.loadFailed();
                          }
                        },
                        child: _enabled
                            ? ListView.builder(
                                itemCount: 6,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                itemBuilder: (context, index) {
                                  if (kDebugMode) {
                                    print(
                                        'apiData ${trendingResponseList.length}');
                                  }
                                  // print('apiData ${apiData.list[index]}');
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16.0),
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
                                                .withOpacity(0.04),
                                            spreadRadius: 0,
                                            blurRadius: 9.0,
                                            offset: const Offset(0, 0),
                                          )
                                        ]),
                                    child: Shimmer.fromColors(
                                      baseColor: const Color.fromRGBO(
                                          191, 191, 191, 0.5254901960784314),
                                      highlightColor: Colors.white,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 8.0,
                                            right: 8.0,
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              padding:
                                                  const EdgeInsets.all(11.0),
                                              decoration: const BoxDecoration(
                                                color: grayColorD,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/icons/instagram.png',
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                13.0, 17.0, 10.0, 18.0),
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
                                    ),
                                  ); //,data: apiData);
                                })
                            : recentResponseList.isNotEmpty
                                ? ListView.builder(
                                    itemCount: recentResponseList.length,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    itemBuilder: (context, index) {
                                      if (kDebugMode) {
                                        print(
                                            'apiData ${recentResponseList.length}');
                                      }
                                      return CampaignTrendingListItem(
                                          index: index,
                                          verifyStatus: verifyStatus,
                                          data: recentResponseList);
                                    },
                                  )
                                : noCampaign()),
                    //for all campaign
                    SmartRefresher(
                        controller: _allRefreshController,
                        enablePullUp: true,
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus? mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = const Text(
                                "pull up load",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else if (mode == LoadStatus.loading) {
                              body = const CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = const Text(
                                "Load Failed!Click retry!",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else if (mode == LoadStatus.canLoading) {
                              body = const Text(
                                "Release to load more",
                                style: TextStyle(color: secondaryColor),
                              );
                            } else {
                              body = const Text(
                                "List ends here..",
                                style: TextStyle(color: secondaryColor),
                              );
                            }
                            return SizedBox(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        onRefresh: () async {
                          setState(() {
                            _enabled = true;
                          });
                          // getRevuerDetails();
                          _type = 3;
                          _page = 0;
                          newAdValue = 0;
                          var data = await Provider.of<CampAllListProvider>(
                                  context,
                                  listen: false)
                              .getCampAllData(trendingBody);
                          if (data.status == "SUCCESS") {
                            setState(() {
                              _enabled = false;
                            });
                            setState(() {
                              _allRefreshController.refreshCompleted();
                              allResponseList.clear();
                              allResponseList.addAll(data.data!.campaignData!);
                              newAdValue = data.data!.newAdValue!;
                              _allRefreshController.refreshCompleted();
                              _allRefreshController.resetNoData();
                            });
                          } else {
                            _enabled = false;
                            _allRefreshController.refreshFailed();
                          }
                        },
                        onLoading: () async {
                          _type = 3;
                          _page++;
                          if (kDebugMode) {
                            print("_page $_page");
                          }
                          var data = await Provider.of<CampAllListProvider>(
                                  context,
                                  listen: false)
                              .getCampAllData(trendingBody);
                          if (data.status == "SUCCESS") {
                            setState(() {
                              if (data.data != null &&
                                  data.data!.campaignData!.isNotEmpty) {
                                allResponseList
                                    .addAll(data.data!.campaignData!);
                                newAdValue = data.data!.newAdValue!;
                                _allRefreshController.loadComplete();
                              } else {
                                Fluttertoast.showToast(msg: data.message!);
                                _allRefreshController.loadComplete();
                                _allRefreshController.loadNoData();
                              }
                            });
                          } else {
                            _allRefreshController.loadFailed();
                          }
                        },
                        child: _enabled
                            ? ListView.builder(
                                itemCount: 6,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                itemBuilder: (context, index) {
                                  if (kDebugMode) {
                                    print(
                                        'apiData ${trendingResponseList.length}');
                                  }
                                  // print('apiData ${apiData.list[index]}');
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16.0),
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
                                                .withOpacity(0.04),
                                            spreadRadius: 0,
                                            blurRadius: 9.0,
                                            offset: const Offset(0, 0),
                                          )
                                        ]),
                                    child: Shimmer.fromColors(
                                      baseColor: const Color.fromRGBO(
                                          191, 191, 191, 0.5254901960784314),
                                      highlightColor: Colors.white,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 8.0,
                                            right: 8.0,
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              padding:
                                                  const EdgeInsets.all(11.0),
                                              decoration: const BoxDecoration(
                                                color: grayColorD,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/icons/instagram.png',
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                13.0, 17.0, 10.0, 18.0),
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
                                    ),
                                  ); //,data: apiData);
                                })
                            : allResponseList.isNotEmpty
                                ? ListView.builder(
                                    itemCount: allResponseList.length,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16.0),
                                    itemBuilder: (context, index) {
                                      if (kDebugMode) {
                                        print(
                                            'apiData ${allResponseList.length}');
                                      }
                                      return CampaignTrendingListItem(
                                          index: index,
                                          verifyStatus: verifyStatus,
                                          data: allResponseList);
                                    },
                                  )
                                : noCampaign()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showImage() {
    if (isRevuerApiCalled) {
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
        print("image url $_revuerImage");
      }
      if (_revuerImage.isNotEmpty) {
        return Image.network(_revuerImage,
            width: 41.0,
            height: 41.0,
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
                fontSize: 27,
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

  Widget showAdsView(String advertiseData1) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: 150,
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                advertiseData1,
                height: 150.0,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor:
                        const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
                    highlightColor: Colors.white,
                    child: Container(
                      height: 150.0,
                      color: Colors.grey,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    child: Image.asset(
                      'assets/images/error_image.png',
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 8, right: 12),
              child: Text(
                "This is test content this is test content this is test content this is test content this is test content this is test content this is test content this is test content",
                maxLines: 2,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  getTrendingData() async {
    _type = 1;
    var respData =
        await Provider.of<CampTrendingProvider>(context, listen: false)
            .getCampTrendingData(trendingBody);
    if (kDebugMode) {
      print("data trending:- ${respData.data!.campaignData![0].campaignName}");
    }
    if (respData.status == "SUCCESS") {
      _refreshController.refreshCompleted();
      trendingResponseList.clear();
      trendingResponseList.addAll(respData.data!.campaignData!);
      if (trendingResponseList.isNotEmpty) {
        setState(() {
          _enabled = false;
        });
      } else {
        setState(() {
          _enabled = true;
        });
      }
    }
  }

  getRecentData() async {
    _type = 2;
    var respData =
        await Provider.of<CampRecentListProvider>(context, listen: false)
            .getCampRecentData(trendingBody);
    if (kDebugMode) {
      print("data recent ka:- ${respData.data!.campaignData![0].campaignName}");
    }
    if (respData.status == "SUCCESS") {
      _refreshController.refreshCompleted();
      recentResponseList.clear();
      recentResponseList.addAll(respData.data!.campaignData!);
    }
  }

  getAllData() async {
    _type = 3;
    var respData =
        await Provider.of<CampAllListProvider>(context, listen: false)
            .getCampAllData(trendingBody);
    if (kDebugMode) {
      print("data all ka:- ${respData.data!.campaignData![0].campaignName}");
    }
    if (respData.status == "SUCCESS") {
      _refreshController.refreshCompleted();
      allResponseList.clear();
      allResponseList.addAll(respData.data!.campaignData!);
    }
  }

  Widget showRejectDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
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
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Image.asset(
                    'assets/icons/close2.png',
                    width: 30.0,
                    height: 30.0,
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
                      padding: const EdgeInsets.all(10.0),
                      width: 90.0,
                      height: 90.0,
                      decoration: const BoxDecoration(
                        color: primaryColorAlpha1,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/close2.png',
                          width: 28.8,
                          height: 30.6,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    const Text(
                      "Your profile is  rejected by admin..",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: secondaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    /*const Text(
                      "We will notify you as soon as possible",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: thirdColor,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400),
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showAppUpdateDialog(String msg) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.transparent,
        child: CustomDialog(
          Child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset('assets/lottie/update_app.json'),
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: secondaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700),
                    ),
                    /*const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      "We will notify you as soon as possible",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: thirdColor,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400),
                    ),*/
                    const SizedBox(
                      height: 20.0,
                    ),
                    ButtonWidget(
                        buttonText: "UPDATE",
                        onPressed: () async {
                          PackageInfo packageInfo =
                              await PackageInfo.fromPlatform();
                          if (Platform.isAndroid || Platform.isIOS) {
                            final appId = Platform.isAndroid
                                ? revuerDetailsModel.android!.link!
                                : revuerDetailsModel.iOS!.ios_link!;
                            final url = Uri.parse(
                              Platform.isAndroid ? appId : appId,
                            );
                            launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showAppMaintenanceDialog(String msg) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.transparent,
        child: CustomDialog(
          Child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Lottie.asset('assets/lottie/maintenance.json'),
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: secondaryColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    /*const Text(
                      "We will notify you as soon as possible",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: thirdColor,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),*/
                    ButtonWidget(
                        buttonText: "OK",
                        onPressed: () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(20.0),
            backgroundColor: Colors.transparent,
            child: CustomDialog(
              Child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 37.0, 10.0, 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Are you sure want to exit..?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: secondaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ButtonWidget(
                                  buttonText: "NO",
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  }),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 1,
                              child: ButtonWidget(
                                  buttonColor: secondaryColor,
                                  buttonText: "YES",
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
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
            "Campaign is empty...",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "You don't have any campaigns..",
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
      ApiClient.getClient().apiGetCampaignSearchList(map).then((it) {
        if (it.status == "SUCCESS") {
          if (kDebugMode) {
            print("responseSuccess search campaign ${it.data}");
          }
          if (mounted) {
            setState(() {
              if (it.data != null && it.data!.campaignData!.isNotEmpty) {
                campaignSearchList.clear();
                campaignSearchList.addAll(it.data!.campaignData!);
                showSearch(
                        context: context,
                        delegate:
                            CustomCampaignSearchDelegate(campaignSearchList))
                    .then((value) {
                  SystemChrome.setSystemUIOverlayStyle(
                      const SystemUiOverlayStyle(
                    systemNavigationBarColor: Colors.transparent,
                    // navigation bar color
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: Brightness.dark,
                    //status bar brigtness
                    statusBarIconBrightness: Brightness.light,
                    //status barIcon Brightness
                    systemNavigationBarDividerColor: Colors.transparent,
                    //Navigation bar divider color
                    systemNavigationBarIconBrightness:
                        Brightness.light, //navigation bar icon
                  ));
                });
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
