import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/models/user_model.dart';
import 'package:kijani_pmc_app/repositories/user_repository.dart';
import '../services/local_storage.dart';

class UserController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final LocalStorage _localStorage = LocalStorage();

  final emailController = TextEditingController();
  final codeController = TextEditingController();

  final branchData = <String, dynamic>{}.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  Future<void> authenticate() async {
    try {
      final user = await _userRepo.checkUser(
        email: emailController.text,
        code: codeController.text,
      );

      if (user == null) {
        _showSnackbar("Wrong Credentials", "Check Email or Code",
            isError: true);
        return;
      }

      branchData.assignAll(user.toJson());

      final stored = await _localStorage.storeData(
        key: "userData",
        data: user.toJson(),
      );

      if (!stored) {
        _showSnackbar("Storage Error", "Failed to store user data",
            isError: true);
        return;
      }

      _showSnackbar("Welcome", "Welcome ${user.name}");
      Get.offAllNamed('/home');
    } catch (e) {
      _showSnackbar("Error", "Something went wrong. Please try again.",
          isError: true);
      if (kDebugMode) {
        print("Auth error: $e");
      }
    }
  }

  Future<Map<String, dynamic>> getBranchData() async {
    final storedData = await _localStorage.getData(key: 'userData');
    branchData.assignAll(storedData);
    return storedData;
  }

  Future<bool> logout() {
    return _localStorage.removeEverything();
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
    );

  }
}
