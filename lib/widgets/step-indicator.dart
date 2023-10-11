import 'package:flutter/material.dart';
import 'package:revuer/res/colors.dart';

class StepIndicator extends StatefulWidget {
  int totalStep=2;
  int step=1;
  StepIndicator({Key? key, required this.totalStep, required this.step}) : super(key: key);

  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> {
  @override
  Widget build(BuildContext context) {
    /*return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.totalStep,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 6.0,),
        itemBuilder: (context, index) {
          return Expanded(
            child: Container(
              height: 6.0,
              color: widget.step <= widget.totalStep ? primaryColor : Colors.white,
            ),
          );
        }
    );*/
    return Row(
      children: [
        for (int i = 0; i < widget.totalStep; i++)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: widget.totalStep == i+1 ? 0.0 : 8.0),
              height: 6.0,
              decoration: BoxDecoration(
                  color: widget.step >= i+1 ? primaryColor : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(20))
              ),

            ),
          ),
      ],
    );
  }
}
