// controllers/unsynced_data_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';

class SyncingController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  // Reactive list of unsynced data items
  var unsyncedDataList = <DailyReport>[].obs;

  //on initialisation
  @override
  void onInit() {
    super.onInit();
    // Fetch unsynced reports data when the controller is initialized
    getUnsyncedReports();
  }

  //sync reports data
  Future<void> syncReportsData() async {
    final Data response = await reportRepo.syncReports();
    if (response.status) {
      Get.snackbar(
        "Syncing",
        "Reports data synced successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      unsyncedDataList.clear(); // Clear the list after syncing
    } else {
      Get.snackbar(
        "Error",
        response.message ?? "Failed to sync reports data.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //get unsynced reports data
  Future<void> getUnsyncedReports() async {
    final Data<List<DailyReport>> response =
        await reportRepo.fetchLocalDailyReports();
    if (response.status) {
      unsyncedDataList.assignAll(response.data ?? []);
    } else {
      Get.snackbar(
          "Error", response.message ?? "Failed to fetch unsynced reports.");
    }
  }

  Future<void> syncAllData() async {
    if (unsyncedDataList.isEmpty) {
      Get.snackbar("No Data", "No unsynced data to sync.");
      return;
    }

    // Simulate syncing process
    Get.snackbar("Syncing", "All data is being synced...");
    unsyncedDataList.clear(); // Clear the list after syncing
  }
}
