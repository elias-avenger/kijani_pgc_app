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

class GardenController extends GetxController {
  final GardenRepository _gardenRepo = GardenRepository();
  final InternetCheck _internetCheck = InternetCheck();

  final ReportRepository _reportRepo = ReportRepository();

  final parishData = <String, dynamic>{}.obs;
  final RxList<Garden> gardens = <Garden>[].obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  var unSyncedReports = 0.obs;
  var userAvatar = ''.obs;
  var activeGarden = ''.obs;
  // var activeGardenName = ''.obs;

  var isGardenDataLoading = false.obs;

  Garden garden = Garden(
    recordID: "",
    id: "",
    centerPoint: "",
    polygon: "",
    treesPlanted: 0,
    treesSurviving: 0,
    gardenPhotos: [],
    speciesData: [],
  );

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null && args.containsKey('garden')) {
      garden = args['garden'];
      activeGarden.value = garden.id;
      if (kDebugMode) {
        print("Garden: ${activeGarden.value}");
      }
      isGardenDataLoading.value = true;

      updateGardenData(gardenId: activeGarden.value).then((_) {
        isGardenDataLoading.value = false;
      });
    } else {
      getGardenUnSyncedData();
    }
  }

  Future<void> updateGardenData({required String gardenId}) async {
    bool airtableConn = await _internetCheck.isAirtableConnected();
    if (airtableConn) {
      var gardenData = await _gardenRepo.fetchGardenData(gardenId);
      if (gardenData.status) {
        await _gardenRepo.saveGardenData(gardenData.data ?? [], gardenId);
        showToastGlobal(
          "Garden data updated",
          backgroundColor: Colors.green,
        );
      } else {
        showToastGlobal(
          "An error occurred",
          backgroundColor: Colors.red,
        );
      }
    }
    Data<List<Garden>> localGardenData =
        await _gardenRepo.fetchLocalGardenData(garden: gardenId);
    if (localGardenData.status) {
      List<Garden> gardenData = localGardenData.data ?? [];
      if (gardenData.isNotEmpty) {
        activeGarden.value = gardenId;
        getGardenUnSyncedData();
      } else {
        _showSnackBar(
          "No data",
          "Failed to retrieve local garden data!",
          isError: true,
        );
      }
    } else {
      showToastGlobal(
        "No Internet. Get internet and tap again to get data!",
        backgroundColor: Colors.red,
      );
    }
  }

  // Method to check if a user is logged in
  Future<void> getGardenUnSyncedData() async {
    if (kDebugMode) {
      print("....Getting farmer data....");
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
