// toast_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';

void showToastGlobal(
  String message, {
  Color backgroundColor = Colors.black87,
  Color textColor = Colors.white,
  StyledToastAnimation animation = StyledToastAnimation.slideFromBottomFade,
  StyledToastAnimation reverseAnimation = StyledToastAnimation.fade,
  Duration duration = const Duration(seconds: 4),
  StyledToastPosition position = const StyledToastPosition(
    align: Alignment.topCenter,
    offset: 70,
  ),
}) {
  final context = Get.context;
  if (context == null) {
    debugPrint('⚠️ Get.context is null. Toast not shown.');
    return;
  }

  showToast(
    message,
    context: context,
    animation: animation,
    reverseAnimation: reverseAnimation,
    backgroundColor: backgroundColor,
    textStyle: TextStyle(color: textColor),
    borderRadius: BorderRadius.circular(8),
    position: position,
    duration: duration,
  );
}
