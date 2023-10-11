import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color primaryColor = Color(0xffFCB43C);
const Color primaryLightColor = Color(0xfffcd999);
const Color primaryColorLight = Color(0xffFFF4E2);
const Color primaryColorAlpha1 = Color(0x20FCB43C);
const Color secondaryColor = Color(0xff001540);
const Color thirdColor = Color(0xff95A5A6);
const Color fadeGreyColor = Color(0x3395a5a6);
const Color grayColor = Color(0xffEEEEEE);
const Color grayColorD = Color(0xffEBF0F2);

const Color cdColor1 = Color(0xffF4A409);
const Color cdColor2 = Color(0xff6D6D6D);
const Color cdColor3 = Color(0xff8E5340);

const Color pdColor = Color(0xffECDEFF);
const Color pdDarkColor = Color(0xff6200EA);
const Color onGoingColor = Color(0xff3C94FC);
const Color completedColor = Color(0xff2ECC71);
const Color rejectColor = Color(0xfff5adad);
const Color rejectDarkColor = Color(0xffee5454);

Gradient cdGradient1 = const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xffFBD06C),
    Color.fromRGBO(255, 236, 191, 0.4),
  ],
);

Gradient cdGradient2 = const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xffAFACA6),
    Color(0xffeeedec),
  ],
);

Gradient cdGradient3 = const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xffFBA88E),
    Color.fromRGBO(250, 168, 142, 0.3),
  ],
);
