import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pgc_app/controllers/garden_compliance_report.dart';
import 'package:kijani_pgc_app/screens/reports/compliancesections/section_one.dart';
import 'package:kijani_pgc_app/screens/reports/compliancesections/section_two.dart';
import 'package:kijani_pgc_app/screens/reports/compliancesections/section_three.dart';

class GardenComplianceForm extends StatefulWidget {
  const GardenComplianceForm({super.key});

  @override
  State<GardenComplianceForm> createState() => _GardenComplianceFormState();
}

class _GardenComplianceFormState extends State<GardenComplianceForm> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Expecting a String gardenId, fallback for safety
  final String gardenId =
      (Get.arguments is String) ? Get.arguments as String : 'Garden';

  late final GardenComplianceController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(GardenComplianceController());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (c.isLoading.value) return;

    if (_currentStep == 0) {
      final ok = c.section1FormKey.currentState?.validate() ?? false;
      if (!ok) return;
    } else if (_currentStep == 1) {
      final ok = c.section2FormKey.currentState?.validate() ?? false;
      final polyOk = c.polypotsCompliance.isNotEmpty;
      if (!ok || !polyOk) return;
    } else if (_currentStep == 2) {
      final ok = c.section3FormKey.currentState?.validate() ?? false;
      if (!ok) return;
      await _submit(); // final step -> submit
      return;
    }

    setState(() => _currentStep++);
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _previousStep() async {
    if (c.isLoading.value) return;
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      // First step: normal back
      Get.back();
    }
  }

  Future<void> _submit() async {
    await c.submitReport(gardenId);
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
        onBack: _previousStep,
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
            child: Obx(
              () => PrimaryButton(
                text: _currentStep == 2 ? 'Submit' : 'Next',
                isLoading: c.isLoading.value,
                onPressed: _nextStep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
