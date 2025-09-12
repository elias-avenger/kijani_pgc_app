import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/dropdown_field.dart';
import 'package:kijani_pgc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pgc_app/components/widgets/file_upload_field.dart';
import 'package:kijani_pgc_app/components/widgets/multi_select_field.dart';
import 'package:kijani_pgc_app/components/widgets/text_area_field.dart';
import 'package:kijani_pgc_app/controllers/report_controller.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());
    final UserController userdata = Get.put(UserController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daily Activity Report"),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedCircleArrowLeft01,
            color: Colors.black,
            size: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select the parish you visited",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ParishDropdown(
                label: 'Parish Visited',
                parishes: userdata.parishes,
                onChanged: (value) => {
                  controller.selectedParish.value = value!,
                },
              ),
              const SizedBox(height: 16),
              MultiSelectField(
                label: "Activity Carried Out",
                options: controller.activityOptions,
                selectedOptions: controller.selectedActivities,
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.selectedActivities.any(
                  (activity) => activity == "Other activities",
                )) {
                  return TextAreaWidget(
                    label: "Other Activity(ies)",
                    controller: controller.otherActivitiesController,
                    onChanged: (value) {
                      controller.otherActivities.value = value;
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              TextAreaWidget(
                label:
                    "Provide more details about the activity and any general feedback",
                controller: controller.detailsController,
                onChanged: (value) {
                  controller.details.value = value;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Upload any images taken during the visit",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ImagePickerWidget(
                onImagesSelected: (values) => {
                  if (values.isNotEmpty)
                    {controller.attachments.addAll(values)},
                },
                label: "Add Images",
              ),
              const SizedBox(height: 16),
              MultiSelectField(
                label: "Next day's activities",
                options: controller.activityOptions,
                selectedOptions: controller.nextActivities,
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.nextActivities.any(
                  (activity) => activity == "Other assignment",
                )) {
                  return TextAreaWidget(
                    label: "Other Next Activity(ies)",
                    controller: controller.otherNextActivitiesController,
                    onChanged: (value) {
                      controller.otherNextActivities.value = value;
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 24),
              PrimaryButton(
                text: "Submit",
                onPressed: () => controller.submitForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
