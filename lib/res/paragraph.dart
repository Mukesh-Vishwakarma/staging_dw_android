
import 'package:flutter/material.dart';
import 'package:revuer/res/colors.dart';

class ParagraphText extends StatefulWidget {
  final String text;
  final TextStyle moreStyle;

  const ParagraphText({Key? key,required this.text,required this.moreStyle}) : super(key: key);

  @override
  State<ParagraphText> createState() => _ParagraphTextState();
}

class _ParagraphTextState extends State<ParagraphText> {
  String? firstHalf;
  String? secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > 240) {
      firstHalf = widget.text.substring(0, 240);
      secondHalf = widget.text.substring(240, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: secondHalf!.isEmpty
          ? Text(firstHalf!,style: widget.moreStyle)
          : Column(
        children: <Widget>[
          Text(flag ? "$firstHalf!..." : firstHalf! + secondHalf!,style:widget.moreStyle),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  flag ? "show more" : "show less",
                  style: const TextStyle(color: secondaryColor),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                flag = !flag;
              });
            },
          ),
        ],
      ),
    );
  }
}
