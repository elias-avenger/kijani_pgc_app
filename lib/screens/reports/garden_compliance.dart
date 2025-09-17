import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pgc_app/controllers/garden_compliance_report.dart';
import 'package:kijani_pgc_app/screens/reports/compliancesections/section_one.dart';
import 'package:kijani_pgc_app/screens/reports/compliancesections/section_three.dart';
import 'package:kijani_pgc_app/screens/reports/compliancesections/section_two.dart';

class GardenComplianceForm extends StatefulWidget {
  const GardenComplianceForm({super.key});

  @override
  State<GardenComplianceForm> createState() => _GardenComplianceFormState();
}

class _GardenComplianceFormState extends State<GardenComplianceForm> {
  final _pageController = PageController();
  int _currentStep = 0;

  var gardenId = Get.arguments ?? 'Garden';

  late final GardenComplianceController c;

  @override
  void initState() {
    super.initState();
    // Make controller available to all sections (no Get.arguments needed)
    c = Get.put(GardenComplianceController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    // If this form is one-time, uncomment to dispose controller when leaving
    // Get.delete<GardenComplianceController>();
    super.dispose();
  }

  // garden_compliance_form.dart
  // in GardenComplianceForm._nextStep()
  void _nextStep() {
    final c = Get.find<GardenComplianceController>();

    if (_currentStep == 0) {
      final ok = c.section1FormKey.currentState?.validate() ?? false;
      if (!ok) return;
    } else if (_currentStep == 1) {
      final ok = c.section2FormKey.currentState?.validate() ?? false;
      final polyOk = c.polypotsCompliance.value.isNotEmpty;
      if (!ok || !polyOk) return;
    } else if (_currentStep == 2) {
      final ok = c.section3FormKey.currentState?.validate() ?? false;
      if (!ok) return;
      _submit();
      return;
    }

    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _submit() {
    //TODO: call the function to submit the report from the controller
    //NOTE: the function to be callled, should have the garden ID as a parameter
    c.submitReport(gardenId);
    // Get.snackbar(
    //   'Success',
    //   'Garden compliance report for "$gardenId" submitted successfully!',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    // );
    // Get.back(); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_currentStep) {
      0 => 'Garden Compliance Report',
      1 => 'Section 2: Garden Compliance Report',
      _ => 'Section 3: Garden Compliance Report',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        title: title,
        onBack: () => _currentStep == 0 ? Get.back() : _previousStep(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                GardenComplianceSectionOne(),
                GardenComplianceSectionTwo(),
                GardenComplianceSectionThree(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            child: PrimaryButton(
              text: _currentStep == 2 ? 'Submit' : 'Next',
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
