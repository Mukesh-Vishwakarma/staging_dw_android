import 'package:flutter/material.dart';
import 'colors.dart';
import 'font_family.dart';

final lightTheme = ThemeData(
    fontFamily: FontFamily.poppins,
    brightness: Brightness.light,
    primaryColor: primaryColor,
);

final darkTheme = ThemeData(
  fontFamily: FontFamily.poppins,
  brightness: Brightness.dark,
  primaryColor: primaryColor,
);