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
import 'package:kijani_pgc_app/screens/map/map_screen.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';
import 'package:latlong2/latlong.dart';

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
                Get.to(
                  () => const ReusableRouteGardensMap(),
                  arguments: {
                    'gardens': [], //TODO: add all gardens here
                    'polygonOf': (garden) => garden.polygon,
                    'centerOf': (garden) =>
                        LatLng(garden.latitude ?? 0.0, garden.longitude ?? 0.0),
                    'nameOf': (garden) => garden.name ?? 'Unnamed Garden',
                    'title': 'Group Gardens & Routes',
                  },
                );
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
                          title: "", value: 0, icon: null, color: kijaniBrown),
                      GridItem(
                          title: "", value: 0, icon: null, color: Colors.black),
                      GridItem(
                          title: "", value: 0, icon: null, color: kijaniGreen),
                    ],
                    items: farmers,
                    itemBuilder: (context, farmer, index) => CustomListItem(
                      title: "${farmer.name} [${farmer.phone}]",
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
