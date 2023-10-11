import 'package:flutter/material.dart';
import 'package:revuer/networking/models/my_campaign_details_model.dart';

import '../../res/colors.dart';
import '../../res/paragraph.dart';

class MyCampaignDetailsTab1Screen extends StatefulWidget {
  final MyCampaignDetailsModel? data;

  const MyCampaignDetailsTab1Screen({Key? key, required this.data}) : super(key: key);

  @override
  State<MyCampaignDetailsTab1Screen> createState() =>
      _MyCampaignDetailsTab1ScreenState();
}

class _MyCampaignDetailsTab1ScreenState
    extends State<MyCampaignDetailsTab1Screen> {

  @override
  Widget build(BuildContext context) {
    if (widget.data != null) {
      return Container(
          margin: const EdgeInsets.only(bottom: 5.0, left: 16.0, right: 16.0),
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
              ]),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 50.0),
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      widget.data!.image!,
                      width: 78.0,
                      height: 78.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: 78.0,
                          height: 78.0,
                          child: Image.asset(
                            width: 60.0,
                            height: 60.0,
                            'assets/images/error_image.png',
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       /* Text(
                          "${widget.data!.campaignName}",
                          style: const TextStyle(
                            color: secondaryColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),*/
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.data?.categoryName}",
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Text(
                              "${widget.data?.camTypeName}",
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2.0),
                          child: Image.asset('assets/icons/wallet.png',
                              width: 19.0, height: 19.0, fit: BoxFit.fitWidth),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Earn Upto",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Text(
                              "\u{20B9}${widget.data!.earnUpto}",
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/compaign.png',
                        width: 24.75,
                        height: 20.0,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Campaign Objective",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10.0),
                            ParagraphText(
                              moreStyle: const TextStyle(color: secondaryColor,
                                  fontSize: 14, fontWeight: FontWeight.w400), text: "${widget.data!.campaignObj}",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/task.png',
                        width: 20.01,
                        height: 25.87,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tasks",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10.0),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.data!.campaignTaskNames!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return Container(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      "Task ${entry.key + 1}: ${entry.value}",
                                      style: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  );
                                }).toList()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  widget.data!.dos![0] == ""? const SizedBox() :Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/check.png',
                        width: 20.0,
                        height: 20.0,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Do’s",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10.0),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.data!.dos!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return Container(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        /*Image.asset(
                                          'assets/icons/like.png',
                                          width: 20.0,
                                          height: 20.0,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),*/
                                        Expanded(
                                          child: ParagraphText(
                                            moreStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400), text: entry.value,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  widget.data!.donts![0] == ""? const SizedBox(): Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/close.png',
                        width: 20.0,
                        height: 20.0,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Don’ts",
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10.0),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.data!.donts!
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return Container(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        /*Image.asset(
                                          'assets/icons/unlike.png',
                                          width: 20.0,
                                          height: 20.0,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),*/
                                        Expanded(
                                          child: ParagraphText(
                                            moreStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400), text: entry.value,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  widget.data?.additionals != ""
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/compaign.png',
                              width: 24.75,
                              height: 20.0,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Additional Details",
                                    style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 10.0),
                                  ParagraphText(
                                    moreStyle: const TextStyle(
                                        color: secondaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400), text: "${widget.data?.additionals}",
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(
                          height: 0.0,
                        ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/star.png',
                              width: 20.0,
                              height: 20.0,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              widget.data!.revuerLimit!,
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Text(
                              "Revuers Approved",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/clock.png',
                              width: 20.0,
                              height: 20.0,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              "${widget.data!.totaldays!} Days",
                              style: const TextStyle(
                                color: secondaryColor,
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Text(
                              "Campaign Days Left",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ],
          ));
    } else {
      return const Center(
          child: CircularProgressIndicator(
        color: primaryColor,
      ));
    }
  }
}
