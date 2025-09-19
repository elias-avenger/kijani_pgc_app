import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/models/return_data.dart';
import 'package:kijani_pgc_app/repositories/report_repository.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';

class ReportController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  UserController userController = Get.find<UserController>();

  var selectedParish = ''.obs;
  var selectedActivities = <String>[].obs;
  var otherActivities = "".obs;
  var details = ''.obs;
  var nextActivities = <String>[].obs;
  var otherNextActivities = "".obs;
  RxList<String> attachments = <String>[].obs;

  List<String> get activityOptions => ReportRepository.activities;

  final TextEditingController detailsController = TextEditingController();
  final TextEditingController nextDaysActivitiesController =
      TextEditingController();
  final TextEditingController otherNextActivitiesController =
      TextEditingController();
  final TextEditingController otherActivitiesController =
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
    Map<String, dynamic> data = {
      'PGC': userController.branchData['ID'].trim(),
      'Parish': selectedParish.value.trim(),
      'Activities': selectedActivities,
      'Other activities': otherActivities.value,
      'Activity details': details.value,
      'Next activities': nextActivities.join(", "),
      'Other next activities': otherNextActivities.value,
      'Photo Urls': attachments, // Pass List<String>
      'Date': DateTime.now().toIso8601String(),
    };

    Data<AirtableRecord> isSubmitted = await reportRepo.submitReport(
      data: data,
      reportKey: 'PGCReports',
      photoFields: ['Photo Urls'],
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
