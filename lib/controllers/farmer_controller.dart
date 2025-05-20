import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/garden.dart';

import '../models/report.dart';
import '../models/return_data.dart';
import '../models/user_model.dart';
import '../repositories/garden_repository.dart';
import '../repositories/report_repository.dart';
import '../services/internet_check.dart';
import '../utilities/toast_utils.dart';

class FarmerController extends GetxController {
  final GardenRepository _gardenRepo = GardenRepository();
  final InternetCheck _internetCheck = InternetCheck();

  final ReportRepository _reportRepo = ReportRepository();

  final parishData = <String, dynamic>{}.obs;
  final RxList<Garden> gardens = <Garden>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unSyncedReports = 0.obs;
  var userAvatar = ''.obs;
  var activeFarmer = ''.obs;
  var activeFarmerName = ''.obs;

  var isGardensLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args.containsKey('farmer')) {
      if (kDebugMode) {
        print("Farmer: ${args['farmer']}");
      }

      isGardensLoading.value = true;
      activeFarmerName.value = args['name'];
      updateFarmerGardens(farmerId: args['farmer']).then((_) {
        isGardensLoading.value = false;
      });
    } else {
      getFarmerData();
    }
  }

  // Method to check if a user is logged in
  Future<void> getFarmerData() async {
    if (kDebugMode) {
      print("....Getting farmer data....");
    }
    Data<List<Garden>> localGardens =
        await _gardenRepo.fetchLocalGardens(farmer: activeFarmer.value);
    if (localGardens.status) {
      if (kDebugMode) {
        print("Local Farmer Gardens: ${localGardens.data}");
      }
      gardens.assignAll(localGardens.data as Iterable<Garden>);
    }

    //fetch unSynced reports
    Data<List<DailyReport>> unSyncedData =
        await _reportRepo.fetchLocalReports();
    if (unSyncedData.status) {
      unSyncedReports.value = unSyncedData.data!.length;
    } else {
      unSyncedReports.value = 0;
    }
  }

  Future<void> updateFarmerGardens({required String farmerId}) async {
    bool airtableConn = await _internetCheck.isAirtableConnected();
    if (airtableConn) {
      var gardens = await _gardenRepo.fetchGardens(farmerId);
      if (gardens.status) {
        await _gardenRepo.saveGardens(gardens.data ?? [], farmerId);
        showToastGlobal(
          "Farmer garden List updated",
          backgroundColor: Colors.green,
        );
      } else {
        showToastGlobal(
          "An error occurred",
          backgroundColor: Colors.red,
        );
      }
    }
    Data<List<Garden>> localGardens =
        await _gardenRepo.fetchLocalGardens(farmer: farmerId);
    if (localGardens.status) {
      List<Garden> gardens = localGardens.data ?? [];
      if (gardens.isNotEmpty) {
        activeFarmer.value = farmerId;
        getFarmerData();
      } else {
        _showSnackBar(
          "No data",
          "No Farmer data. Get internet and tap again to get data!",
          isError: true,
        );
      }
    } else {
      showToastGlobal(
        "Farmer Data is up to date",
        backgroundColor: Colors.green,
      );
    }
  }

  void _showSnackBar(String title, String message, {bool isError = false}) {
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
