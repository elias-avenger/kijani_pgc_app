import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/global/services/image_services.dart';

class BCReportController extends GetxController {
  final pcReports = ''.obs;
  final description = ''.obs;
  final otherActivity = ''.obs;
  final otherChallenge = ''.obs;
  final isLoading = false.obs; // Added to track loading state

  final selectedActivities = <String>[].obs;
  final selectedChallenges = <String>[].obs;
  final images = <XFile>[].obs;

  final ImageServices _imageServices =
      ImageServices(); // Use the new ImageServices

  final List<String> predefinedActivities = [
    "Transporting seedlings from Central nurseries",
    "Data validation",
    "Other(s) Specify",
    "Requesting for operational inputs",
    "Attending stakeholder engagement meetings",
    "Record keeping",
    "Stocktaking",
    "Organizing branch catch-ups/meetings eg Technical refresher trainings",
    "Participating in area catch-ups/meetings",
    "Managing issues a PC is facing",
    "Managing field issues",
    "Company representation",
    "Supporting with service providers’ identification",
    "Supporting with intern candidates' identification",
    "Participating in disciplinary proceedings",
    "Looking for houses for field teams and stores",
    "Delivering inputs for a Parish",
    "Taking PC to Medical facility",
    "Transporting of used polypots to stores",
  ];

  final List<String> predefinedChallenges = [
    "Poor performance by PCs",
    "Issues with supervisor",
    "Motorbike breakdown",
    "Delay in Facilitation money",
    "Missing minutes and data",
    "Inadequate working materials",
    "Unpaid medical Bills",
    "None",
    "Others (specify)",
    "Unpaid garage bills",
    "Faulty Phone",
    "Impassable roads",
    "Ill health",
    "No power for charging phones",
  ];

  Future<void> pickImages() async {
    isLoading.value = true; // Show loading
    try {
      List<String> imagePaths = await _imageServices.pickMultipleImages();
      if (imagePaths.isNotEmpty) {
        images.assignAll(imagePaths.map((path) => XFile(path)));
      }
    } finally {
      isLoading.value = false; // Hide loading
    }
  }

  bool validateForm() {
    if (pcReports.isEmpty) {
      Get.snackbar(
          "Validation Error", "Please enter the number of PC reports received.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedActivities.isEmpty) {
      Get.snackbar("Validation Error", "Please select at least one activity.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedActivities.contains("Other(s) Specify") &&
        otherActivity.value.isEmpty) {
      Get.snackbar("Validation Error", "Please specify the other activity.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedChallenges.isEmpty) {
      Get.snackbar("Validation Error", "Please select at least one challenge.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedChallenges.contains("Others (specify)") &&
        otherChallenge.value.isEmpty) {
      Get.snackbar("Validation Error", "Please specify the other challenge.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar("Validation Error", "Please provide a description.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  void submitForm() {
    if (!validateForm()) return; // Validate form before submission

    // Append other activity/challenge details to the list if they are provided
    if (selectedActivities.contains("Other(s) Specify") &&
        otherActivity.value.isNotEmpty) {
      selectedActivities.add("Other: ${otherActivity.value}");
    }
    if (selectedChallenges.contains("Others (specify)") &&
        otherChallenge.value.isNotEmpty) {
      selectedChallenges.add("Other: ${otherChallenge.value}");
    }

    final reportData = {
      "PC Reports": pcReports.value,
      "Activities": selectedActivities,
      "Challenges": selectedChallenges,
      "Description": description.value,
      "Photos": images.map((image) => image.path).toList(),
    };

    // Handle form submission (e.g., send data to backend)
    print("Report Data: $reportData");

    // Clear data after submission
    clearForm();
  }

  void clearForm() {
    pcReports.value = '';
    description.value = '';
    otherActivity.value = '';
    otherChallenge.value = '';
    selectedActivities.clear();
    selectedChallenges.clear();
    images.clear();
  }
}
