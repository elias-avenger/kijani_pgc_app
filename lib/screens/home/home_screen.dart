import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pmc_app/components/app_drawer.dart';
import 'package:kijani_pmc_app/components/reusable_body.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';
import 'package:kijani_pmc_app/models/grid_item.dart';
import 'package:kijani_pmc_app/models/user_model.dart';
import 'package:kijani_pmc_app/components/widgets/list_tile.dart';
import 'package:kijani_pmc_app/routes/app_pages.dart';
import 'package:kijani_pmc_app/utilities/constants.dart';
import 'package:badges/badges.dart' as badges;
import 'package:kijani_pmc_app/utilities/greetings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    final Greetings greetings = Greetings();

    return Obx(() {
      final user = User.fromJson(userController.branchData);
      final parishes = userController.parishes;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMenu02,
                color: Colors.black,
              ),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                greetings.formattedDate(),
                style: GoogleFonts.roboto(fontSize: 14, color: kGreyText),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Get.toNamed(Routes.UNSYCEDDATA),
              child: Container(
                margin: const EdgeInsets.only(right: 18),
                child: badges.Badge(
                  badgeContent: Text(
                    "5",
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                  child: const Icon(HugeIcons.strokeRoundedDatabaseSync01),
                ),
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Hi, ${user.name}",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.white,
        ),
        drawer: CustomDrawer(),
        body: ReusableScreenBody(
          listTitle: "Assigned Parishes",
          gridItems: [
            GridItemModel(
              title: "Parishes",
              value: user.parishes.split(",").length,
              icon: HugeIcons.strokeRoundedLocation03,
              color: kijaniBlue,
            ),
            GridItemModel(title: "", value: 0, icon: null, color: kijaniBrown),
            GridItemModel(title: "", value: 0, icon: null, color: Colors.black),
            GridItemModel(title: "", value: 0, icon: null, color: kijaniGreen),
          ],
          items: parishes,
          itemBuilder: (context, parish, index) => CustomListItem(
            title: "${parish.name} Parish",
            subtitle: "${parish.groupIDs.length} Groups",
            trailing: index < 1
                ? const Icon(HugeIcons.strokeRoundedAccess, color: Colors.green)
                : const Icon(HugeIcons.strokeRoundedSquareLock02,
                    color: Colors.red),
            onTap: () {
              // Your logic
            },
          ),
        ),
      );
    });
  }
}
