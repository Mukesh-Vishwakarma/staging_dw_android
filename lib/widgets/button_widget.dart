import 'package:flutter/material.dart';
import '../res/colors.dart';

class ButtonWidget extends StatelessWidget {
  final String? buttonText;
  final Widget? buttonContent;
  final Color textColor;
  final Color buttonColor;
  final Alignment textAlign;
  final bool isShadow;
  final VoidCallback onPressed;
  final double width;

  const ButtonWidget({
    Key? key,
    this.buttonText,
    this.buttonContent,
    this.textColor = Colors.white,
    this.buttonColor = primaryColor,
    this.textAlign = Alignment.center,
    this.isShadow = true,
    this.width = double.infinity,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 48,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            boxShadow: isShadow ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null
        ),
        child: buttonText == null ?
          buttonContent! :
          Text(
            buttonText!,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0
            ),
          ),
      ),
    );

  }

}
