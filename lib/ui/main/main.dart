import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../networking/DataEncryption.dart';
import '../../networking/api_client.dart';
import '../../networking/models/revuer_details_model.dart';
import '../../res/colors.dart';
import '../../bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import '../../shared_preference/preference_provider.dart';
import '../home/home.dart';
import '../campaign/my-campaign.dart';
import '../analytics/analytics.dart';
import '../inbox/Inbox.dart';

class MainScreen extends StatefulWidget {
  final int index;

  const MainScreen({Key? key, this.index = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  int verifyStatus = 1;
  RevuerDetailsModel revuerDetailsModel = RevuerDetailsModel();

  getRevuerDetails() async {
    Map<String, dynamic> map = {
      "revuer_token": await SharedPrefProvider.getString(
          SharedPrefProvider.uniqueToken) //from share preference
    };
    bool isOnline = await ApiClient.hasNetwork();
    if (isOnline) {
      ApiClient.getClient().apiGetRevuerDetails(map).then((it) {
        if (it.status == "SUCCESS") {
          // Fluttertoast.showToast(msg: it.message.toString());
          var realData = DataEncryption.getDecryptedData(
              it.data!.reqKey.toString(), it.data!.reqData.toString());
          revuerDetailsModel = RevuerDetailsModel.fromJson(realData);
          if (revuerDetailsModel.revuerData!.revuerApproveStatus != null) {
            setState(() {
              verifyStatus = revuerDetailsModel.revuerData!.revuerApproveStatus!;
            });
          }
        } else if (it.status == "FAILURE") {
          if (kDebugMode) {
            print("responseFailure $it");
          }
        }
      }).catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            // Here's the sample to get the failed response error code and message
            final res = (obj as DioError).response;
            if (kDebugMode) {
              print("status ${res?.statusCode}");
            }
            break;
          default:
            break;
        }
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
    getRevuerDetails();
  }

  final pages = [
    const HomeScreen(),
    const MyCampaignScreen(),
    const AnalyticScreen(),
    const InboxScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: pages[_selectedIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            verifyStatus == 0
                ? Container(
                    // height: 20,
                    color: secondaryColor,
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(left: 12.0,top: 3.0,bottom: 3.0),
                    // padding: EdgeInsets.all(8.0),
                    child: const Text(
                      "Your profile is under review..",
                      style: TextStyle(fontSize:12,color: Colors.white),
                    ),
                  )
                : const SizedBox(),
            FloatingNavbar(
                currentIndex: _selectedIndex,
                unselectedItemColor: thirdColor,
                selectedItemColor: primaryColor,
                selectedBackgroundImg: const AssetImage("assets/images/ellipse103.png"),
                fontSize: 10.0,
                onTap: _onItemTapped,
                items: [
                  FloatingNavbarItem(
                    title: "Home",
                    customWidget: _selectedIndex == 0
                        ? Image.asset('assets/icons/home-a.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain)
                        : Image.asset('assets/icons/home.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain),
                  ),
                  FloatingNavbarItem(
                    title: "My Campaign",
                    customWidget: _selectedIndex == 1
                        ? Image.asset('assets/icons/campaign-a.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain)
                        : Image.asset('assets/icons/campaign.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain),
                  ),
                  FloatingNavbarItem(
                    title: "Earnings",
                    customWidget: _selectedIndex == 2
                        ? Image.asset('assets/icons/graph-a.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain)
                        : Image.asset('assets/icons/graph.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain),
                  ),
                  FloatingNavbarItem(
                    title: "Inbox",
                    customWidget: _selectedIndex == 3
                        ? Image.asset('assets/icons/inbox-a.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain)
                        : Image.asset('assets/icons/inbox.png',
                            width: 20.0, height: 20.0, fit: BoxFit.contain),
                  ),
                ])
          ],
        ));
  }
}
