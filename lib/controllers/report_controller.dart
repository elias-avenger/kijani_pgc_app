import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/repositories/report_repository.dart';

class ReportController extends GetxController {
  ReportRepository reportRepo = ReportRepository();

  var selectedParish = ''.obs;
  var selectedActivities = <String>[].obs;
  var details = ''.obs;
  var nextActivities = <String>[].obs;
  var attachments = [].obs;

  List<String> get activityOptions => ReportRepository.activities;

  final TextEditingController detailsController = TextEditingController();
  final TextEditingController nextDaysActivitiesController =
      TextEditingController();

  void pickFiles() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      attachments.addAll(pickedFiles);
    }
  }

  @override
  void onClose() {
    // ✅ Properly dispose controllers
    detailsController.dispose();
    nextDaysActivitiesController.dispose();
    super.onClose();
  }

  Future<void> submitForm() async {
    //call the repository to submit the form
    bool isSubmitted = await reportRepo.submitDailyReport({
      'parish': selectedParish.value,
      'activities': selectedActivities,
      'details': details.value,
      'nextActivities': nextActivities,
      'attachments': attachments,
    });
    //submit the form
    if (!isSubmitted) {
      Get.snackbar("Error", "Failed to submit form");
      return;
    }
    Get.snackbar(
      "Success",
      "Form submitted successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
