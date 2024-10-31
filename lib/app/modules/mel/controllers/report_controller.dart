import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/mel/controllers/mel_controller.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:kijani_pmc_app/global/services/aws_service.dart';

class MELReportController extends GetxController {
  final AuthController authData = Get.put(AuthController());
  final MelController melUpdate = Get.put(MelController());

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
  final selectedParishes = <String>[].obs;

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

  void submitForm() async {
    // Form Validation
    if (_isFormValid()) {
      // Prepare report data with conditional addition of "Other" options

      try {
        List<String> imageUrls = [];
        //https://2024-app-uploads.s3.amazonaws.com/scaled_1000042417.webp, https://2024-app-uploads.s3.amazonaws.com/scaled_1000042418.webp, https://2024-app-uploads.s3.amazonaws.com/scaled_1000042417.webp

        for (var image in images) {
          //call aws to submit
          String res = await AWSService().uploadToS3(image.path, image.name);
          if (res == 'IMAGE UPLOADED') {
            imageUrls.add(
                "https://2024-app-uploads.s3.amazonaws.com/${image.path.split('/').last}");
          }
        }
        final reportData = {
          "MEL":
              "${authData.userData['MEL Officer'].trim()} -- ${authData.userData['Branch'].trim()}",
          "Location:": selectedParishes,
          "Activities implemented": selectedActivities,
          if (selectedActivities.contains("Other") && otherActivity.isNotEmpty)
            "Others activities": otherActivity.value,
          "Highlights:": highlights.value,
          "On-Site Observations:": selectedObservations,
          if (selectedObservations.contains("Other") &&
              otherObservation.isNotEmpty)
            "Other Observations": otherObservation.value,
          "Challenges encountered if any:": selectedChallenges,
          if (selectedChallenges.contains("Other") && otherChallenge.isNotEmpty)
            "Other Challenges": otherChallenge.value,
          "Plan For tomorrow’s activity:": planForTomorrow.value,
          "photo URLs": imageUrls.join(', '),
        };
        print("Report Data: $reportData");
        reportData.forEach((key, value) {
          print('$key: $value');
        });
        var res =
            await currentGardenBase.createRecord('MEL Reports', reportData);
        print(res.fields);
      } on AirtableException catch (e) {
        print("AIRATBALE ERROR: ${e.message}");
        print("AIRATBALE ERROR: ${e.details}");
      } catch (e) {
        print(e.toString());
      }

      // Clear data after submission
      clearForm();
      await melUpdate.fetchReports();
      Get.offAndToNamed(Routes.dashboard);
      Get.snackbar(
        'Success',
        'Report was successfully Submitted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
