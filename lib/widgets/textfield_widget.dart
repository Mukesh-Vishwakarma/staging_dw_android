import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../res/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? textController;
  final String? placeholder;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final bool isImg;
  final bool isSuffixImg;
  final Widget? imgIcon;
  final Widget? imgSuffixIcon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final int maxLength;
  final textCaps;
  final initialValue;
  final showPasswordVisiblityIcon;
  final Color textColor;
  final Color hintTextColor;
  final Color boxShadowColor;
  final double blurRadius;
  final bool filled;
  final bool readOnly;
  final bool digitOnly;

  const CustomTextField({
    Key? key,
    this.textController,
    this.placeholder,
    this.prefixIcon,
    this.isImg = false,
    this.imgIcon,
    this.suffixIcon,
    this.isSuffixImg = false,
    this.imgSuffixIcon,
    this.onChanged,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.maxLength = 255,
    this.textCaps,
    this.initialValue,
    this.showPasswordVisiblityIcon = false,
    this.digitOnly = false,
    this.hintTextColor = thirdColor,
    this.textColor = secondaryColor,
    this.filled = false,
    this.boxShadowColor = Colors.transparent,
    this.blurRadius = 0.0,
    this.readOnly = false
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  bool passwordIconVisiblity = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: double.infinity,
        // height: 50.0,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.boxShadowColor,
                spreadRadius: 0,
                blurRadius: widget.blurRadius,
                offset: const Offset(0, 0),
              )
            ],

        ),
        child: TextFormField(
          inputFormatters: widget.digitOnly ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ] : [],
          textCapitalization: widget.textCaps ?? TextCapitalization.none,
          obscureText: widget.showPasswordVisiblityIcon
              ? passwordIconVisiblity == false
              ? true
              : false
              : false,
          controller: widget.textController,
          readOnly: widget.readOnly,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.next,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          autofocus: false,
          style: TextStyle(color: widget.textColor, fontSize: 16.0, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              focusedBorder: TextFieldStyles.inputfocusedStyle,
              enabledBorder: TextFieldStyles.inputBorderStyle,
              errorBorder: TextFieldStyles.inputBorderStyle,
              focusedErrorBorder: TextFieldStyles.inputBorderStyle,
              filled: true,
              fillColor: Colors.white,
              hintText: widget.placeholder,
              hintStyle: TextStyle(
                  color: widget.hintTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400
              ),
              counterText: "",
              prefixIconConstraints: const BoxConstraints(
                  minHeight: 25.0,
                  minWidth: 25.0
              ),
              prefixIcon: widget.isImg ? widget.imgIcon : widget.prefixIcon,
              suffixIcon: widget.showPasswordVisiblityIcon
                  ? GestureDetector(
                child: passwordIconVisiblity == false
                    ? Icon(Icons.visibility_off, color: widget.hintTextColor)
                    : Icon(Icons.visibility, color: widget.hintTextColor),
                onTap: () {
                  if (widget.showPasswordVisiblityIcon) {
                    passwordIconVisiblity == false
                        ? passwordIconVisiblity = true
                        : passwordIconVisiblity = false;
                    setState(() {});
                  }
                },
              )
                  : widget.isSuffixImg ? widget.imgSuffixIcon : widget.suffixIcon),
        ),

      ),
    );
  }
}

class TextFieldStyles {
  TextFieldStyles._();

  static const inputBorderStyle = OutlineInputBorder (
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide:BorderSide(
        color: grayColor,
        width: 1,
      )
  );

  static const inputfocusedStyle = OutlineInputBorder (
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide:BorderSide(
        color: primaryColor,
        width: 1,
      )
  );

}
