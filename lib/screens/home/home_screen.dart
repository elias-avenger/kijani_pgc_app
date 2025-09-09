import 'package:badges/badges.dart' as badges;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_drawer.dart';
import 'package:kijani_pgc_app/components/home_appbar.dart';
import 'package:kijani_pgc_app/components/reusable_body.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/models/user_model.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';
import 'package:kijani_pgc_app/utilities/greetings.dart';
import 'package:kijani_pgc_app/utilities/toast_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final Greetings greetings = Greetings();

    return Obx(() {
      final user = User.fromJson(userController.branchData);
      final parishes = userController.parishes;
      var isLoading = userController.isHomeScreenLoading.value;
      var numGroups = 0;
      for (var parish in parishes) {
        numGroups += parish.numGroups;
      }
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: isLoading
            ? const CustomHomeAppBarSkeleton()
            : CustomHomeAppBar(username: user.name),
        drawer: CustomDrawer(),
        body: RefreshIndicator(
          color: Colors.green,
          onRefresh: () async {
            // TODO: Fetch Data Here
            //simulate
            await Future.delayed(const Duration(seconds: 2));
            showToastGlobal(
              "Parish List is Updated",
              backgroundColor: Colors.green,
            );
          },
          child: isLoading
              ? const ReusableScreenBodySkeleton()
              : ReusableScreenBody(
                  listTitle: "Assigned Parishes",
                  gridItems: [
                    GridItem(
                      title: "Parishes",
                      value: parishes.length,
                      icon: HugeIcons.strokeRoundedLocation03,
                      color: kijaniBlue,
                    ),
                    GridItem(
                      title: "Groups",
                      value: numGroups,
                      icon: HugeIcons.strokeRoundedGroup01,
                      color: kijaniBrown,
                    ),
                    GridItem(
                        title: "", value: 0, icon: null, color: Colors.black),
                    GridItem(
                        title: "", value: 0, icon: null, color: kijaniGreen),
                  ],
                  items: parishes,
                  itemBuilder: (context, parish, index) => CustomListItem(
                    title: "${parish.name} Parish",
                    subtitle: "${parish.numGroups} Groups",
                    trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.black),
                    onTap: () {
                      Get.toNamed(Routes.PARISH, arguments: {
                        'parish': parish.id,
                        'name': parish.name
                      });
                      print("Parish To Open: ${parish.name}");
                    },
                  ),
                ),
        ),
      );
    });
  }
}
