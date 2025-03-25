import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/app/data/providers/userdata_provider.dart';
import 'package:kijani_pmc_app/app/modules/bc/controllers/bc_controller.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/services/airtable_service.dart';
import 'package:kijani_pmc_app/global/services/aws_service.dart';
import 'package:kijani_pmc_app/global/services/image_services.dart';

class ParishReportController extends GetxController {
  final UserdataProvider userData = Get.put(UserdataProvider());
  final BcController bcData = Get.put(BcController());

  final isLoading = false.obs;

  // Form fields
  final selectedActivities = <String>[].obs;
  final otherActivity = ''.obs;
  final selectedTasks = <String>[].obs;
  final otherTask = ''.obs;
  final selectedGroups = <String>[].obs;
  final selectedDate = ''.obs;
  final description = ''.obs;
  final selectedChallenges = <String>[].obs;
  final otherChallenge = ''.obs;
  final images = <XFile>[].obs;

  final ImageServices _imageServices = ImageServices();

  final List<String> predefinedActivities = [
    "Taking Bicycles for repair and bringing them back",
    "Seeds/materials distribution",
    "Meeting with local leaders",
    "Supporting PCs in Mobilization",
    "Supporting PCs in Nursery activities",
    "Making follow-up on assigned tasks",
    "Transportation of seedlings",
    "Delivering Bicycles spares",
    "Any other activities ( specify)",
  ];

  final List<String> predefinedTasks = [
    "Mobilize and register farmer groups",
    "Train farmers on tree nursery establishment (specify activity in comment section)",
    "Ask farmers to bring construction materials (grass and poles)",
    "Work with farmers to construct nursery structures",
    "Work with farmers to pot and line pots",
    "Establish standard seedbeds",
    "Put borders around the edges of the seedbed",
    "Pretreat and sow assorted tree seeds",
    "Sprinkle soil to cover exposed seeds",
    "Water adequately the seedbed",
    "Apply termiticide",
    "Remove the mulch over the seedbed",
    "Reduce extra soil on the sown seeds",
    "Prick all the ready seedlings",
    "Add soil after pricking to cover exposed seeds and holes created",
    "Water heavily both the seedbed and potbed before and after pricking",
    "Put side shade to protect seedlings from direct sunlight",
    "Clean seedbeds and the hubs",
    "Isolate all the diseased seedlings from the rest",
    "Apply recommended agrochemicals to fight the infections",
    "Reduce shade upon the seedlings",
    "Completely remove shade upon the seedlings",
    "Bring back shade upon the seedlings ",
    "Sort all seedlings according to height, quality, and health status",
    "Line all the empty pots left after sorting",
    "Water heavily the seedlings after sorting",
    "Root prune all seedlings feeding from the ground",
    "Water heavily the seedlings after root pruning",
    "Add shade upon the root-pruned seedlings",
    "Visit farmers’ gardens to prove readiness for planting",
    "Distribute all the ready seedlings",
    "Demonstrate standard planting practices to the farmers",
    "Follow up with farmers to ascertain standard plantings",
    "Ask farmers to collect all the used poly pots from their gardens",
    "Collect all used poly pots from farmers ",
    "Clean all the hubs with no seedlings before closing",
    "Other task (s) (specify)",
    "Advise farmers to do first weeding of the the garden"
  ];

  final List<String> predefinedChallenges = [
    "Pests",
    "Theft of seedlings",
    "Inadequate construction materials",
    "Animal disturbances",
    "Land issues with nursery site owners",
    "Floods",
    "Diseases",
    "None ",
    "Others (specify)",
    "Drying up water points",
    "Hail storm",
    "Lack of rainfall",
    "Burnt Nursery hub",
    "Interference from local leaders",
    "contaminated water source",
    "Farmers losing interest",
    "PC absconding work",
    "Unauthorized leave by PC",
    "Network issues"
  ];

  // Image picker
  Future<void> pickImages() async {
    isLoading.value = true;
    try {
      List<String> imagePaths = await _imageServices.pickMultipleImages();
      if (imagePaths.isNotEmpty) {
        images.assignAll(imagePaths.map((path) => XFile(path)));
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Date selection
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate.value = "${picked.month}/${picked.day}/${picked.year}";
    }
  }

  // Validation method
  bool validateForm() {
    if (selectedActivities.isEmpty) {
      Get.snackbar("Validation Error", "Please select at least one activity.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedActivities.contains("Any other activities ( specify)") &&
        otherActivity.isEmpty) {
      Get.snackbar("Validation Error", "Please specify the other activity.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedTasks.contains("Other task (s) (specify)") &&
        otherTask.isEmpty) {
      Get.snackbar("Validation Error", "Please specify the other task.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedChallenges.isEmpty) {
      Get.snackbar("Validation Error", "Please select at least one challenge.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar("Validation Error", "Please provide a description.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (selectedDate.isEmpty) {
      Get.snackbar("Validation Error", "Please select a follow-up date.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    if (images.isEmpty) {
      Get.snackbar("Validation Error", "Please add at least one photo.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  // Form submission
  void submitForm(String parishid) async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      List<String> imageUrls = [];
      for (var image in images) {
        String res = await AWSService().uploadToS3(image.path, image.name);
        if (res == "IMAGE UPLOADED") {
          imageUrls.add(
              "https://2024-app-uploads.s3.amazonaws.com/${image.path.split('/').last}");
        }
      }

      final reportData = {
        "Name of BC": bcData.bcId.value.trim(),
        "Parish": parishid,
        "Bcs activities": selectedActivities,
        if (selectedActivities.contains("Any other activities ( specify)") &&
            otherActivity.value.isNotEmpty)
          "Other Activities": otherActivity.value,
        "Tasks assigned to the PC": selectedTasks,
        if (selectedTasks.contains("Other task (s) (specify)") &&
            otherTask.value.isNotEmpty)
          "Other tasks": otherTask.value,
        "Groups for tasks": selectedGroups.join(', '),
        "Follow-up Date": selectedDate.value,
        "Description": description.value,
        "Challenges": selectedChallenges,
        if (selectedChallenges.contains("Others (specify)") &&
            otherChallenge.value.isNotEmpty)
          "Other Challenge": otherChallenge.value,
        "photo URLs": imageUrls.join(', '),
      };

      reportData.forEach((key, value) {
        print("$key: $value");
      });

      // Submit data to Airtable
      var res = await currentNurseryBase.createRecord(
          'BCs Parish Visit Reports', reportData);
      if (res.fields.isNotEmpty) {
        clearForm();
        await userData.loadReportsFromStorage();
        Get.offAndToNamed(Routes.dashboard);

        Get.snackbar('Success', 'Report was successfully submitted',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Submission Failed', 'Error: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form fields
  void clearForm() {
    description.value = '';
    otherChallenge.value = '';
    otherActivity.value = '';
    otherTask.value = '';
    selectedActivities.clear();
    selectedChallenges.clear();
    selectedTasks.clear();
    images.clear();
    selectedDate.value = '';
  }
}
