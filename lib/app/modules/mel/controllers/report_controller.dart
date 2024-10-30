import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MELReportController extends GetxController {
  final highlights = ''.obs;
  final planForTomorrow = ''.obs;
  final otherActivity = ''.obs;
  final otherObservation = ''.obs;
  final otherChallenge = ''.obs;

  final selectedActivities = <String>[].obs;
  final selectedObservations = <String>[].obs;
  final selectedChallenges = <String>[].obs;
  final images = <XFile>[].obs;
  final isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  final List<String> predefinedActivities = [
    "PC training",
    "Catch-up",
    "Planting site Registration",
    "Baseline survey administration",
    "Survival Check",
    "Monitoring Visit",
    "Farmer onboarding",
    "Group mobilization",
    "Other",
    "Data verification at Office",
  ];

  final List<String> predefinedOnSiteObservations = [
    "Signs of infection observed",
    "Incorrect tree spacing",
    "Mixed planting of various species",
    "Incorrect spacing",
    "Kijani trees mixed with trees from another organization",
    "Low tree survival rates",
    "Animal damage to trees",
    "Lack of weeding",
    "Flooding in the garden",
    "Trees planted with polypots",
    "Polypots scattered throughout the garden",
    "Trees wilting due to too much sunshine",
    "Other",
  ];

  final List<String> predefinedChallenges = [
    "No challenge experienced",
    "Motorcycle breakdown",
    "Difficulty Locating gardens",
    "Interrupted by Rain",
    "Interrupted by village market",
    "Interrupted by Burial Ceremonies",
    "Difficulty Finding Farmers at Home",
    "Long Distance Between Farms",
    "Kijani App Malfunction",
    "Incomplete Records",
    "Overgrown/Bushy Farms",
    "Illness",
    "Delayed Fuel Provision",
    "Safety/Insecurity Issues",
    "Poor Network Reception",
    "Farmers Without SIM Cards for Registration",
    "Phone Malfunction",
    "Other",
  ];

  Future<void> pickImages() async {
    isLoading.value = true; // Show loading
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        images.assignAll(pickedFiles);
      }
    } finally {
      isLoading.value = false; // Hide loading after processing
    }
  }

  void submitForm() {
    // Form Validation
    if (_isFormValid()) {
      if (selectedActivities.contains("Other")) {
        selectedActivities.add("Other: ${otherActivity.value}");
      }
      if (selectedObservations.contains("Other")) {
        selectedObservations.add("Other: ${otherObservation.value}");
      }
      if (selectedChallenges.contains("Other")) {
        selectedChallenges.add("Other: ${otherChallenge.value}");
      }

      // Prepare report data
      final reportData = {
        "Highlights": highlights.value,
        "Activities": selectedActivities,
        "On-Site Observations": selectedObservations,
        "Challenges": selectedChallenges,
        "Plan for Tomorrow": planForTomorrow.value,
        "Photos": images.map((image) => image.path).toList(),
      };

      // Handle form submission (e.g., send data to backend)
      print("Report Data: $reportData");

      // Clear data after submission
      clearForm();
    } else {
      // Show error message if form is not valid
      Get.snackbar(
        'Error',
        'Please fill in all required fields correctly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _isFormValid() {
    if (selectedActivities.isEmpty ||
        highlights.isEmpty ||
        selectedObservations.isEmpty ||
        selectedChallenges.isEmpty ||
        planForTomorrow.isEmpty ||
        images.isEmpty) {
      return false;
    }

    if (selectedActivities.contains("Other") && otherActivity.isEmpty) {
      return false;
    }
    if (selectedObservations.contains("Other") && otherObservation.isEmpty) {
      return false;
    }
    if (selectedChallenges.contains("Other") && otherChallenge.isEmpty) {
      return false;
    }

    return true;
  }

  void clearForm() {
    highlights.value = '';
    planForTomorrow.value = '';
    otherActivity.value = '';
    otherObservation.value = '';
    otherChallenge.value = '';
    selectedActivities.clear();
    selectedObservations.clear();
    selectedChallenges.clear();
    images.clear();
  }
}
