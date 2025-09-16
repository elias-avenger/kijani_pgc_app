import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/reusable_body.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';

import '../../controllers/garden_controller.dart';
import '../../models/garden.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GardenController gardenController = Get.put(GardenController());

    return Obx(() {
      // final farmers = groupController.farmers;
      final garden = gardenController.activeGarden.value;
      var isLoading = gardenController.isGardenDataLoading.value;

      Garden gardenData = gardenController.garden;

      return Scaffold(
        appBar: MyAppBar(
          title: garden,
          menuActions: [
            AppMenuAction(
              id: 'compliance',
              label: 'Submit garden compliance Report',
              icon: HugeIcons.strokeRoundedTeacher,
              onTap: () {
                if (kDebugMode) {
                  print("Opening compliance report screen);");
                }
                // Get.toNamed(
                //   Routes.GARDENCOMPLIANCE,
                //   arguments: {
                //     'garden': garden,
                //   },
                // );
              },
            ),
            AppMenuAction(
              id: 'gardenMap',
              label: 'View Garden on the map',
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
            : ReusableScreenBody(
                listTitle: "Garden data",
                gridItems: [
                  GridItem(
                    title: "Trees planted",
                    value: gardenData.treesPlanted,
                    icon: HugeIcons.strokeRoundedPlant02,
                    color: kijaniBlue,
                  ),
                  GridItem(
                    title: "Trees surviving",
                    value: gardenData.treesSurviving,
                    icon: HugeIcons.strokeRoundedPlant03,
                    color: kijaniBrown,
                  ),
                  GridItem(
                      title: "", value: 0, icon: null, color: Colors.black),
                  GridItem(title: "", value: 0, icon: null, color: kijaniGreen),
                ],
                items: gardenData.speciesData,
                itemBuilder: (context, data, index) => CustomListItem(
                  title: data['species'],
                  subtitle:
                      "${data['planted']} planted - ${data['surviving']} surviving",
                  trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                      color: Colors.black),
                  onTap: () {
                    // Anything
                    // print("Data: $data");
                  },
                ),
              ),
      );
    });
  }
}
