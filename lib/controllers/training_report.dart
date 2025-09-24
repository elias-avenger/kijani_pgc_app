// garden_compliance_report.dart
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/services/location.dart';

import '../models/farmer.dart';
import '../models/photo.dart';
import '../models/return_data.dart';
import '../repositories/report_repository.dart';

class TrainingReportController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  UserController userController = Get.find<UserController>();
  Locator location = Locator();
  RxBool isSubmitting = false.obs;

  final RxList<Farmer> farmers = <Farmer>[].obs;
  final RxList<String> attendanceListImage = <String>[].obs;
  final RxList<String> trainingImages = <String>[].obs;

  final TextEditingController detailsController = TextEditingController();

  Future<void> submitReport(groupId) async {
    isSubmitting.value = true;
    String userLocation = await location.getPointCoordinates();
    List<String> farmerIds = farmers.map((farmer) => farmer.id).toList();
    List<Photo> attendancePhoto =
        (attendanceListImage.toList() as List<dynamic>?)
                ?.map((e) => Photo.fromPath(e.toString()))
                .toList() ??
            [];
    List<Photo> trainingPhotos = (trainingImages.toList() as List<dynamic>?)
            ?.map((e) => Photo.fromPath(e.toString()))
            .toList() ??
        [];
    String trainingComments = detailsController.text;
    Map<String, dynamic> data = {
      'Group': groupId,
      'Farmers present': farmerIds,
      'Attendance list image': attendancePhoto,
      'Training session images': trainingPhotos,
      'Training comments': trainingComments,
      'Date': DateTime.now().toIso8601String(),
      'Submitted by': userController.branchData['ID'].trim(),
      'User location': userLocation,
    };
    debugPrint("Data: $data");
    Data<AirtableRecord> isSubmitted = await reportRepo.submitReport(
      data: data,
      reportKey: 'FarmerTraining',
      photoFields: ['Attendance list image', 'Training session images'],
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
        Get.back(closeOverlays: true);
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
        Get.back(closeOverlays: true);
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
        Get.back(closeOverlays: true);
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
    isSubmitting.value = false;
    _clearForm();
    // Navigate to previous screen
    Get.back(closeOverlays: true);
  }

  void _clearForm() {
    farmers.value = [];
    attendanceListImage.value = [];
    trainingImages.value = [];
    detailsController.clear();
  }
}
