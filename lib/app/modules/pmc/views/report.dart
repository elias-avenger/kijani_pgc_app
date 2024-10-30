import 'dart:io';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/pmc/controllers/report_UI_controller.dart';
import 'package:kijani_pmc_app/app/modules/pmc/controllers/report_controller.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';
import 'package:kijani_pmc_app/global/services/image_services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PmcReportScreen extends StatefulWidget {
  const PmcReportScreen({super.key});

  @override
  State<PmcReportScreen> createState() => _PmcReportScreenState();
}

class _PmcReportScreenState extends State<PmcReportScreen> {
  static final _formKey = GlobalKey<FormState>();
  final TextEditingController descController = TextEditingController();
  final ReportsController dataController = Get.put(ReportsController());
  final ReportController controller = Get.put(ReportController());
  final AuthController userController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Form"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Obx(
              () {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildSelectionButton(
                      title: 'Select Activities',
                      category: 'activities',
                      items: controller.activities,
                    ),
                    const SizedBox(height: 10),
                    buildSelectedActivities(),
                    const SizedBox(height: 10),
                    buildSelectionButton(
                      title: 'Select Garden Challenges',
                      category: 'gardenChallenges',
                      items: controller.gardenChallenges,
                    ),
                    const SizedBox(height: 10),
                    buildSelectedGardenChallenges(),
                    const SizedBox(height: 10),
                    buildSelectionButton(
                      title: 'Select Farmer Challenges',
                      category: 'farmerChallenges',
                      items: controller.farmerChallenges,
                    ),
                    const SizedBox(height: 10),
                    buildSelectedFarmerChallenges(),
                    const SizedBox(height: 10),
                    buildSelectionButton(
                      title: 'Select Individual Challenges',
                      category: 'individualChallenges',
                      items: controller.selectedIndividualChallenges,
                    ),
                    const SizedBox(height: 10),
                    if (controller.selectedIndividualChallenges
                        .containsValue(true))
                      buildSelectedIndividualChallenges(),
                    const SizedBox(height: 20),
                    const Text('Report Description'),
                    TextFormField(
                      controller: descController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
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
                      loadingStateWidget:
                          LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: onSubmit,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSelectionButton({
    required String title,
    required String category,
    required Map<String, dynamic> items,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff23566d),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(14),
      ),
      onPressed: () {
        Get.defaultDialog(
          title: title,
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Obx(
              () => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      for (String item in items.keys)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(item),
                              trailing: Checkbox(
                                activeColor: Colors.green,
                                value: items[item],
                                onChanged: (value) {
                                  controller.toggleItem(category, item, value!);
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Text(title),
    );
  }

  Widget buildSelectedActivities() {
    return Column(
      children: [
        for (String activity in controller.activities.keys)
          if (controller.activities[activity]!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: activity == 'Pest and disease control'
                      ? "Enter number of gardens for Pest and disease control"
                      : "Enter number for $activity",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Color(0xff23566d),
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  controller.updateItemDetails('activities', activity, value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
            ),
      ],
    );
  }

  Widget buildSelectedGardenChallenges() {
    return Column(
      children: [
        for (String challenge in controller.gardenChallenges.keys)
          if (controller.gardenChallenges[challenge]!)
            GestureDetector(
              onTap: () async {
                String? image =
                    await ImageServices().pickImage(ImageSource.gallery);
                if (image != '') {
                  controller.updateItemDetails(
                    'gardenChallenges',
                    challenge,
                    {'photoPath': image, 'name': image.split('/').last},
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Photo of $challenge",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final imagePath =
                            controller.gardenChallengeDetails[challenge];
                        if (imagePath != null && imagePath.isNotEmpty) {
                          return Image.file(
                            File(imagePath['photoPath']),
                            fit: BoxFit.cover,
                          );
                        } else {
                          return const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget buildSelectedFarmerChallenges() {
    return Column(
      children: [
        for (String challenge in controller.farmerChallenges.keys)
          if (controller.farmerChallenges[challenge]!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text(challenge),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Enter numbers",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Color(0xff23566d),
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      controller.updateItemDetails(
                          'farmerChallenges', challenge, value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget buildSelectedIndividualChallenges() {
    return Wrap(
      children: [
        const Text('Selected challenges:'),
        for (String challenge in controller.individualChallenges)
          if (controller.selectedIndividualChallenges[challenge]!)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "✅ $challenge",
              ),
            ),
      ],
    );
  }

  void onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final userData = userController.userData;

      Map<String, dynamic> dataToSubmit = {};

      // Add coordinator
      dataToSubmit['Coordinator'] =
          "${userData['Branch']} | ${userData['PMC']}";

      // Add activities and their numbers
      final selectedActivities =
          controller.getSelectedItemsWithDetails('activities');
      List<String> activitiesToSubmit = [];
      for (Map<String, dynamic> activity in selectedActivities) {
        activitiesToSubmit.add(activity['item']);
        int value = int.parse(activity['details']);
        switch (activity['item']) {
          case 'Weeding':
            dataToSubmit['Gardens weeded'] = value;
            break;
          case 'Pruning':
            dataToSubmit['Gardens pruned'] = value;
            break;
          case 'Thinning':
            dataToSubmit['Gardens thinned'] = value;
            break;
          case 'Pest and disease control':
            dataToSubmit['Gardens pest and disease Controlled'] = value;
            break;
          case 'Fire line creation':
            dataToSubmit['Gardens fire lines created'] = value;
            break;
          case 'Farmer contract signing':
            dataToSubmit['Farmer contracts signed'] = value;
            break;
          case 'Identifying outstanding farmers':
            dataToSubmit['Outstanding farmers identified'] = value;
            break;
          case 'Groups mobilization':
            dataToSubmit['Groups remobilized'] = value;
            break;
          case 'Farmers mobilization':
            dataToSubmit['Farmers mobilized'] = value;
            break;
          default:
            Get.snackbar("Error:", "Found wrong activity");
            break;
        }
      }
      dataToSubmit['Activities'] = activitiesToSubmit;

      // Add garden challenges and photos
      final selectedGardenChallenges =
          controller.getSelectedItemsWithDetails('gardenChallenges');
      List<String> gardenChallengesToSubmit = [];
      Map<String, dynamic> challengesPhotos = {};
      for (Map<String, dynamic> challenge in selectedGardenChallenges) {
        gardenChallengesToSubmit.add(challenge['item']);
        challengesPhotos[challenge['item']] = {
          'imagePath': challenge['details']['photoPath'],
          'imageName': challenge['details']['name'],
        };
      }
      dataToSubmit['Garden challenges'] = gardenChallengesToSubmit;
      dataToSubmit['Garden challenges photos'] = challengesPhotos;

      // Add farmer challenges and their details (numbers)
      final selectedFarmerChallenges =
          controller.getSelectedItemsWithDetails('farmerChallenges');
      List<String> farmerChallengesToSubmit = [];
      for (Map<String, dynamic> challenge in selectedFarmerChallenges) {
        farmerChallengesToSubmit.add(challenge['item']);
        dataToSubmit[challenge['item']] = int.parse(challenge['details']);
      }
      dataToSubmit['Farmer challenges'] = farmerChallengesToSubmit;

      // Add personal challenges
      List<String> individualChallengesToSubmit = [];
      final selectedIndividualChallenges =
          controller.getSelectedItemsWithDetails('individualChallenges');
      for (Map<String, dynamic> challenges in selectedIndividualChallenges) {
        individualChallengesToSubmit.add(challenges['item']);
      }
      dataToSubmit['Personal challenges'] = individualChallengesToSubmit;

      // Add description
      final description = descController.text;
      dataToSubmit['Description'] = description;

      // Add date
      dataToSubmit['Date'] =
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

      // Submit data
      await dataController.submitReport(reportData: dataToSubmit);
    }
  }
}
