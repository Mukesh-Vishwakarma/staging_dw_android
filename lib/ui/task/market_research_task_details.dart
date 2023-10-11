import 'package:flutter/material.dart';

import '../../networking/models/task_list_model.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../campaign/my-campaign-details.dart';

class MarketResearchTaskDetails extends StatefulWidget {
  final TaskData taskData;
  final bool isLastIndex;

  const MarketResearchTaskDetails({Key? key, required this.taskData, required this.isLastIndex}) : super(key: key);

  @override
  State<MarketResearchTaskDetails> createState() => _MarketResearchTaskDetailsState();
}

class _MarketResearchTaskDetailsState extends State<MarketResearchTaskDetails> {
  double statusBarHeight = 5.0;

  void _openMyPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/my-campaign-details'),
        builder: (context) => const MyCampaignDetailsScreen(index: 1),
      ),
    );
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
              child: ClipPath(
                clipper: OvalClipper(),
                child: Container(
                  width: double.infinity,
                  height: 242.0,
                  color: secondaryColor,
                ),
              ),
            ),
          /*  Padding(
              padding:
                  EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 5),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _openMyPage(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(2.0, 5.0, 7.0, 5.0),
                      child: Image.asset(
                        'assets/icons/back.png',
                        width: 23.0,
                        height: 23.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    widget.taskType == 1
                        ? "Task 1: Buy a product"
                        : "Task 2: Submit Review",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 80.0),
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
                      child: widget.taskType == 1
                          ? SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/interests.png',
                                        width: 20.01,
                                        height: 25.87,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      const Text(
                                        "Product Details",
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5.0),
                                        child: Image.asset(
                                          'assets/icons/right-arrow.png',
                                          width: 22.0,
                                          height: 12.0,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      const Expanded(
                                        child: Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sit sit tempus egestas praesent integer enim viverra amet. Sed arcu sit sagittis urna varius. Ut congue purus tortor sed risus eros, tristique tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sit sit tempus egestas praesent integer enim viverra amet. Sed arcu sit sagittis urna varius. Ut congue purus tortor sed risus eros, tristique tortor.  ",
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'assets/icons/link.png',
                                        width: 18.0,
                                        height: 18.0,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Product on",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/amazon.png',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  const Text(
                                                    "Amazon",
                                                    style: TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 30.0,
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/flipkart.png',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  const Text(
                                                    "Flipkart",
                                                    style: TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 30.0,
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/myntra.png',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  const Text(
                                                    "Myntra",
                                                    style: TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 30.0,
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/meesho.png',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(
                                                    height: 2.0,
                                                  ),
                                                  const Text(
                                                    "Meesho",
                                                    style: TextStyle(
                                                        color: secondaryColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'assets/icons/upload.png',
                                        width: 20.0,
                                        height: 21.0,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Purchased Product Sreenshot",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              DottedBorder(
                                                dashPattern: const [6, 4],
                                                color: thirdColor,
                                                borderType: BorderType.RRect,
                                                radius:
                                                    const Radius.circular(10),
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12)),
                                                  child: SizedBox(
                                                    height: 85.0,
                                                    width: 85.0,
                                                    child: Center(
                                                      child: Image.asset(
                                                        'assets/icons/plus.png',
                                                        width: 20.0,
                                                        height: 20.0,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/interests.png',
                                        width: 20.01,
                                        height: 25.87,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      const Text(
                                        "Submit Review Details",
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 5.0),
                                        child: Image.asset(
                                          'assets/icons/right-arrow.png',
                                          width: 22.0,
                                          height: 12.0,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      const Expanded(
                                        child: Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sit sit tempus egestas praesent integer enim viverra amet. Sed arcu sit sagittis urna varius. Ut congue purus tortor sed risus eros, tristique tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sit sit tempus egestas praesent integer enim viverra amet. Sed arcu sit sagittis urna varius. Ut congue purus tortor sed risus eros, tristique tortor.  ",
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 40.0,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'assets/icons/upload.png',
                                        width: 20.0,
                                        height: 21.0,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Reviewed Product Sreenshot",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(
                                            height: 20.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              DottedBorder(
                                                dashPattern: const [6, 4],
                                                color: thirdColor,
                                                borderType: BorderType.RRect,
                                                radius:
                                                    const Radius.circular(10),
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12)),
                                                  child: SizedBox(
                                                    height: 85.0,
                                                    width: 85.0,
                                                    child: Center(
                                                      child: Image.asset(
                                                        'assets/icons/plus.png',
                                                        width: 20.0,
                                                        height: 20.0,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),*/
            /*Positioned(
              bottom: 24.0,
              left: 16.0,
              right: 16.0,
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        buttonText: "SAVE",
                        buttonColor: thirdColor,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ButtonWidget(
                        buttonText: widget.taskType == 1
                            ? "SAVE & NEXT"
                            : "SUBMIT TASKS",
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
