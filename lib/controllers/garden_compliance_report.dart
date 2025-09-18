// garden_compliance_report.dart
import 'package:airtable_crud/airtable_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/services/location.dart';

import '../models/photo.dart';
import '../models/return_data.dart';
import '../repositories/report_repository.dart';

class GardenComplianceController extends GetxController {
  ReportRepository reportRepo = ReportRepository();
  UserController userController = Get.find<UserController>();
  Locator location = Locator();

  final weeded = false.obs;
  final gapfilling = false.obs;
  final singling = false.obs;
  final debudding = false.obs;
  final pruned = false.obs;
  final firelines = false.obs;

  final RxList<String> gardenPhotos = <String>[].obs;

  final weedingCompliance = "".obs;
  final plantingCompliance = "".obs;
  final gapFillingCompliance = "".obs;
  final singlingCompliance = "".obs;
  final firelinesCompliance = "".obs;
  final pruningCompliance = "".obs;
  final debuddingCompliance = "".obs;

  final charcoalSpeciesSpacing = "".obs;
  final timberSpeciesSpacing = "".obs;
  final polypotsCompliance = "".obs;

  final nextFollowUpDate = "".obs;
  final comments = "".obs;

  // 🔑 FormKey for Section 1
  final GlobalKey<FormState> section1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> section2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> section3FormKey = GlobalKey<FormState>();

  Future<void> submitReport(gardenId) async {
    String userLocation = await location.getPointCoordinates();

    List<Photo> gardenPhoto = (gardenPhotos.toList() as List<dynamic>?)
            ?.map((e) => Photo.fromPath(e.toString()))
            .toList() ??
        [];
    Map<String, dynamic> data = {
      'Garden': gardenId,
      'Compliance Status': getGardenCompliance(),
      'Garden Photo': gardenPhoto,
      'Weeding Compliance': weedingCompliance.value,
      'Planting Compliance': plantingCompliance.value,
      'Gap-filling Compliance': gapFillingCompliance.value,
      'Singling Compliance': singlingCompliance.value,
      'Fire-lines Compliance': firelinesCompliance.value,
      'Pruning Compliance': pruningCompliance.value,
      'Debudding Compliance': debuddingCompliance.value,
      'Charcoal species spacing': charcoalSpeciesSpacing.value,
      'Timber species spacing': timberSpeciesSpacing.value,
      'Polypots in garden': polypotsCompliance.value,
      'Date of next follow up': nextFollowUpDate.value,
      'Comments': comments.value, // Pass List<String>
      'Visit Date': DateTime.now().toIso8601String(),
      'Visited by': userController.branchData['ID'].trim(),
      'User Location': userLocation,
    };
    Data<AirtableRecord> isSubmitted = await reportRepo.submitReport(
      data: data,
      reportKey: 'GardenCompliance',
      photoFields: ['Garden Photo'],
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
        userController.unsyncedReports.value += 1;
        _clearForm();
        Get.back();
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
        Get.back();
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
        Get.back();
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
    // Navigate to previous screen
    Get.back();
  }

  List getGardenCompliance() {
    List complianceInputs = [
      weeded.value,
      gapfilling.value,
      singling.value,
      debudding.value,
      pruned.value,
      firelines.value,
    ];
    List complianceOptions = [
      "Weeded",
      "Gap Filling done (As needed)",
      "Singling done (As needed)",
      "Debudding (As needed)",
      "Pruned (As needed)",
      "Firelines",
    ];
    List complianceValues = [];
    for (int i = 0; i < complianceInputs.length; i++) {
      if (complianceInputs[i]) {
        complianceValues.add(complianceOptions[i]);
      }
    }
    return complianceValues;
  }

  void _clearForm() {
    weeded.value = false;
    gapfilling.value = false;
    singling.value = false;
    debudding.value = false;
    pruned.value = false;
    firelines.value = false;
    gardenPhotos.value = [];
    weedingCompliance.value = "";
    plantingCompliance.value = "";
    gapFillingCompliance.value = "";
    singlingCompliance.value = "";
    firelinesCompliance.value = "";
    pruningCompliance.value = "";
    debuddingCompliance.value = "";
    charcoalSpeciesSpacing.value = "";
    timberSpeciesSpacing.value = "";
    polypotsCompliance.value = "";
    nextFollowUpDate.value = "";
    comments.value = "";
  }
}
