import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pmc_app/app/data/models/parish_model.dart';
import 'package:kijani_pmc_app/app/modules/parish/controller/report.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';
import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class ParishReportFormScreen extends StatelessWidget {
  const ParishReportFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ParishReportController controller = Get.put(ParishReportController());
    final Parish parish = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Parish Report"),
        backgroundColor: kfGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle("BCs activities *"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
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
                if (controller.selectedActivities
                    .contains("Any other activities ( specify)")) {
                  return TextField(
                    onChanged: (value) =>
                        controller.otherActivity.value = value,
                    decoration: _inputDecoration("Other Activity"),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Tasks assigned to the PC *"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  controller.predefinedTasks,
                  controller.selectedTasks,
                  "Select Tasks",
                ),
                child: const Text("Select Tasks"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedTasks)),
              Obx(() {
                if (controller.selectedTasks
                    .contains("Other task (s) (specify)")) {
                  return TextField(
                    onChanged: (value) => controller.otherTask.value = value,
                    decoration: _inputDecoration("Other Task"),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Groups the Task Needs to be Done For *"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  parish.groups
                      .map((group) => group.id.split('|').first)
                      .toList(),
                  controller.selectedGroups,
                  "Select Groups",
                ),
                child: const Text("Select Groups"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedGroups)),
              const SizedBox(height: 20),
              _buildSectionTitle("Follow-up Date *"),
              Obx(() => TextField(
                    onTap: () => _selectDate(context, controller),
                    readOnly: true,
                    decoration: _inputDecoration("mm/dd/yyyy"),
                    controller: TextEditingController(
                      text: controller.selectedDate.value,
                    ),
                  )),
              const SizedBox(height: 20),
              _buildSectionTitle("Challenges *"),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kfBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () => _showSelectionDialog(
                  controller,
                  controller.predefinedChallenges,
                  controller.selectedChallenges,
                  "Select Challenges",
                ),
                child: const Text("Select Challenges"),
              ),
              Obx(() => _buildSelectedItems(controller.selectedChallenges)),
              Obx(() {
                if (controller.selectedChallenges
                    .contains("Others (specify)")) {
                  return TextField(
                    onChanged: (value) =>
                        controller.otherChallenge.value = value,
                    decoration: _inputDecoration("Other Challenge"),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 20),
              _buildSectionTitle("Description *"),
              TextField(
                onChanged: (value) => controller.description.value = value,
                maxLines: 3,
                decoration: _inputDecoration("Enter a description"),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Add some photo(s) (Max - 2) *"),
              _buildImagePicker(controller),
              const SizedBox(height: 30),
              Obx(
                () => EasyButton(
                  height: 50,
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
                    size: 25,
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (controller.validateForm()) {
                            controller.submitForm(parish.id);
                          }
                        },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => controller.clearForm(),
                child: const Text("Clear form"),
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

  Future<void> _showSelectionDialog(
    ParishReportController controller,
    List<String> options,
    RxList<String> selectedList,
    String title,
  ) async {
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
      selectedList.assignAll(selected);
    }
  }

  Future<void> _selectDate(
      BuildContext context, ParishReportController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.selectedDate.value =
          "${picked.month}/${picked.day}/${picked.year}";
    }
  }

  Widget _buildImagePicker(ParishReportController controller) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 34),
                  const SizedBox(height: 8),
                  Text(
                    "Browse Photos from gallery",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
