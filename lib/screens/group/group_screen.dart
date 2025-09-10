import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/empty_widget.dart';
import 'package:kijani_pgc_app/components/reusable_body.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
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

      return Scaffold(
        appBar: MyAppBar(title: group),
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
              icon: HugeIcons.strokeRoundedLocation03,
              color: kijaniBlue,
            ),
            GridItem(
                title: "", value: 0, icon: null, color: kijaniBrown),
            GridItem(
                title: "", value: 0, icon: null, color: Colors.black),
            GridItem(
                title: "", value: 0, icon: null, color: kijaniGreen),
          ],
          items: farmers,
          itemBuilder: (context, farmer, index) => CustomListItem(
            title: farmer.name,
            subtitle: "{farmer.gardens.length}",
            trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                color: Colors.black),
            onTap: () {
              // Your logic
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
