import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    AuthController authController = Get.find<AuthController>();
    if (authController.isAuthenticated.value == false) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
