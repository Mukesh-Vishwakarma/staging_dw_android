import 'package:flutter/material.dart';
import '../../ui/profile-setup/payment-mode-profile.dart';
import '../../res/colors.dart';
import '../../shaps/flutter_custom_clippers.dart';
import '../../res/constants.dart';
import '../../widgets/step-indicator.dart';

class PaymentModeScreen extends StatefulWidget {
  const PaymentModeScreen({Key? key}) : super(key: key);

  @override
  State<PaymentModeScreen> createState() => _PaymentModeScreenState();
}

class _PaymentModeScreenState extends State<PaymentModeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double statusBarHeight = 5.0;

  void _openMyPage() {
    Navigator.pushReplacementNamed(context, '/subscription');
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
              padding: EdgeInsets.fromLTRB(16.0, (statusBarHeight + 15.0), 16.0, 10),
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
                  const Text(
                    "Step 3 : 3",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8.0,),
                  StepIndicator(totalStep: 3, step: 3),
                  const SizedBox(height: 15.0,),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 50.0),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Select any one patment method",
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20.0,),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    settings: const RouteSettings(name: '/payment-mode-profile'),
                                    builder: (context) => PaymentModeProfileScreen(
                                        location: "paymentModeProfile",
                                        patmentMethod: 1
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
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
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 19.5, 38.0,19.5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/icons/upi.png',
                                            width: 40.0,
                                            height: 55.39,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          const Text(
                                            "UPI payment",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.arrow_forward_ios_sharp, size: 18.0, color: secondaryColor),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    settings: const RouteSettings(name: '/payment-mode-profile'),
                                    builder: (context) => PaymentModeProfileScreen(
                                        location: "paymentModeProfile",
                                        patmentMethod: 2
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
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
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 19.5, 38.0,19.5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/icons/bank.png',
                                            width: 51.01,
                                            height: 51.01,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          const Text(
                                            "Bank Transfer",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.arrow_forward_ios_sharp, size: 18.0, color: secondaryColor),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),

                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
