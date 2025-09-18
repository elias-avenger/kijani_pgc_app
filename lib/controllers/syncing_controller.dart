// controllers/unsynced_data_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';

class SyncingController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  // Reactive list of unsynced data items
  var unSyncedDailyReports = <Map<String, dynamic>>[].obs;
  var unSyncedComplianceReports = <Map<String, dynamic>>[].obs;
  var unSyncedDataList = <Map<String, dynamic>>[].obs;

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
      unSyncedDataList.clear();
      unSyncedDailyReports.clear();
      unSyncedComplianceReports.clear(); // Clear the list after syncing
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
    String errorMsg = '';
    List<Map<String, dynamic>> allUnsyncedReports = [];
    //fetch unSynced Daily reports
    Data<List<Map<String, dynamic>>> localDailyReports =
        await reportRepo.fetchLocalReports(reportKey: 'PGCReport');
    localDailyReports.status
        ? unSyncedDailyReports.assignAll(localDailyReports.data!)
        : errorMsg = '${errorMsg}Unsynced Daily reports fetch failed';
    //fetch unSynced Compliance reports
    Data<List<Map<String, dynamic>>> localComplianceReports =
        await reportRepo.fetchLocalReports(reportKey: 'GardenCompliance');
    localComplianceReports.status
        ? unSyncedComplianceReports.assignAll(localComplianceReports.data!)
        : errorMsg = '${errorMsg}Unsynced Compliance reports fetch failed';
    //combine both lists
    allUnsyncedReports.addAll(unSyncedDailyReports);
    allUnsyncedReports.addAll(unSyncedComplianceReports);
    unSyncedDataList.assignAll(allUnsyncedReports);
    if (errorMsg.isNotEmpty) {
      Get.snackbar("Error", errorMsg);
    }
  }

  Future<void> syncAllData() async {
    if (unSyncedDataList.isEmpty) {
      Get.snackbar("No Data", "No unsynced data to sync.");
      return;
    }

    // Simulate syncing process
    Get.snackbar("Syncing", "All data is being synced...");
    unSyncedDataList.clear(); // Clear the list after syncing
  }
}
