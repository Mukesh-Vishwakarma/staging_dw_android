import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  Widget? Child;
  CustomDialog({Key? key, this.Child}) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
          width: MediaQuery.of(context).size.width,
          child: widget.Child,
        ),
      ],
    );
  }
}
