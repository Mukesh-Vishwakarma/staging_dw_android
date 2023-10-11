import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../res/colors.dart';

typedef OnCodeEnteredCompletion = void Function(String value);
typedef OnCodeChanged = void Function(String value);

class OtpTextField extends StatefulWidget {
  final bool showCursor;
  final int numberOfFields;
  final double borderWidth;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color disabledBorderColor;
  final Color borderColor;
  final Color? cursorColor;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final OnCodeEnteredCompletion? onSubmit;
  final OnCodeEnteredCompletion? onCodeChanged;
  final bool obscureText;
  final bool showFieldAsBox;
  final bool enabled;
  final bool filled;
  final bool autoFocus;
  final bool readOnly;
  bool clearText;
  final bool hasCustomInputDecoration;
  final Color fillColor;
  final BorderRadius borderRadius;
  final InputDecoration? decoration;

  OtpTextField({
    this.showCursor = true,
    this.numberOfFields = 4,
    this.textStyle = const TextStyle(
        color: secondaryColor, fontSize: 20.0, fontWeight: FontWeight.w600),
    this.clearText = false,
    this.keyboardType = TextInputType.number,
    this.borderWidth = 2.0,
    this.cursorColor,
    this.disabledBorderColor = const Color(0xFFE7E7E7),
    this.enabledBorderColor = thirdColor,
    this.borderColor = thirdColor,
    this.focusedBorderColor = thirdColor,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.onSubmit,
    this.obscureText = false,
    this.showFieldAsBox = false,
    this.enabled = true,
    this.autoFocus = false,
    this.hasCustomInputDecoration = false,
    this.filled = false,
    this.fillColor = const Color(0xFFFFFFFF),
    this.readOnly = false,
    this.decoration,
    this.onCodeChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  late List<String?> _verificationCode;
  late List<FocusNode?> _focusNodes;
  late List<TextEditingController?> _textControllers;

  @override
  void initState() {
    super.initState();

    _verificationCode = List<String?>.filled(widget.numberOfFields, null);
    _focusNodes = List<FocusNode?>.filled(widget.numberOfFields, null);
    _textControllers = List<TextEditingController?>.filled(
      widget.numberOfFields,
      null,
    );
  }

  @override
  void didUpdateWidget(covariant OtpTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.clearText != widget.clearText && widget.clearText == true) {
      for (var controller in _textControllers ){
        controller?.clear();
      }
      _verificationCode = List<String?>.filled(widget.numberOfFields, null);
      setState((){
        widget.clearText = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textControllers
        .forEach((TextEditingController? controller) => controller?.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return generateTextFields(context);
  }

  Widget _buildTextField({required BuildContext context, required int index}) {
    return Container(
      width: 50.0,
      height: 50.0,
      child: TextField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        showCursor: widget.showCursor,
        keyboardType: widget.keyboardType,
        textAlign: TextAlign.center,
        maxLength: 1,
        readOnly: widget.readOnly,
        style: widget.textStyle,
        autofocus: widget.autoFocus,
        cursorColor: widget.cursorColor,
        controller: _textControllers[index],
        focusNode: _focusNodes[index],
        enabled: widget.enabled,
        textAlignVertical: TextAlignVertical.center,
        decoration: widget.hasCustomInputDecoration
            ? widget.decoration
            : InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
          counterText: "",
          filled: widget.filled,
          fillColor: widget.fillColor,
          focusedBorder: widget.showFieldAsBox
              ? outlineBorder(widget.focusedBorderColor)
              : underlineInputBorder(widget.focusedBorderColor),
          enabledBorder: widget.showFieldAsBox
              ? outlineBorder(widget.enabledBorderColor)
              : underlineInputBorder(widget.enabledBorderColor),
          disabledBorder: widget.showFieldAsBox
              ? outlineBorder(widget.disabledBorderColor)
              : underlineInputBorder(widget.disabledBorderColor),
          border: widget.showFieldAsBox
              ? outlineBorder(widget.borderColor)
              : underlineInputBorder(widget.borderColor),
        ),
        obscureText: widget.obscureText,
        onChanged: (String value) {
          //save entered value in a list
          _verificationCode[index] = value;
          onCodeChanged(verificationCode: value);
          changeFocusToNextNodeWhenValueIsEntered(
            value: value,
            indexOfTextField: index,
          );
          onSubmit(verificationCode: _verificationCode);
        },
      ),
    );
  }

  OutlineInputBorder outlineBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        width: widget.borderWidth,
        color: color,
      ),
      borderRadius: widget.borderRadius,
    );
  }

  UnderlineInputBorder underlineInputBorder(Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: widget.borderWidth,
      ),
    );
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.numberOfFields, (int i) {
      addFocusNodeToEachTextField(index: i);
      addTextEditingControllerToEachTextField(index: i);

      return _buildTextField(context: context, index: i);
    });

    return Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: textFields,
    );
  }

  void addFocusNodeToEachTextField({required int index}) {
    if (_focusNodes[index] == null) {
      _focusNodes[index] = FocusNode();
    }
  }

  void addTextEditingControllerToEachTextField({required int index}) {
    if (_textControllers[index] == null) {
      _textControllers[index] = TextEditingController();
    }
  }

  void changeFocusToNextNodeWhenValueIsEntered({
    required String value,
    required int indexOfTextField,
  }) {
    //only change focus to the next textField if the value entered has a length greater than one
    if (value.length > 0) {
      //if the textField in focus is not the last textField,
      // change focus to the next textField
      if (indexOfTextField + 1 != widget.numberOfFields) {
        //change focus to the next textField
        FocusScope.of(context).requestFocus(_focusNodes[indexOfTextField + 1]);
      } else {
        //if the textField in focus is the last textField, unFocus after text changed
        _focusNodes[indexOfTextField]?.unfocus();
      }
    }else if(indexOfTextField > 0){
      FocusScope.of(context).requestFocus(_focusNodes[indexOfTextField - 1]);
    }
  }

  void onSubmit({required List<String?> verificationCode}) {
    if (verificationCode.every((String? code) => code != null && code != '')) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(verificationCode.join());
      }
    }
  }

  void onCodeChanged({required String verificationCode}) {
    if (widget.onCodeChanged != null) {
      widget.onCodeChanged!(verificationCode);
    }
  }

}