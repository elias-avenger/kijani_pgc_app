// garden_compliance_report.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GardenComplianceController extends GetxController {
  final weeded = false.obs;
  final gapfilling = false.obs;
  final singling = false.obs;

  final RxList<String> gardenPhotos = <String>[].obs;
  final treesByFarmer = "".obs;
  final treesByPGC = "".obs;

  final weedCompliance = "".obs;
  final plantingCompliance = "".obs;
  final charcoalSpeciesSpacing = "".obs;
  final timberSpeciesSpacing = "".obs;
  final polypotsCompliance = "".obs;

  final nextFollowUpDate = "".obs;
  final comments = "".obs;

  // 🔑 FormKey for Section 1
  final GlobalKey<FormState> section1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> section2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> section3FormKey = GlobalKey<FormState>();

  Map<String, dynamic> toJson() => {
        'weeded': weeded.value,
        'gapfilling': gapfilling.value,
        'singling': singling.value,
        'gardenPhotos': gardenPhotos.toList(),
        'treesByFarmer': treesByFarmer.value,
        'treesByPGC': treesByPGC.value,
        'weedCompliance': weedCompliance.value,
        'plantingCompliance': plantingCompliance.value,
        'charcoalSpeciesSpacing': charcoalSpeciesSpacing.value,
        'timberSpeciesSpacing': timberSpeciesSpacing.value,
        'polypotsCompliance': polypotsCompliance.value,
        'nextFollowUpDate': nextFollowUpDate.value,
        'comments': comments.value,
      };
}
