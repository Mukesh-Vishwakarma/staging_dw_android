import 'package:flutter/material.dart';
import '../../res/colors.dart';
import '../../res/constants.dart';
import '../../widgets/button_widget.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Image(image: AssetImage('assets/images/hero-welcome.png')),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              const Text(
                Strings.welcomeTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                Strings.welcomeSubTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: thirdColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
              width: double.infinity,
              child: ButtonWidget(
                buttonContent: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "LET'S EARN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    Image.asset(
                      "assets/icons/arrow-right.png",
                      width: 22,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

