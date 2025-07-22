import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/empty_widget.dart';
import 'package:kijani_pgc_app/components/reusable_body.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/controllers/parish_controller.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';

class ParishScreen extends StatelessWidget {
  const ParishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ParishController parishController = Get.put(ParishController());

    return Obx(() {
      final groups = parishController.groups;
      final parish = parishController.activeParishName.value;
      var isLoading = parishController.isGroupsLoading.value;

      return Scaffold(
        appBar: MyAppBar(title: "$parish Parish"),
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const ReusableScreenBodySkeleton()
            : groups.isNotEmpty
                ? ReusableScreenBody(
                    listTitle: "Parish groups",
                    gridItems: [
                      GridItem(
                        title: "Groups",
                        value: groups.length,
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
                    items: groups,
                    itemBuilder: (context, group, index) => CustomListItem(
                      title: group.name,
                      subtitle: "${group.gardenIDs.length}",
                      trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                          color: Colors.black),
                      onTap: () {
                        // Your logic
                      },
                    ),
                  )
                : EmptyDataScreen(
                    onUpdate: () {
                      print("Updating data");
                    },
                    title: "No parish groups found",
                  ),
      );
    });
  }
}
