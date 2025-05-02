import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/models/report.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';

class ReportController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  UserController userController = Get.find<UserController>();

  var selectedParish = ''.obs;
  var selectedActivities = <String>[].obs;
  var details = ''.obs;
  var nextActivities = <String>[].obs;
  RxList<String> attachments = <String>[].obs;

  List<String> get activityOptions => ReportRepository.activities;

  final TextEditingController detailsController = TextEditingController();
  final TextEditingController nextDaysActivitiesController =
      TextEditingController();

  void pickFiles() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        attachments.add(file.path); // Store the file path
      }
    }
  }

  Future<void> submitForm() async {
    DailyReport data = DailyReport.fromJson({
      'userID': userController.branchData['ID'],
      'parish': selectedParish.value,
      'activities': selectedActivities,
      'details': details.value,
      'nextActivities': nextActivities,
      'images': attachments, // Pass List<String>
      'date': DateTime.now().toIso8601String(),
    });

    Data<AirtableRecord> isSubmitted = await reportRepo.submitDailyReport(data);

    if (!isSubmitted.status) {
      //show snackBars
      if (isSubmitted.message == "No internet, report saved locally") {
        Get.snackbar(
          "No internet",
          "No internet, report saved locally",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        userController.unsyncedReports.value += 1;
        _clearForm();
        Get.offAllNamed(Routes.HOME);
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
        Get.offAllNamed(Routes.HOME);
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
        Get.offAllNamed(Routes.HOME);
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
    // Navigate to home screen
    Get.offAllNamed(Routes.HOME);
  }

  void _clearForm() {
    selectedParish.value = '';
    selectedActivities.clear();
    details.value = '';
    nextActivities.clear();
    attachments.clear();
    detailsController.clear();
    nextDaysActivitiesController.clear();
  }

  @override
  void onClose() {
    detailsController.dispose();
    nextDaysActivitiesController.dispose();
    super.onClose();
  }
}
