import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';

class RoleGuard extends GetMiddleware {
  final String role;

  RoleGuard(this.role);

  @override
  RouteSettings? redirect(String? route) {
    AuthController authController = Get.find<AuthController>();

    // Check if the user's role matches the required role for the route
    if (authController.userRole.value != role) {
      return const RouteSettings(
          name: '/not-authorized'); // Redirect to an unauthorized page
    }
    return null; // Proceed if authorized
  }
}
