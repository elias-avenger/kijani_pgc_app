import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/mel/controllers/report_controller.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';
import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class MELReportFormScreen extends StatelessWidget {
  const MELReportFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MELReportController controller = Get.put(MELReportController());
    final AuthController authData = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Submit MEL Report",
        ),
        backgroundColor: kfGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "${authData.userData['MEL Officer']}--${authData.userData['Branch']}",
                style: GoogleFonts.lato(
                  color: const Color(0xff23566d),
                  fontSize: 18,
                ),
              ),
              _buildSectionTitle("Select Parishes"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  authData.parishData
                      .map((parish) => parish.id)
                      .toList(), // List of predefined parishes
                  controller.selectedParishes, // Selected parishes list
                  "Select Parishes",
                  isActivity:
                      false, // Set false to avoid reassigning activities
                ),
                child: const Text("Select Parishes"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedParishes)),
              _buildSectionTitle("Activities Implemented"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  controller.predefinedActivities,
                  controller.selectedActivities,
                  "Select Activities",
                ),
                child: const Text("Select Activities"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedActivities)),
              Obx(() {
                if (controller.selectedActivities.contains("Other")) {
                  return TextField(
                    onChanged: (value) =>
                        controller.otherActivity.value = value,
                    decoration: _inputDecoration("Specify other activity"),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Highlights"),
              TextField(
                onChanged: (value) => controller.highlights.value = value,
                maxLines: 3,
                decoration: _inputDecoration("Brief summary of achievements"),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("On-Site Observations"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  controller.predefinedOnSiteObservations,
                  controller.selectedObservations,
                  "Select Observations",
                ),
                child: const Text("Select Observations"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedObservations)),
              Obx(() {
                if (controller.selectedObservations.contains("Other")) {
                  return TextField(
                    onChanged: (value) =>
                        controller.otherObservation.value = value,
                    decoration: _inputDecoration("Specify other observation"),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Challenges Encountered"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  controller.predefinedChallenges,
                  controller.selectedChallenges,
                  "Select Challenges",
                  isActivity: false,
                ),
                child: const Text("Select Challenges"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedChallenges)),
              Obx(() {
                if (controller.selectedChallenges.contains("Other")) {
                  return TextField(
                    onChanged: (value) =>
                        controller.otherChallenge.value = value,
                    decoration: _inputDecoration("Specify other challenge"),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Plan For Tomorrow's Activity"),
              TextField(
                onChanged: (value) => controller.planForTomorrow.value = value,
                maxLines: 3,
                decoration: _inputDecoration("Enter plan for tomorrow"),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Photos"),
              _buildImagePicker(controller),
              const SizedBox(height: 30),
              EasyButton(
                height: 65,
                borderRadius: 16.0,
                buttonColor: kfGreen,
                idleStateWidget: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                loadingStateWidget: LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: controller.submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kfGreen,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Future<void> _showSelectionDialog(MELReportController controller,
      List<String> options, RxList<String> selectedList, String title,
      {bool isActivity = true}) async {
    final selected = await showDialog<List<String>>(
      context: Get.context!,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title,
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    return CheckboxListTile(
                      activeColor: kfGreen,
                      value: selectedList.contains(option),
                      title: Text(option),
                      onChanged: (bool? isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            selectedList.add(option);
                          } else {
                            selectedList.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      if (isActivity) {
        controller.selectedActivities.assignAll(selected);
      } else {
        controller.selectedChallenges.assignAll(selected);
      }
    }
  }

  Widget _buildImagePicker(MELReportController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: controller.isLoading.value ? null : controller.pickImages,
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey),
              ),
              child: controller.isLoading.value
                  ? Center(
                      child: Column(
                        children: [
                          LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.grey,
                            size: 30,
                          ),
                          const Text(
                            'Processing photos',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                          size: 34,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Select Photos",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.images.map((image) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildSelectedItems(RxList<String> selectedList) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: selectedList.map((item) {
        return Chip(
          label: Text(
            item,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          backgroundColor: kfGreen.withOpacity(0.8),
          deleteIcon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
          onDeleted: () {
            selectedList.remove(item);
          },
        );
      }).toList(),
    );
  }
}
