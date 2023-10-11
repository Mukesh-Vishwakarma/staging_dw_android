import 'package:flutter/material.dart';
import 'package:revuer/networking/models/camp_trending_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../res/colors.dart';
import '../../shared_preference/preference_provider.dart';
import '../campaign/campaign-details.dart';
import '../campaign/my-campaign-details.dart';

class CustomCampaignSearchDelegate extends SearchDelegate {

  @override
  ThemeData appBarTheme(BuildContext context){
    return Theme.of(context).copyWith(
      backgroundColor: secondaryColor,
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
          color: secondaryColor
      ),
      textTheme: const TextTheme(
        titleLarge:TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
    );
  }

  List<CampaignData> campaignSearchList = [];
  CustomCampaignSearchDelegate(this.campaignSearchList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    List<CampaignData> matchQuery = [];
    for (var campaignList in campaignSearchList) {
      if(query.isNotEmpty && campaignList.campaignName!.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(campaignList);
      }
      /*if (campaignList.campaignName!.toLowerCase().contains(query.toLowerCase())) {
      }*/
    }
    return matchQuery.isNotEmpty
        ? Container(
      margin: const EdgeInsets.all(16),
          child: ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: index == 0
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )
                    : BorderRadius.zero),
            child: InkWell(
              onTap: () async {
                if (matchQuery[index].approveStatus == 1) {
                  SharedPrefProvider.setString(SharedPrefProvider.campaignToken,
                      "${matchQuery[index].campaignToken}");
                  SharedPrefProvider.setString(
                      SharedPrefProvider.brandloginUniqueToken,
                      "${matchQuery[index].brandloginUniqueToken}");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/campaign-task'),
                      builder: (context) => MyCampaignDetailsScreen(),
                    ),
                  );
                  //  Navigator.pushReplacementNamed(context, '/my-campaign-details');
                } else {
                  SharedPrefProvider.setString(SharedPrefProvider.campaignToken,
                      "${matchQuery[index].campaignToken}");
                  SharedPrefProvider.setString(
                      SharedPrefProvider.brandloginUniqueToken,
                      "${matchQuery[index].brandloginUniqueToken}");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/campaign-task'),
                      builder: (context) => CampaignDetailsScreen(
                        location: "home",
                      ),
                    ),
                  );
                  // Navigator.pushReplacementNamed(context, '/campaign-details');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
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
                        color: const Color(0xff2A3B53).withOpacity(0.04),
                        spreadRadius: 0,
                        blurRadius: 9.0,
                        offset: const Offset(0, 0),
                      )
                    ]),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: matchQuery[index].socialIcon!.isNotEmpty
                          ? Container(
                          width: 40.0,
                          height: 40.0,
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: grayColorD,
                            shape: BoxShape.circle,
                          ),
                          child: showSocialIcon(
                              matchQuery[index].socialIcon!))
                          : const SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(13.0, 17.0, 10.0, 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                              "${matchQuery[index].image}",
                              width: 130.0,
                              height: 130.0,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: const Color.fromRGBO(
                                      191, 191, 191, 0.5254901960784314),
                                  highlightColor: Colors.white,
                                  child: Container(
                                    width: 130.0,
                                    height: 130.0,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  width: 130.0,
                                  height: 130.0,
                                  child: Image.asset(
                                    width: 80.0,
                                    height: 80.0,
                                    'assets/images/error_image.png',
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 14.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 30),
                                  child: Text(
                                    "${matchQuery[index].campaignName}",
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: unitHeightValue * 1.8 > 14.0
                                          ? 14.0
                                          : unitHeightValue * 1.8,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  "${matchQuery[index].brandName}",
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: unitHeightValue * 1.99 > 16.0
                                        ? 16.0
                                        : unitHeightValue * 1.99,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                FittedBox(
                                  child: Row(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 2.0),
                                            child: Image.asset(
                                                'assets/icons/wallet.png',
                                                width: 18.0,
                                                height: 18.0,
                                                fit: BoxFit.fitWidth),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Earn Upto",
                                                style: TextStyle(
                                                  color: thirdColor,
                                                  fontSize:
                                                  unitHeightValue * 1.8 > 14.0
                                                      ? 14.0
                                                      : unitHeightValue * 1.8,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              Text(
                                                "\u{20B9}${matchQuery[index].earnUpto}",
                                                style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize:
                                                  unitHeightValue * 1.99 > 16.0
                                                      ? 16.0
                                                      : unitHeightValue * 1.99,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 18.0,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 2.0),
                                            child: Image.asset(
                                                'assets/icons/slot.png',
                                                width: 20.5,
                                                height: 19.0,
                                                fit: BoxFit.fitWidth),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Slots",
                                                style: TextStyle(
                                                  color: thirdColor,
                                                  fontSize:
                                                  unitHeightValue * 1.8 > 14.0
                                                      ? 14.0
                                                      : unitHeightValue * 1.8,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "${matchQuery[index].joinRevuer}",
                                                    style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: unitHeightValue *
                                                          1.99 >
                                                          16.0
                                                          ? 16.0
                                                          : unitHeightValue * 1.99,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    "/${matchQuery[index].revuerLimit}",
                                                    style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize:
                                                      unitHeightValue * 1.8 > 14.0
                                                          ? 14.0
                                                          : unitHeightValue * 1.8,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
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
            ),
          );
      },
    ),
        )
        :  Expanded(child: noCampaign());
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    List<CampaignData> matchQuery = [];
    for (var campaignList in campaignSearchList) {
      if(query.isNotEmpty && campaignList.campaignName!.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(campaignList);
      }
    }
    return matchQuery.isNotEmpty
        ? Container(
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: index == 0
                    ? const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )
                    : BorderRadius.zero),
            child: InkWell(
              onTap: () async {
                if (matchQuery[index].approveStatus == 1) {
                  SharedPrefProvider.setString(SharedPrefProvider.campaignToken,
                      "${matchQuery[index].campaignToken}");
                  SharedPrefProvider.setString(
                      SharedPrefProvider.brandloginUniqueToken,
                      "${matchQuery[index].brandloginUniqueToken}");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/campaign-task'),
                      builder: (context) => MyCampaignDetailsScreen(),
                    ),
                  );
                  //  Navigator.pushReplacementNamed(context, '/my-campaign-details');
                } else {
                  SharedPrefProvider.setString(SharedPrefProvider.campaignToken,
                      "${matchQuery[index].campaignToken}");
                  SharedPrefProvider.setString(
                      SharedPrefProvider.brandloginUniqueToken,
                      "${matchQuery[index].brandloginUniqueToken}");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      settings: const RouteSettings(name: '/campaign-task'),
                      builder: (context) => CampaignDetailsScreen(
                        location: "home",
                      ),
                    ),
                  );
                  // Navigator.pushReplacementNamed(context, '/campaign-details');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
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
                        color: const Color(0xff2A3B53).withOpacity(0.04),
                        spreadRadius: 0,
                        blurRadius: 9.0,
                        offset: const Offset(0, 0),
                      )
                    ]),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: matchQuery[index].socialIcon!.isNotEmpty
                          ? Container(
                          width: 40.0,
                          height: 40.0,
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: grayColorD,
                            shape: BoxShape.circle,
                          ),
                          child: showSocialIcon(
                              matchQuery[index].socialIcon!))
                          : const SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(13.0, 17.0, 10.0, 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                              "${matchQuery[index].image}",
                              width: 130.0,
                              height: 130.0,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: const Color.fromRGBO(
                                      191, 191, 191, 0.5254901960784314),
                                  highlightColor: Colors.white,
                                  child: Container(
                                    width: 130.0,
                                    height: 130.0,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  width: 130.0,
                                  height: 130.0,
                                  child: Image.asset(
                                    width: 80.0,
                                    height: 80.0,
                                    'assets/images/error_image.png',
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 14.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 30),
                                  child: Text(
                                    "${matchQuery[index].campaignName}",
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: unitHeightValue * 1.8 > 14.0
                                          ? 14.0
                                          : unitHeightValue * 1.8,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(
                                  "${matchQuery[index].brandName}",
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: unitHeightValue * 1.99 > 16.0
                                        ? 16.0
                                        : unitHeightValue * 1.99,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                FittedBox(
                                  child: Row(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 2.0),
                                            child: Image.asset(
                                                'assets/icons/wallet.png',
                                                width: 18.0,
                                                height: 18.0,
                                                fit: BoxFit.fitWidth),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Earn Upto",
                                                style: TextStyle(
                                                  color: thirdColor,
                                                  fontSize:
                                                  unitHeightValue * 1.8 > 14.0
                                                      ? 14.0
                                                      : unitHeightValue * 1.8,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              Text(
                                                "\u{20B9}${matchQuery[index].earnUpto}",
                                                style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize:
                                                  unitHeightValue * 1.99 > 16.0
                                                      ? 16.0
                                                      : unitHeightValue * 1.99,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 18.0,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 2.0),
                                            child: Image.asset(
                                                'assets/icons/slot.png',
                                                width: 20.5,
                                                height: 19.0,
                                                fit: BoxFit.fitWidth),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Slots",
                                                style: TextStyle(
                                                  color: thirdColor,
                                                  fontSize:
                                                  unitHeightValue * 1.8 > 14.0
                                                      ? 14.0
                                                      : unitHeightValue * 1.8,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "${matchQuery[index].joinRevuer}",
                                                    style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: unitHeightValue *
                                                          1.99 >
                                                          16.0
                                                          ? 16.0
                                                          : unitHeightValue * 1.99,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    "/${matchQuery[index].revuerLimit}",
                                                    style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize:
                                                      unitHeightValue * 1.8 > 14.0
                                                          ? 14.0
                                                          : unitHeightValue * 1.8,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
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
            ),
          );
        },
      ),
    )
        :  const SizedBox();
  }

  Widget showSocialIcon(String type) {
    if (type == "1") {
      return Image.asset(
        "assets/images/facebook.png",
        width: 30,
        height: 30,
      );
    } else if (type == "2") {
      return Image.asset(
        "assets/images/instagram.png",
        width: 30,
        height: 30,
      );
    } else if (type == "3") {
      return Image.asset(
        "assets/images/twitter.png",
        width: 30,
        height: 30,
      );
    } else if (type == "4") {
      return Image.asset(
        "assets/images/youtube.png",
        width: 30,
        height: 30,
      );
    } else if (type == "5") {
      return Image.asset(
        "assets/images/pinterest.png",
        width: 30,
        height: 30,
      );
    } else if (type == "6") {
      return Image.asset(
        "assets/images/linkedin.png",
        width: 30,
        height: 30,
      );
    } else {
      return const SizedBox();
    }
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
            "No Campaigns Found..",
            style: TextStyle(
                color: secondaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
