// controllers/unsynced_data_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/models/data.dart';

class SyncingController extends GetxController {
  // Reactive list of unsynced data items
  var unsyncedDataList = <UnsyncedData>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the list with sample data
    unsyncedDataList.addAll([
      UnsyncedData(
        title: "Farmer Data Update",
        lastRecorded: "20/05/2025",
        count: 4,
        icon: Icons.group,
      ),
      UnsyncedData(
        title: "Planting Update",
        lastRecorded: "20/05/2025",
        count: 2,
        icon: Icons.local_florist,
      ),
      UnsyncedData(
        title: "Garden Polygon Update",
        lastRecorded: "20/05/2025",
        count: 1,
        icon: Icons.map,
      ),
    ]);
  }

  // Handle Sync All action
  Future<void> syncAll() async {
    // Simulate syncing process
    Get.snackbar("Syncing", "All data is being synced...");
    unsyncedDataList.clear(); // Clear the list after syncing
  }
}
