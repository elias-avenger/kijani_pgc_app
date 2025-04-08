import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/models/report.dart';
import 'package:kijani_pmc_app/repositories/report_repository.dart';

class ReportController extends GetxController {
  ReportRepository reportRepo = ReportRepository();

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
      pickedFiles.forEach((file) {
        attachments.add(file.path); // Store the file path
      });
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
    print("Authenticating user...");

    // Convert List<XFile> to List<String> (just the paths)

    DailyReport data = DailyReport.fromJson({
      'pgc': "Katoemmanuel",
      'parish': selectedParish.value,
      'activities': selectedActivities,
      'details': details.value,
      'nextActivities': nextActivities,
      'images': attachments, // Pass List<String>
    });

    print("Data to be submitted: ${data.toJson()}");
    //bool isSubmitted = await reportRepo.submitDailyReport(data);

    // if (!isSubmitted) {
    //   Get.snackbar("Error", "Failed to submit form");
    //   return;
    // }
    Get.snackbar(
      "Success",
      "Form submitted successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
