import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/app/data/providers/userdata_provider.dart';
import 'dart:io';

import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/bc/controllers/bc_controller.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:kijani_pmc_app/global/services/aws_service.dart';
import 'package:kijani_pmc_app/global/services/image_services.dart';

class BCReportController extends GetxController {
  final AuthController authData = Get.put(AuthController());
  final BcController bcData = Get.put(BcController());
  final UserdataProvider userData = Get.put(UserdataProvider());

  final pcReports = ''.obs;
  final explanationForLessReports = ''.obs;
  final description = ''.obs;
  final otherActivity = ''.obs;
  final otherChallenge = ''.obs;
  final isLoading = false.obs; // Added to track loading state

  final selectedActivities = <String>[].obs;
  final selectedChallenges = <String>[].obs;
  final images = <XFile>[].obs;

  final ImagePicker _picker = ImagePicker();
  final ImageServices _imageServices = ImageServices();

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

  void submitForm() async {
    if (!validateForm()) return; // Validate form before submission

    isLoading.value = true; // Show loading indicator

    try {
      // Upload images to AWS S3 and collect the URLs
      List<String> imageUrls = [];

      for (var image in images) {
        String res = await AWSService().uploadToS3(image.path, image.name);
        if (res == 'IMAGE UPLOADED') {
          imageUrls.add(
              "https://2024-app-uploads.s3.amazonaws.com/${image.path.split('/').last}");
        } else {
          throw Exception("Failed to upload image: ${image.name}");
        }
      }

      // Prepare report data with conditional addition of "Other" options
      final reportData = {
        "Name of BC": bcData.bcId.value.trim(),
        "PC reports": pcReports.value.trim(),
        if (pcReports.value.trim().isNotEmpty &&
            int.parse(pcReports.value.trim()) < 6)
          "Why less reports?": explanationForLessReports.value,
        "Activities": selectedActivities,
        if (selectedActivities.contains("Other(s) Specify") &&
            otherActivity.value.isNotEmpty)
          "Other Activities": otherActivity.value,
        "Challenges": selectedChallenges,
        if (selectedChallenges.contains("Others (specify)") &&
            otherChallenge.value.isNotEmpty)
          "Other Challenge": otherChallenge.value,
        "Description": description.value,
        "photo URLs": imageUrls.join(', '),
      };

      reportData.forEach((key, value) {
        if (kDebugMode) {
          print("$key: $value");
        }
      });
      // Submit data to Airtable
      var res = await currentNurseryBase.createRecord(
          'BCs Daily Reports', reportData);
      if (kDebugMode) {
        print(res.fields);
      }

      //Clear data after submission
      clearForm();

      //Optionally, fetch updated reports or navigate to another screen
      await userData.loadReportsFromStorage();
      Get.offAndToNamed(Routes.dashboard);

      // Show success message
      Get.snackbar(
        'Success',
        'Report was successfully submitted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on AirtableException catch (e) {
      // Handle Airtable-specific exceptions
      print("Airtable Error: ${e.message}");
      print("Airtable Details: ${e.details}");
      Get.snackbar(
        'Submission Failed',
        'Error: ${e.message}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      // Handle other exceptions
      print("Error: ${e.toString()}");
      Get.snackbar(
        'Submission Failed',
        'Error: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Hide loading indicator
    }
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
