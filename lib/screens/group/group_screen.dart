import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/empty_widget.dart';
import 'package:kijani_pgc_app/components/reusable_body.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';

import '../../controllers/group_controller.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.put(GroupController());

    return Obx(() {
      final farmers = groupController.farmers;
      final group = groupController.activeGroupName.value;
      var isLoading = groupController.isFarmersLoading.value;

      var numGardens = 0;
      for (var farmer in farmers) {
        numGardens += farmer.numGardens;
      }

      return Scaffold(
        appBar: MyAppBar(
          title: group,
          menuActions: [
            AppMenuAction(
              id: 'training',
              label: 'Submit farmer training Report',
              icon: HugeIcons.strokeRoundedTeacher,
              onTap: () {
                if (kDebugMode) {
                  print("Opening training report screen);");
                }
                Get.toNamed(
                  Routes.GROUPTRAINING,
                  arguments: {
                    'group': group,
                    'farmers': farmers,
                  },
                );
              },
            ),
            AppMenuAction(
              id: 'groupMap',
              label: 'View Group on the map',
              icon: HugeIcons.strokeRoundedMapsLocation01,
              onTap: () {
                if (kDebugMode) {
                  print("Refreshing data");
                }
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const ReusableScreenBodySkeleton()
            : farmers.isNotEmpty
                ? ReusableScreenBody(
                    listTitle: "Group farmers",
                    gridItems: [
                      GridItem(
                        title: "Farmers",
                        value: farmers.length,
                        icon: HugeIcons.strokeRoundedUser,
                        color: kijaniBlue,
                      ),
                      GridItem(
                        title: "Gardens",
                        value: numGardens,
                        icon: HugeIcons.strokeRoundedPlant03,
                        color: kijaniBrown,
                      ),
                      GridItem(
                          title: "", value: 0, icon: null, color: Colors.black),
                      GridItem(
                          title: "", value: 0, icon: null, color: kijaniGreen),
                    ],
                    items: farmers,
                    itemBuilder: (context, farmer, index) => CustomListItem(
                      title: farmer.name,
                      subtitle:
                          "[${farmer.phone}] - ${farmer.numGardens} gardens",
                      trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                          color: Colors.black),
                      onTap: () {
                        Get.toNamed(Routes.FARMER, arguments: {
                          'farmer': farmer.id,
                          'groupId': groupController.activeGroup.value,
                          'farmerData': farmer,
                        });
                        if (kDebugMode) {
                          print("Farmer To Open: ${farmer.name}");
                        }
                      },
                    ),
                  )
                : EmptyDataScreen(
                    onUpdate: () {
                      if (kDebugMode) {
                        print("Updating data");
                      }
                    },
                    title: "No group farmers found",
                  ),
      );
    });
  }
}
