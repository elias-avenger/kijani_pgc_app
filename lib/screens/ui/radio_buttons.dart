import 'package:flutter/material.dart';

class RadioButtons extends StatelessWidget {
  const RadioButtons(
      {super.key,
      required this.groupValue,
      required this.firstBtnValue,
      required this.secondBtnValue,
      required this.firstBtnColor,
      required this.secondBtnColor,
      required this.onChanged,
      this.spacing = 20.0,
      this.btnSize = 1.25,
      this.textSize = 18.0});

  final String? groupValue;
  final String firstBtnValue;
  final String secondBtnValue;
  final Color? firstBtnColor;
  final Color? secondBtnColor;
  final Function(String?) onChanged;
  final double btnSize;
  final double spacing;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
          scale: btnSize,
          child: Radio(
            value: firstBtnValue,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: firstBtnColor,
            fillColor: WidgetStateProperty.all(firstBtnColor),
          ),
        ),
        Text(
          firstBtnValue,
          style: TextStyle(fontSize: textSize),
        ),
        SizedBox(width: spacing),
        Transform.scale(
          scale: btnSize,
          child: Radio(
            value: secondBtnValue,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: secondBtnColor,
            fillColor: WidgetStateProperty.all(secondBtnColor),
          ),
        ),
        Text(
          secondBtnValue,
          style: TextStyle(fontSize: textSize),
        ),
      ],
    );
  }
}
