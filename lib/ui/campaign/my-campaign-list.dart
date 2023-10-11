import 'package:flutter/material.dart';
import 'package:revuer/networking/models/my_camp_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../res/colors.dart';
import '../../shared_preference/preference_provider.dart';
import 'my-campaign-details-pending.dart';
import 'my-campaign-details.dart';

class MyCampaignListItem extends StatefulWidget {
  final String screenType;
  final int index;
  final List<MyCampaignModel> data;

  const MyCampaignListItem(
      {Key? key, this.screenType = "", this.index = 0, required this.data})
      : super(key: key);

  @override
  State<MyCampaignListItem> createState() => _MyCampaignListItemState();
}

class _MyCampaignListItemState extends State<MyCampaignListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SharedPrefProvider.setString(SharedPrefProvider.campaignToken,
            "${widget.data[widget.index].campaignToken}");
        SharedPrefProvider.setString(SharedPrefProvider.brandloginUniqueToken,
            "${widget.data[widget.index].brandloginUniqueToken}");
        widget.screenType == "onGoing"
            ? Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/campaign-task'),
                  builder: (context) => MyCampaignDetailsScreen(),
                ),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const MyCampaignDetailsPendingScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 20.0, 10.0, 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                "${widget.data[widget.index].image}",
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
                          "${widget.data[widget.index].campaignName}",
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
                          "${widget.data[widget.index].brandName}",
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
                              "\u{20B9}${widget.data[widget.index].earnUpto}",
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
  }
}
