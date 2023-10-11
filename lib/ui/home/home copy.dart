import 'package:flutter/material.dart';

import '../../bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../tabs/bubble_tab_indicator.dart';
import 'campaign-list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  final List<Tab> tabs = <Tab>[
    const Tab(text: Strings.trending),
    const Tab(text: Strings.recentlyAdded),
    const Tab(text: Strings.allCampaign)
  ];

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
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
            padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 5.0), 16.0, 10),
            child: Column(

              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/dummy_avtar.png',
                            width: 41.0,
                            height: 41.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Image.asset(
                            'assets/icons/search.png',
                            width: 22.0,
                            height: 21.0,
                            fit: BoxFit.fitWidth
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hello, ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Rohit Gupta!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0,),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TabBar(
                            isScrollable: true,
                            unselectedLabelColor: Colors.white,
                            labelColor: Colors.white,
                            labelStyle: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600
                            ),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: const BubbleTabIndicator(
                              indicatorHeight: 36.0,
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
                        const SizedBox(width: 18.0,),
                        Image.asset(
                            'assets/icons/filter.png',
                            width: 21.0,
                            height: 16.0,
                            fit: BoxFit.fitWidth
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20.0,),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView.builder(
                          itemCount: 15,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return CampaignListItem();
                          }),

                      ListView.builder(
                          itemCount: 15,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return CampaignListItem();
                          }),

                      ListView.builder(
                          itemCount: 15,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return CampaignListItem();
                          }),

                    ],
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
      bottomNavigationBar: FloatingNavbar(
        currentIndex: _selectedIndex,
        unselectedItemColor: thirdColor,
        selectedItemColor: primaryColor,
        selectedBackgroundImg: const AssetImage("assets/images/ellipse103.png"),
        fontSize: 14.0,
        onTap: _onItemTapped,
        items: [
          FloatingNavbarItem(
            title:"Home",
            customWidget: _selectedIndex == 0 ? Image.asset('assets/icons/home-a.png') : Image.asset('assets/icons/home.png'),
          ),
          FloatingNavbarItem(
            title:"My Campaign",
            customWidget: _selectedIndex == 1 ? Image.asset('assets/icons/campaign-a.png') : Image.asset('assets/icons/campaign.png'),
          ),
          FloatingNavbarItem(
            title:"Analytics",
            customWidget: _selectedIndex == 2 ? Image.asset('assets/icons/graph-a.png') : Image.asset('assets/icons/graph.png'),
          ),
          FloatingNavbarItem(
            title:"Inbox",
            customWidget: _selectedIndex == 3 ? Image.asset('assets/icons/inbox-a.png') : Image.asset('assets/icons/inbox.png'),
          ),
        ]
      ),


    );
  }
}
