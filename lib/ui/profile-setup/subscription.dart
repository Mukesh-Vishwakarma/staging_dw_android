import 'package:flutter/material.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/step-indicator.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;

  List featuresList = [
    "Lorem ipsum dolor sit ame",
    "Sit aliquet risus neque enim",
    "Euismod pharetra fusce hendrerit quis scelerisque pellentesque",
    "Sit aliquet risus neque enim",
    "Venenatis purus, posuere imperdiet"
  ];

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/social-profiles');
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
              padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 45),
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
                  const SizedBox(height: 20.0,),
                  const Text(
                    Strings.setupProfile,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Step 3 : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "Subscription",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8.0,),
                  StepIndicator(totalStep: 3, step: 3),
                  const SizedBox(height: 15.0,),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50.0),
                      /*padding: const EdgeInsets.all(16.0),*/
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
                          ]
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Subscription",
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 8.0,),
                                Text(
                                  "Purchace a plan for participating in campaign",
                                  style: TextStyle(
                                    color: thirdColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14),
                            color: primaryColorLight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Subscription Plan",
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                Column(
                                  children: const [
                                    Text(
                                      "\u{20B9}199",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    Text(
                                      "per month",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Features",
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                ListView.separated(
                                    itemCount: featuresList.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20.0,),
                                    itemBuilder: (BuildContext context, int index) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/icons/check-light.png',
                                            width: 34.0,
                                            height: 34.0,
                                            fit: BoxFit.fitWidth,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                featuresList[index].toString(),
                                                style: const TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w400
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24.0,
              left: 16.0,
              right: 16.0,
              child: ButtonWidget(
                buttonContent: const Text(
                  "PURCHASE A PLAN",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/payment-mode');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
