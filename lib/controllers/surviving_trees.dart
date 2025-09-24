// garden_compliance_report.dart
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/services/location.dart';

import '../models/return_data.dart';
import '../repositories/report_repository.dart';

class SurvivingTreesController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  UserController userController = Get.find<UserController>();
  Locator location = Locator();

  final RxString garden = "".obs;
  final RxString species = "".obs;
  final RxString season = "".obs;
  final RxInt survivingTrees = 0.obs;

  Future<void> submitReport() async {
    String userLocation = await location.getPointCoordinates();
    String update = "${garden.value} -- ${species.value}";

    Map<String, dynamic> data = {
      'Update': update,
      'Surviving Trees': survivingTrees.value,
      'Date Collected': DateTime.now().toIso8601String(),
      'Submitted By': userController.branchData['ID'].trim(),
      'User location': userLocation,
      'season': season.value,
    };
    debugPrint("Data: $data");
    Data<AirtableRecord> isSubmitted = await reportRepo.submitReport(
      data: data,
      reportKey: 'SurvivingTrees',
      photoFields: [],
    );

    if (!isSubmitted.status) {
      //show snackBars
      if (isSubmitted.message == "No internet, report saved locally") {
        Get.snackbar(
          "No internet",
          "No internet, report saved locally",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        userController.unSyncedReports.value += 1;
        _clearForm();
        Get.back();
        return;
      } else if (isSubmitted.message ==
          "Photo upload failed, report saved locally") {
        Get.snackbar(
          "Photo upload failed",
          "Photo upload failed, report saved locally",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        _clearForm();
        Get.back();
        return;
      } else if (isSubmitted.message ==
          "No internet and failed to save locally") {
        Get.snackbar(
          "No internet",
          "No internet and failed to save locally",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        _clearForm();
        Get.back();
        return;
      }
      Get.snackbar(
        "Error",
        isSubmitted.message!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      "Success",
      "Report submitted successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    _clearForm();
    // Navigate to previous screen
    Get.back();
  }

  void _clearForm() {
    garden.value = "";
    species.value = "";
    season.value = "";
    survivingTrees.value = 0;
  }
}
