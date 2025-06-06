import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/controllers/reports_controller.dart';
import 'package:kijani_pmc_app/models/parish.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/models/return_data.dart';
import 'package:kijani_pmc_app/models/user_model.dart';
import 'package:kijani_pmc_app/repositories/parish_repository.dart';
import 'package:kijani_pmc_app/repositories/report_repository.dart';
import 'package:kijani_pmc_app/repositories/user_repository.dart';
import 'package:kijani_pmc_app/routes/app_pages.dart';
import 'package:kijani_pmc_app/services/getx_storage.dart';

class UserController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final StorageService _storageService = StorageService();
  final ParishRepository _parishRepo = ParishRepository();
  final ReportRepository _reportRepo = ReportRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final branchData = <String, dynamic>{}.obs;
  final RxList<Parish> parishes = <Parish>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unsyncedReports = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkIfUserIsLoggedIn();
  }

  // Method to check if a user is logged in
  Future<void> checkIfUserIsLoggedIn() async {
    Data<User> response = await _userRepo.fetchLocalUser();
    User? localUser = response.data;
    if (localUser != null) {
      branchData.value = localUser.toJson();
      //fetch parishes
      Data<List<Parish>> localParishes = await _parishRepo.fetchLocalParishes();
      if (localParishes.status) {
        parishes.assignAll(localParishes.data as Iterable<Parish>);
      }
      //fetch unsynced reports
      Data<List<DailyReport>> unsyncedData =
          await _reportRepo.fetchLocalReports();
      if (unsyncedData.status) {
        unsyncedReports.value = unsyncedData.data!.length;
      } else {
        unsyncedReports.value = 0;
      }
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> login() async {
    try {
      Data<User> response = await _userRepo.checkUser(
        email: emailController.text,
        code: codeController.text,
      );
      if (!response.status) {
        _showSnackbar("Wrong Credentials", "Check Email or Code",
            isError: true);
        return;
      }

      User? user = response.data as User;

      //fetch parishes
      Data<List<Parish>> parishes =
          await _parishRepo.fetchParishes(user.parishes.split(','));

      if (parishes.status) {
        //assign parishes to the observable list
        this.parishes.assignAll(parishes.data as Iterable<Parish>);
        //store parishes locally
        Data stored = await _parishRepo.saveParishes(parishes.data!);
        if (!stored.status) {
          _showSnackbar("Storage Error", "Failed to store parishes data",
              isError: true);
          return;
        }
      }

      //save parishes locally

      branchData.assignAll(user.toJson());
      Data saveResponse = await _userRepo.saveUser(user);
      if (!saveResponse.status) {
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

  Future<bool> logout() {
    return _storageService.clearAll();
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

  //dispose controllers
  @override
  void onClose() {
    emailController.dispose();
    codeController.dispose();
    super.onClose();
  }
}
