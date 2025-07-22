import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/group.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/models/user_model.dart';
import 'package:kijani_pgc_app/repositories/group_repository.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';
import 'package:kijani_pgc_app/utilities/toast_utils.dart';

import '../services/internet_check.dart';

class ParishController extends GetxController {
  final GroupRepository _groupRepo = GroupRepository();
  final InternetCheck _internetCheck = InternetCheck();

  final ReportRepository _reportRepo = ReportRepository();

  final parishData = <String, dynamic>{}.obs;
  final RxList<Group> groups = <Group>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unSyncedReports = 0.obs;
  var userAvatar = ''.obs;
  var activeParish = ''.obs;
  var activeParishName = ''.obs;

  var isGroupsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args.containsKey('parish')) {
      if (kDebugMode) {
        print("Parish: ${args['parish']}");
      }

      isGroupsLoading.value = true;
      activeParishName.value = args['name'];
      updateParishGroups(parishId: args['parish']).then((_) {
        isGroupsLoading.value = false;
      });
    } else {
      getParishData();
    }
  }

  // Method to check if a user is logged in
  Future<void> getParishData() async {
    if (kDebugMode) {
      print("....Getting parish data....");
    }
    Data<List<Group>> localGroups =
        await _groupRepo.fetchLocalGroups(parish: activeParish.value);
    if (localGroups.status) {
      if (kDebugMode) {
        print("Local Parish Groups: ${localGroups.data}");
      }
      groups.assignAll(localGroups.data as Iterable<Group>);
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

  Future<void> updateParishGroups({required String parishId}) async {
    bool airtableConn = await _internetCheck.isAirtableConnected();
    if (airtableConn) {
      var groups = await _groupRepo.fetchGroups(parishId);
      if (groups.status) {
        await _groupRepo.saveGroups(groups.data ?? [], parishId);
        // _showSnackBar(
        //   'Parish groups updated',
        //   'Parish groups updated successfully',
        // );

        showToastGlobal(
          "Parish group List updated",
          backgroundColor: Colors.green,
        );
      } else {
        // _showSnackBar(
        //   'Update failed',
        //   groups.message ?? "Just could not",
        //   isError: true,
        // );
        showToastGlobal(
          "An error occurred",
          backgroundColor: Colors.red,
        );
      }
    }
    Data<List<Group>> localGroups =
        await _groupRepo.fetchLocalGroups(parish: parishId);
    if (localGroups.status) {
      List<Group> groups = localGroups.data ?? [];
      if (groups.isNotEmpty) {
        activeParish.value = parishId;
        getParishData();
        // if (Get.currentRoute != Routes.PARISH) {
        //   Get.toNamed(Routes.PARISH);
        // }
      } else {
        _showSnackBar(
          "No data",
          "No parish data. Get internet and tap again to get data!",
          isError: true,
        );
      }
    } else {
      // _showSnackBar(
      //   "No data",
      //   "No parish data. Get internet and tap again to get data!",
      //   isError: true,
      // );
      showToastGlobal(
        "Parish Data is up to date",
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
