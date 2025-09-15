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

import '../../controllers/farmer_controller.dart';

class FarmerScreen extends StatelessWidget {
  const FarmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FarmerController farmerController = Get.put(FarmerController());

    return Obx(() {
      final gardens = farmerController.gardens;
      final farmer = farmerController.activeFarmerName.value;
      var isLoading = farmerController.isGardensLoading.value;

      var numTreesPlanted = 0;
      for (var garden in gardens) {
        numTreesPlanted += garden.treesPlanted;
      }

      return Scaffold(
        appBar: MyAppBar(title: farmer),
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const ReusableScreenBodySkeleton()
            : gardens.isNotEmpty
                ? ReusableScreenBody(
                    listTitle: "Farmer gardens",
                    gridItems: [
                      GridItem(
                        title: "Gardens",
                        value: gardens.length,
                        icon: HugeIcons.strokeRoundedPlant03,
                        color: kijaniBlue,
                      ),
                      GridItem(
                        title: "Trees planted",
                        value: numTreesPlanted,
                        icon: HugeIcons.strokeRoundedPlant01,
                        color: kijaniBrown,
                      ),
                      GridItem(
                          title: "", value: 0, icon: null, color: Colors.black),
                      GridItem(
                          title: "", value: 0, icon: null, color: kijaniGreen),
                    ],
                    items: gardens,
                    itemBuilder: (context, garden, index) => CustomListItem(
                      title: garden.id,
                      subtitle: "${garden.treesPlanted} trees planted",
                      trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                          color: Colors.black),
                      onTap: () {
                        // Get.toNamed(Routes.GARDEN, arguments: {
                        //   'garden': garden.id,
                        // });
                        if (kDebugMode) {
                          print("Garden To Open: ${garden.id}");
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
                    title: "No farmer gardens found",
                  ),
      );
    });
  }
}
