import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/models/return_data.dart';
import 'package:kijani_pmc_app/repositories/report_repository.dart';

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
    });

    Data<AirtableRecord> isSubmitted = await reportRepo.submitDailyReport(data);

    if (!isSubmitted.status) {
      Get.snackbar("Error", "Failed to submit form");
      return;
    }
    Get.snackbar(
      "Success",
      "Report submitted successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // Clear the form after submission
    selectedParish.value = '';
    selectedActivities.clear();
    details.value = '';
    nextActivities.clear();
    attachments.clear();
    detailsController.clear();
    nextDaysActivitiesController.clear();
    // Navigate to another screen or perform other actions
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    // ✅ Properly dispose controllers
    detailsController.dispose();
    nextDaysActivitiesController.dispose();
    super.onClose();
  }
}
