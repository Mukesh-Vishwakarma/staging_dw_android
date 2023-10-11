import 'package:flutter/material.dart';
import 'package:revuer/networking/models/camp_trending_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../networking/models/my_camp_model.dart';
import '../../res/colors.dart';
import '../../shared_preference/preference_provider.dart';
import '../campaign/campaign-details.dart';
import '../campaign/my-campaign-details-pending.dart';
import '../campaign/my-campaign-details.dart';

class CustomMyCampaignSearchDelegate extends SearchDelegate {

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      backgroundColor: secondaryColor,
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(color: secondaryColor),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
      ),
    );
  }

  List<MyCampaignModel> campaignSearchList = [];

  CustomMyCampaignSearchDelegate(this.campaignSearchList);

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
    List<MyCampaignModel> matchQuery = [];
    for (var campaignList in campaignSearchList) {
      if (query.isNotEmpty &&
          campaignList.campaignName!
              .toLowerCase()
              .contains(query.toLowerCase())) {
        matchQuery.add(campaignList);
      }
    }
    return matchQuery.isNotEmpty
        ? Container(
            margin: EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: matchQuery.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    SharedPrefProvider.setString(
                        SharedPrefProvider.campaignToken,
                        "${matchQuery[index].campaignToken}");
                    SharedPrefProvider.setString(
                        SharedPrefProvider.brandloginUniqueToken,
                        "${matchQuery[index].brandloginUniqueToken}");

                    if (matchQuery[index].revuerCampaignStatus == "0" &&
                        matchQuery[index].revuerCampaignStatus == "6") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MyCampaignDetailsPendingScreen()));
                    } else if (matchQuery[index].revuerCampaignStatus == "2") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/campaign-task'),
                          builder: (context) => MyCampaignDetailsScreen(),
                        ),
                      );
                    }
                    if (matchQuery[index].revuerCampaignStatus == "3") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CampaignDetailsScreen()));
                    }
                    if (matchQuery[index].revuerCampaignStatus == "4") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/campaign-task'),
                          builder: (context) => MyCampaignDetailsScreen(),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 20.0, 10.0, 20.0),
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
                          width: 18.0,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${matchQuery[index].campaignName}",
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${matchQuery[index].brandName}",
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/wallet.png',
                                            width: 17.0,
                                            height: 17.0,
                                            fit: BoxFit.fitWidth),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "\u{20B9}${matchQuery[index].earnUpto}",
                                          style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_sharp,
                                  size: 18.0, color: secondaryColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Expanded(child: noCampaign());
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<MyCampaignModel> matchQuery = [];
    for (var campaignList in campaignSearchList) {
      if (query.isNotEmpty &&
          campaignList.campaignName!
              .toLowerCase()
              .contains(query.toLowerCase())) {
        matchQuery.add(campaignList);
      }
    }
    return matchQuery.isNotEmpty
        ? Container(
            margin: EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: matchQuery.length,
              itemBuilder: (context, index) {
                var result = matchQuery[index];
                return InkWell(
                  onTap: () {
                    SharedPrefProvider.setString(
                        SharedPrefProvider.campaignToken,
                        "${matchQuery[index].campaignToken}");
                    SharedPrefProvider.setString(
                        SharedPrefProvider.brandloginUniqueToken,
                        "${matchQuery[index].brandloginUniqueToken}");

                    if (matchQuery[index].revuerCampaignStatus == "0" &&
                        matchQuery[index].revuerCampaignStatus == "6") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MyCampaignDetailsPendingScreen()));
                    } else if (matchQuery[index].revuerCampaignStatus == "2") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/campaign-task'),
                          builder: (context) => MyCampaignDetailsScreen(),
                        ),
                      );
                    }
                    if (matchQuery[index].revuerCampaignStatus == "3") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CampaignDetailsScreen()));
                    }
                    if (matchQuery[index].revuerCampaignStatus == "4") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/campaign-task'),
                          builder: (context) => MyCampaignDetailsScreen(),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 20.0, 10.0, 20.0),
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
                          width: 18.0,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${matchQuery[index].campaignName}",
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${matchQuery[index].brandName}",
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/icons/wallet.png',
                                            width: 17.0,
                                            height: 17.0,
                                            fit: BoxFit.fitWidth),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "\u{20B9}${matchQuery[index].earnUpto}",
                                          style: const TextStyle(
                                            color: secondaryColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_sharp,
                                  size: 18.0, color: secondaryColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox(); /*ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        return  InkWell(
          onTap: () {
            SharedPrefProvider.setString(SharedPrefProvider.campaignToken,
                "${matchQuery[index].campaignToken}");
            SharedPrefProvider.setString(SharedPrefProvider.brandloginUniqueToken,
                "${matchQuery[index].brandloginUniqueToken}");

            if(matchQuery[index].revuerCampaignStatus == "0" &&
                matchQuery[index].revuerCampaignStatus == "6"){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const MyCampaignDetailsPendingScreen()));
            }else if(matchQuery[index].revuerCampaignStatus == "2"){
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/campaign-task'),
                  builder: (context) => MyCampaignDetailsScreen(),
                ),
              );
            }if(matchQuery[index].revuerCampaignStatus == "3"){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CampaignDetailsScreen()));
            }if(matchQuery[index].revuerCampaignStatus == "4"){
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/campaign-task'),
                  builder: (context) => MyCampaignDetailsScreen(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 20.0, 10.0, 20.0),
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
                        baseColor:
                        const Color.fromRGBO(191, 191, 191, 0.5254901960784314),
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
                  width: 18.0,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${matchQuery[index].campaignName}",
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${matchQuery[index].brandName}",
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/wallet.png',
                                    width: 17.0,
                                    height: 17.0,
                                    fit: BoxFit.fitWidth),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "\u{20B9}${matchQuery[index].earnUpto}",
                                  style: const TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_sharp,
                          size: 18.0, color: secondaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );*/
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
