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
Color kGreyText = const Color(0XFFBFBFBF);

//date picker style
DatePickerThemeData kPickerStyle = DatePickerThemeData(
  backgroundColor: Colors.white, // Background of the date picker
  headerBackgroundColor: Colors.black, // Header background
  headerForegroundColor: Colors.white, // Header text/icon color
  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.blue; // Highlight for selected date
    }
    return Colors.grey[200]; // Default day background
  }),
  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return Colors.white; // Text color for selected date
    }
    return Colors.black; // Default day text color
  }),
  todayBackgroundColor:
      WidgetStateProperty.all(Colors.black26), // Today's date background
  todayForegroundColor:
      WidgetStateProperty.all(Colors.black), // Today's date text color
  rangeSelectionBackgroundColor: Colors.black.withOpacity(0.2),
);
