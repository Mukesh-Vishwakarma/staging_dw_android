import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:revuer/networking/models/my_campaign_details_model.dart';

import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shared_preference/preference_provider.dart';
import '../../tabs/bubble_tab_indicator.dart';
import '../main/main.dart';
import 'my-campaign-details-tab1.dart';
import 'my-campaign-details-tab2.dart';
import 'my-campaign-details-tab3.dart';

class MyCampaignDetailsScreen extends StatefulWidget {
  final int index;
  final String location;
  const MyCampaignDetailsScreen({Key? key, this.index = 0,this.location = "hgc"}) : super(key: key);

  @override
  State<MyCampaignDetailsScreen> createState() =>
      _MyCampaignDetailsScreenState();
}

class _MyCampaignDetailsScreenState extends State<MyCampaignDetailsScreen>
    with TickerProviderStateMixin {
  double statusBarHeight = 5.0;
  bool showFeedBack = false;

  final List<Tab> tabs = <Tab>[
    const Tab(text: Strings.details),
    const Tab(text: Strings.tasks),
    const Tab(text: Strings.feedback)
  ];

  final List<Tab> tabs2 = <Tab>[
    const Tab(text: Strings.details),
    const Tab(text: Strings.tasks),
  ];

  TabController? _tabController;

  MyCampaignDetailsModel? data;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this, length: tabs2.length, initialIndex: widget.index);
    getCampaignDetails();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  void _openMyPage() {
    if(widget.location=="notify"){
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MainScreen(),
        ),
            (route) => false, //if you want to disable back feature set to false
      );
    }else{
      Navigator.of(context).pop();
    }
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
        body: Stack(
          children: [
            SizedBox(
              child: Container(
                width: double.infinity,
                height: 280.0,
                color: secondaryColor,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.fromLTRB(0.0, (statusBarHeight + 15.0), 0.0, 5),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _openMyPage(),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                    2.0, 5.0, 7.0, 5.0),
                                child: Image.asset(
                                  'assets/icons/back.png',
                                  width: 23.0,
                                  height: 23.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            /*Image.asset('assets/icons/search.png',
                                width: 22.0,
                                height: 21.0,
                                fit: BoxFit.fitWidth),*/
                          ],
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        data != null
                            ? Text(
                                "${data!.campaignName}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                              )
                            : const SizedBox(height: 20.0),
                        const SizedBox(
                          height: 8.0,
                        ),
                        data != null
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TabBar(
                                      isScrollable: false,
                                      unselectedLabelColor: Colors.white,
                                      labelColor: Colors.white,
                                      labelStyle: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicator: const BubbleTabIndicator(
                                        indicatorHeight: 36.0,
                                        indicatorColor: primaryColor,
                                        tabBarIndicatorSize:
                                            TabBarIndicatorSize.tab,
                                      ),
                                      tabs: showFeedBack ? tabs : tabs2,
                                      controller: _tabController,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Flexible(
                    child: showFeedBack
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              /* tab 1 */
                              MyCampaignDetailsTab1Screen(data: data),

                              /* tab 2 */
                              const MyCampaignDetailsTab2Screen(),

                              /* tab 3 */
                              const MyCampaignDetailsTab3Screen(),
                            ],
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              /* tab 1 */
                              MyCampaignDetailsTab1Screen(data: data),

                              /* tab 2 */
                              const MyCampaignDetailsTab2Screen(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCampaignDetails() async {
    Map<String, dynamic> body = {
      "campaign_token":
          await SharedPrefProvider.getString(SharedPrefProvider.campaignToken)
    };

    if (kDebugMode) {
      print("reqParam myCampaign details $body");
    }
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetCampaignDetails(body).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it["message"].toString());
          if (kDebugMode) {
            print("responseSuccess myCampaign details$it");
          }
          if (kDebugMode) {
            print("responseSuccess myCampaign details${it.data.toString()}");
          }
          if (mounted) {
            var realData = DataEncryption.getDecryptedData(
                it.data!.reqKey.toString(), it.data!.reqData.toString());
            if (kDebugMode) {
              print("details data ${realData.toString()}");
            }
            setState(() {
              data = MyCampaignDetailsModel.fromJson(realData);
              //for feedback
              if (data!.cam_type!) {
                showFeedBack = true;
                _tabController = TabController(
                    vsync: this,
                    length: tabs.length,
                    initialIndex: widget.index);
              }
              // feedback
            });
          }
          // Navigator.pushReplacementNamed(context, '/welcome');
        } else if (it.status == "FAILURE") {
          if (mounted) {
            Fluttertoast.showToast(msg: it.message.toString());
          }
          if (kDebugMode) {
            print("responseFailure myCampaign details$it");
          }
        }
      }).catchError((Object obj) {
        if (mounted) {
          Fluttertoast.showToast(msg: "Something went wrong");
        }
        // non-200 error goes here.
        if (kDebugMode) {
          print("responseException myCampaign details $obj");
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
