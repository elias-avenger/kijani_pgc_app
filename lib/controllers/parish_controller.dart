import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/models/group.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/models/user_model.dart';
import 'package:kijani_pgc_app/repositories/group_repository.dart';
import 'package:kijani_pgc_app/repositories/parish_repository.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';
import 'package:kijani_pgc_app/utilities/toast_utils.dart';

import '../services/internet_check.dart';

class ParishController extends GetxController {
  final ParishRepository _parishRepo = ParishRepository();
  final GroupRepository _groupRepo = GroupRepository();
  final InternetCheck _internetCheck = InternetCheck();
  final UserController _userController = Get.find<UserController>();

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
      updateParishData(parishId: args['parish']).then((_) {
        isGroupsLoading.value = false;
      });
    }
  }

  Future<void> updateParishData({required String parishId}) async {
    bool airtableConn = await _internetCheck.isAirtableConnected();
    if (airtableConn) {
      Data<List> groups = await _groupRepo.fetchGroups(parishId);
      if (groups.status) {
        await _groupRepo.saveGroups(groups.data ?? [], parishId);
        showToastGlobal(
          "Parish group List updated",
          backgroundColor: Colors.green,
        );
        int numGroups = groups.data!.length;
        _parishRepo.updateParishGroups(parishId, numGroups);
        await _userController.updateParishesList();
      } else {
        showToastGlobal(
          "An error occurred",
          backgroundColor: Colors.red,
        );
      }
    }
    Data<List<Group>> localGroups =
        await _groupRepo.fetchLocalGroups(parish: parishId);
    if (localGroups.status) {
      List<Group> parishGroups = localGroups.data ?? [];
      if (parishGroups.isNotEmpty) {
        activeParish.value = parishId;
        groups.assignAll(localGroups.data as Iterable<Group>);
        getParishUnsyncedData();
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
        "No Groups data. Get internet and tap again to get data!",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> getParishUnsyncedData() async {
    if (kDebugMode) {
      print("....Getting parish data....");
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
