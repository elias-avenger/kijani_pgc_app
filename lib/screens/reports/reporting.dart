import 'dart:io';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/controllers/UI%20controllers/report_controller.dart';
import 'package:kijani_pmc_app/controllers/reports_controller.dart';
import 'package:kijani_pmc_app/screens/main_screen.dart';
import 'package:kijani_pmc_app/utilities/constants.dart';
import 'package:kijani_pmc_app/utilities/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../controllers/user_controller.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static final _formKey = GlobalKey<FormState>();
  TextEditingController descController = TextEditingController();
  final UserController pmcCtrl = Get.find();
  final ReportsController dataController = Get.put(ReportsController());

  @override
  Widget build(BuildContext context) {
    final ReportController controller = Get.put(ReportController());

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
                    // Button to select activities
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff23566d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Select Activities",
                          content: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: Obx(
                              () => SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      for (String activity
                                          in controller.activities.keys)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Text(activity),
                                              trailing: Checkbox(
                                                activeColor: Colors.green,
                                                value: controller
                                                    .activities[activity],
                                                onChanged: (value) {
                                                  controller.toggleItem(
                                                      'activities',
                                                      activity,
                                                      value!);
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
                      child: const Text('Select Activities'),
                    ),
                    const SizedBox(height: 10),
                    // Display TextFormFields for selected activities
                    for (String activity in controller.activities.keys)
                      if (controller.activities[activity]! == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: activity == 'Pest and disease control '
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
                              controller.updateItemDetails(
                                  'activities', activity, value);
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
                    const SizedBox(height: 10),

                    // Button to select garden challenges
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff23566d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Select Garden Challenges",
                          content: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: Obx(
                              () => SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      for (String challenge
                                          in controller.gardenChallenges.keys)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Text(challenge),
                                              trailing: Checkbox(
                                                activeColor: Colors.green,
                                                value:
                                                    controller.gardenChallenges[
                                                        challenge],
                                                onChanged: (value) {
                                                  controller.toggleItem(
                                                      'gardenChallenges',
                                                      challenge,
                                                      value!);
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
                      child: const Text('Select Garden Challenges'),
                    ),
                    const SizedBox(height: 10),
                    // Display TextFormFields for selected garden challenges
                    for (String challenge in controller.gardenChallenges.keys)
                      if (controller.gardenChallenges[challenge]! == true)
                        GestureDetector(
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

                                  // Check if there's an image path for this challenge
                                  Obx(() {
                                    final imagePath = controller
                                        .gardenChallengeDetails[challenge];
                                    if (imagePath != null &&
                                        imagePath.isNotEmpty) {
                                      // Display the selected image
                                      return Image.file(
                                        File(imagePath['photoPath']),
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      // Display the camera icon if no image is selected
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
                          onTap: () async {
                            XFile? image =
                                await ImagePickerBrain().takePicture(context);
                            if (image != null) {
                              controller.updateItemDetails(
                                'gardenChallenges',
                                challenge,
                                {'photoPath': image.path, 'name': image.name},
                              );
                            }
                          },
                        ),

                    const SizedBox(height: 10),
                    // Button to select farmer challenges
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff23566d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Select Farmer Challenges",
                          content: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: Obx(
                              () => SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      for (String challenge
                                          in controller.farmerChallenges.keys)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Text(challenge),
                                              trailing: Checkbox(
                                                activeColor: Colors.green,
                                                value:
                                                    controller.farmerChallenges[
                                                        challenge],
                                                onChanged: (value) {
                                                  controller.toggleItem(
                                                      'farmerChallenges',
                                                      challenge,
                                                      value!);
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
                      child: const Text('Select Farmer Challenges'),
                    ),
                    const SizedBox(height: 10),
                    // Display TextFormFields for selected farmer challenges

                    for (String challenge in controller.farmerChallenges.keys)
                      if (controller.farmerChallenges[challenge]! == true)
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

                    const SizedBox(height: 10),

                    // Button to select individual challenges
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff23566d),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Select Individual Challenges",
                          content: Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: Obx(
                              () => SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      for (String challenge
                                          in controller.individualChallenges)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              title: Text(challenge),
                                              trailing: Checkbox(
                                                activeColor: Colors.green,
                                                value: controller
                                                        .selectedIndividualChallenges[
                                                    challenge],
                                                onChanged: (value) {
                                                  controller.toggleItem(
                                                      'individualChallenges',
                                                      challenge,
                                                      value!);
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
                      child: const Text('Select Individual Challenges'),
                    ),
                    const SizedBox(height: 10),

                    // Display selected individual challenges
                    if (controller.selectedIndividualChallenges
                        .containsValue(true))
                      Wrap(
                        children: [
                          const Text('Selected challenges:'),
                          for (String challenge
                              in controller.individualChallenges)
                            if (controller
                                    .selectedIndividualChallenges[challenge]! ==
                                true)
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "✅ $challenge",
                                ),
                              ),
                        ],
                      ),

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
                    // Submit Button
                    EasyButton(
                      height: 65,
                      borderRadius: 16.0,
                      buttonColor: kijaniGreen,
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          //initialise a map to hold report data to submit
                          Map<String, dynamic> dataToSubmit = {};

                          //add coordinator
                          dataToSubmit['Coordinator'] =
                              "${pmcCtrl.branchData['branch']} | ${pmcCtrl.branchData['coordinator']}";

                          //add activities and their numbers
                          final selectedActivities = controller
                              .getSelectedItemsWithDetails('activities');
                          List activitiesToSubmit = [];
                          for (Map<String, dynamic> activity
                              in selectedActivities) {
                            activitiesToSubmit.add(activity['item']);
                            activity['item'] == 'Weeding'
                                ? dataToSubmit['Gardens weeded'] =
                                    int.parse(activity['details'])
                                : activity['item'] == 'Pruning'
                                    ? dataToSubmit['Gardens pruned'] =
                                        int.parse(activity['details'])
                                    : activity['item'] == 'Thinning'
                                        ? dataToSubmit['Gardens thinned'] =
                                            int.parse(activity['details'])
                                        : activity['item'] ==
                                                'Pest and disease control'
                                            ? dataToSubmit['Gardens pest and disease Controlled'] =
                                                int.parse(activity['details'])
                                            : activity['item'] ==
                                                    'Fire line creation'
                                                ? dataToSubmit['Gardens fire lines created'] = int.parse(
                                                    activity['details'])
                                                : activity['item'] ==
                                                        'Farmer contract signing'
                                                    ? dataToSubmit['Farmer contracts signed'] =
                                                        int.parse(
                                                            activity['details'])
                                                    : activity['item'] ==
                                                            'Identifying outstanding farmers'
                                                        ? dataToSubmit['Outstanding farmers identified'] = int.parse(
                                                            activity['details'])
                                                        : activity['item'] ==
                                                                'Groups mobilization'
                                                            ? dataToSubmit['Groups remobilized'] =
                                                                int.parse(activity['details'])
                                                            : activity['item'] == 'Farmers mobilization'
                                                                ? dataToSubmit['Farmers mobilized'] = int.parse(activity['details'])
                                                                : Get.snackbar("Error:", "Found wrong activity");
                          }
                          dataToSubmit['Activities'] = activitiesToSubmit;

                          //add gardens challenges and photos
                          final selectedGardenChallenges = controller
                              .getSelectedItemsWithDetails('gardenChallenges');
                          List gardenChallengesToSubmit = [];
                          Map<String, dynamic> challengesPhotos = {};
                          for (Map<String, dynamic> challenge
                              in selectedGardenChallenges) {
                            gardenChallengesToSubmit.add(challenge['item']);
                            challengesPhotos[challenge['item']] = {
                              'imagePath': challenge['details']['photoPath'],
                              'imageName': challenge['details']['name'],
                            };
                          }
                          dataToSubmit['Garden challenges'] =
                              gardenChallengesToSubmit;
                          dataToSubmit['Garden challenges photos'] =
                              challengesPhotos;

                          // add farmer challenges and their details (numbers)
                          final selectedFarmerChallenges = controller
                              .getSelectedItemsWithDetails('farmerChallenges');
                          List farmerChallengesToSubmit = [];
                          for (Map<String, dynamic> challenge
                              in selectedFarmerChallenges) {
                            farmerChallengesToSubmit.add(challenge['item']);
                            dataToSubmit[challenge['item']] =
                                int.parse(challenge['details']);
                          }
                          dataToSubmit['Farmer challenges'] =
                              farmerChallengesToSubmit;

                          // add personal challenges
                          List individualChallengesToSubmit = [];
                          final selectedIndividualChallenges =
                              controller.getSelectedItemsWithDetails(
                                  'individualChallenges');
                          for (Map<String, dynamic> challenges
                              in selectedIndividualChallenges) {
                            individualChallengesToSubmit
                                .add(challenges['item']);
                          }
                          dataToSubmit['Personal challenges'] =
                              individualChallengesToSubmit;

                          //add description
                          final description = descController.text;
                          dataToSubmit['Description'] = description;

                          //add date
                          dataToSubmit['Date'] =
                              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

                          //submit data
                          String submitted = await dataController.submitReport(
                              reportData: dataToSubmit);
                          if (submitted == 'Data submitted successfully') {
                            Get.snackbar(
                              'Success',
                              'Report submitted successfully',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 7),
                            );
                            Get.off(const MainScreen());
                          } else if (submitted == 'No internet. Stored!') {
                            dataController.countUnSyncedReports();
                            Get.snackbar(
                              'No internet',
                              'Report stored locally',
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 7),
                            );
                            Get.off(const MainScreen());
                          } else {
                            dataController.countUnSyncedReports();
                            Get.snackbar(
                              'Error',
                              'Report submission failed',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 7),
                            );
                          }
                          if (kDebugMode) print("Response: $submitted");
                        }
                      },
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
}
