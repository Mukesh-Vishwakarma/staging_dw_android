import 'package:flutter/material.dart';

import '../../res/colors.dart';

class CampaignRecentAddListItem extends StatefulWidget {
  final int index;
  const CampaignRecentAddListItem({Key? key, this.index=0}) : super(key: key);

  @override
  State<CampaignRecentAddListItem> createState() => _CampaignRecentAddListItemState();
}

class _CampaignRecentAddListItemState extends State<CampaignRecentAddListItem> {
  @override
  Widget build(BuildContext context) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.index == 0 ? const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ) : BorderRadius.zero
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/campaign-details');
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
              ]
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  padding: const EdgeInsets.all(11.0),
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
                padding: const EdgeInsets.fromLTRB(13.0, 17.0, 10.0, 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        'assets/images/dummy1.png',
                        width: 130.0,
                        height: 130.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14.0,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Review recent added product",
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: unitHeightValue * 1.8 > 14.0 ? 14.0 : unitHeightValue * 1.8,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2.0,),
                          Text(
                            "Shoppers",
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: unitHeightValue * 1.99 > 16.0 ? 16.0 : unitHeightValue * 1.99,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5.0,),
                          Row(
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
                                        fit: BoxFit.fitWidth
                                    ),
                                  ),
                                  const SizedBox(width: 5.0,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Earn Upto",
                                        style: TextStyle(
                                          color: thirdColor,
                                          fontSize: unitHeightValue * 1.8 > 14.0 ? 14.0 : unitHeightValue * 1.8,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0,),
                                      Text(
                                        "\u{20B9}1050",
                                        style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: unitHeightValue * 1.99 > 16.0 ? 16.0 : unitHeightValue * 1.99,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(width: 18.0,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2.0),
                                    child: Image.asset(
                                        'assets/icons/slot.png',
                                        width: 20.5,
                                        height: 19.0,
                                        fit: BoxFit.fitWidth
                                    ),
                                  ),
                                  const SizedBox(width: 5.0,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Slots",
                                        style: TextStyle(
                                          color: thirdColor,
                                          fontSize: unitHeightValue * 1.8 > 14.0 ? 14.0 : unitHeightValue * 1.8,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "35",
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: unitHeightValue * 1.99 > 16.0 ? 16.0 : unitHeightValue * 1.99,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "/70",
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: unitHeightValue * 1.8 > 14.0 ? 14.0 : unitHeightValue * 1.8,
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
  }
}
