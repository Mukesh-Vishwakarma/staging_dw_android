import 'package:flutter/material.dart';
import '../../res/colors.dart';

class DataRepository {
  static List<double> data = [];
  static final List<double> _data = [
    1080,
    3980,
    3100,
    4500,
    2020,
    3870
  ];

  static List<double> getData() {
    data = _data;
    return _data;
  }

  static void clearData() {
    data = [];
  }

  static List<String> getLabels() {
    List<String> labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jul'
    ];
    return labels;
  }

  static Color getColor(double value) {
    if (value < 2) {
      return Colors.amber.shade300;
    } else if (value < 4) {
      return Colors.amber.shade600;
    } else {
      return primaryColor;
    }
  }

  static Icon getIcon(double value) {
    if (value < 1) {
      return Icon(
        Icons.star_border,
        size: 24,
        color: getColor(value),
      );
    } else if (value < 2) {
      return Icon(
        Icons.star_half,
        size: 24,
        color: getColor(value),
      );
    } else {
      return Icon(
        Icons.star,
        size: 24,
        color: getColor(value),
      );
    }
  }
}