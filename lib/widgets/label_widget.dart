import 'package:flutter/material.dart';
import '../res/colors.dart';

class LabelWidget extends StatelessWidget {
  final String labelText;
  final Color textColor;
  final TextAlign textAlign;
  final bool mandatory;

  const LabelWidget(
      {Key? key,
      required this.labelText,
      this.textColor = thirdColor,
      this.textAlign = TextAlign.start,
      this.mandatory = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
        children: [
          TextSpan(
              text: mandatory ? '*' : '',
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
    /*return Text(
      labelText,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );*/
  }
}
