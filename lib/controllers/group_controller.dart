import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/farmer.dart';
import '../models/report.dart';
import '../models/return_data.dart';
import '../models/user_model.dart';
import '../repositories/farmer_repository.dart';
import '../repositories/report_repository.dart';
import '../services/internet_check.dart';
import '../utilities/toast_utils.dart';

class GroupController extends GetxController {
  final FarmerRepository _farmerRepo = FarmerRepository();
  final InternetCheck _internetCheck = InternetCheck();

  final ReportRepository _reportRepo = ReportRepository();

  final parishData = <String, dynamic>{}.obs;
  final RxList<Farmer> farmers = <Farmer>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unSyncedReports = 0.obs;
  var userAvatar = ''.obs;
  var activeGroup = ''.obs;
  var activeGroupName = ''.obs;

  var isFarmersLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args.containsKey('group')) {
      if (kDebugMode) {
        print("Group: ${args['group']}");
      }

      isFarmersLoading.value = true;
      activeGroupName.value = args['name'];
      updateGroupFarmers(groupId: args['group']).then((_) {
        isFarmersLoading.value = false;
      });
    } else {
      getGroupData();
    }
  }

  // Method to check if a user is logged in
  Future<void> getGroupData() async {
    if (kDebugMode) {
      print("....Getting group data....");
    }
    Data<List<Farmer>> localFarmers =
        await _farmerRepo.fetchLocalFarmers(group: activeGroup.value);
    if (localFarmers.status) {
      if (kDebugMode) {
        print("Local Group Farmers: ${localFarmers.data}");
      }
      farmers.assignAll(localFarmers.data as Iterable<Farmer>);
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

  Future<void> updateGroupFarmers({required String groupId}) async {
    bool airtableConn = await _internetCheck.isAirtableConnected();
    if (airtableConn) {
      var farmers = await _farmerRepo.fetchFarmers(groupId);
      if (farmers.status) {
        await _farmerRepo.saveFarmers(farmers.data ?? [], groupId);
        showToastGlobal(
          "Group farmer List updated",
          backgroundColor: Colors.green,
        );
      } else {
        showToastGlobal(
          "An error occurred",
          backgroundColor: Colors.red,
        );
      }
    }
    Data<List<Farmer>> localFarmers =
        await _farmerRepo.fetchLocalFarmers(group: groupId);
    if (localFarmers.status) {
      List<Farmer> farmers = localFarmers.data ?? [];
      if (farmers.isNotEmpty) {
        activeGroup.value = groupId;
        getGroupData();
      } else {
        _showSnackBar(
          "No data",
          "No Group data. Get internet and tap again to get data!",
          isError: true,
        );
      }
    } else {
      showToastGlobal(
        "Group Data is up to date",
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
