import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/parish.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/models/user_model.dart';
import 'package:kijani_pgc_app/repositories/parish_repository.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';
import 'package:kijani_pgc_app/repositories/user_repository.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';
import 'package:kijani_pgc_app/services/getx_storage.dart';
import 'package:kijani_pgc_app/services/internet_check.dart';

class UserController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final StorageService _storageService = StorageService();
  final ParishRepository _parishRepo = ParishRepository();
  final ReportRepository _reportRepo = ReportRepository();
  final InternetCheck _internetCheck = InternetCheck();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final branchData = <String, dynamic>{}.obs;
  final RxList<Parish> parishes = <Parish>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unsyncedReports = 0.obs;
  var userAvatar = ''.obs;
  final String _domain = '@kijaniforestry.com';

  var isHomeScreenLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_onEmailTextChanged);
    checkIfUserIsLoggedIn();
  }

  void _onEmailTextChanged() {
    String text = emailController.text;
    if (text.endsWith('@') && !text.contains(_domain)) {
      String newText = text.substring(0, text.length - 1) + _domain;
      emailController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  Future<void> checkIfUserIsLoggedIn() async {
    Data<User> response = await _userRepo.fetchLocalUser();
    User? localUser = response.data;

    if (localUser != null) {
      // Check if user credentials are still valid
      if (await _internetCheck.isAirtableConnected()) {
        print("EMAIL: ${localUser.email} CODE: ${localUser.code}");
        Data<User> isValidUser =
            await _userRepo.isUserValid(localUser.email, localUser.code);

        if (!isValidUser.status || isValidUser.data == null) {
          // Invalid user, logout
          await logout(); // Calls your logout method that clears storage & redirects
          return;
        }

        // Valid user: Update parishes
        await _parishRepo.setParishes(
          isValidUser.data!.parishes.split(','),
        );
      }

      branchData.value = localUser.toJson();

      // Fetch local parishes
      Data<List<Parish>> localParishes = await _parishRepo.fetchLocalParishes();
      if (localParishes.status && localParishes.data != null) {
        parishes.assignAll(localParishes.data!);
      }

      // Fetch unsynced reports
      Data<List<DailyReport>> unsyncedData =
          await _reportRepo.fetchLocalReports();
      unsyncedReports.value = unsyncedData.status && unsyncedData.data != null
          ? unsyncedData.data!.length
          : 0;

      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
    isHomeScreenLoading.value = false;
  }

  Future<void> login() async {
    try {
      Data<User> response = await _userRepo.checkUser(
        email: emailController.text.trim(),
        code: codeController.text.trim(),
      );

      if (!response.status || response.data == null) {
        _showSnackbar("Wrong Credentials", "Check Email or Code",
            isError: true);
        return;
      }

      User user = response.data!;

      Data<List<Parish>> parishesResult =
          await _parishRepo.setParishes(user.parishes.split(','));

      if (parishesResult.status && parishesResult.data != null) {
        parishes.assignAll(parishesResult.data!);

        Data stored = await _parishRepo.saveParishes(parishesResult.data!);
        if (!stored.status) {
          _showSnackbar("Storage Error", "Failed to store parishes data",
              isError: true);
          return;
        }
      }

      branchData.assignAll(user.toJson());
      Data saveResponse = await _userRepo.saveUser(user);
      if (!saveResponse.status) {
        _showSnackbar("Storage Error", "Failed to store user data",
            isError: true);
        return;
      }

      _showSnackbar("Welcome", "Welcome ${user.name}");
      emailController.clear();
      codeController.clear();
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      _showSnackbar("Error", "Something went wrong. Please try again.",
          isError: true);
      if (kDebugMode) {
        print("Auth error: $e");
      }
    }
  }

  Future<void> logout() async {
    await DefaultCacheManager().emptyCache();
    emailController.clear();
    codeController.clear();

    if (await _storageService.clearAll()) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      _showSnackbar("Logout failure", "Could not clear data!", isError: true);
    }
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

  @override
  void onClose() {
    emailController.removeListener(_onEmailTextChanged);
    emailController.dispose();
    codeController.dispose();
    super.onClose();
  }
}
