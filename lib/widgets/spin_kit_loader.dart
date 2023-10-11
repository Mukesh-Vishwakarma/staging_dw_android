import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../res/colors.dart';

class SpinKitLoader extends StatefulWidget {
  const SpinKitLoader({super.key});

  @override
  State<SpinKitLoader> createState() => _SpinKitLoaderState();
}

class _SpinKitLoaderState extends State<SpinKitLoader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: primaryColor,
      ),
      child: const SpinKitThreeBounce(
        color: Colors.white,
        size: 27.0,
      ),
    );
  }
}
