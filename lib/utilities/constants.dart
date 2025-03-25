import 'package:flutter/material.dart';

ButtonStyle kBlackButtonStyle = ButtonStyle(
  backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
  padding:
      WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(16)),
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
);
Color kijaniBlue = const Color(0xff23566d);
Color kijaniGreen = const Color(0xff265e3c);
Color kijaniBrown = const Color(0xff7c3d1c);
