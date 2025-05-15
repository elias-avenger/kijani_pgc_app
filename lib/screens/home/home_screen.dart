import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_drawer.dart';
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

      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const HugeIcon(
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
                child: Obx(() {
                  return badges.Badge(
                    showBadge: userController.unsyncedReports > 0,
                    badgeContent: Text(
                      userController.unsyncedReports.toString(),
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                    child: const Icon(HugeIcons.strokeRoundedDatabaseSync01),
                  );
                }),
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

        /// ✅ Pull-to-Refresh Wrapper
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
          child: ReusableScreenBody(
            listTitle: "Assigned Parishes",
            gridItems: [
              GridItem(
                title: "Parishes",
                value: parishes.length,
                icon: HugeIcons.strokeRoundedLocation03,
                color: kijaniBlue,
              ),
              GridItem(title: "", value: 0, icon: null, color: kijaniBrown),
              GridItem(title: "", value: 0, icon: null, color: Colors.black),
              GridItem(title: "", value: 0, icon: null, color: kijaniGreen),
            ],
            items: parishes,
            itemBuilder: (context, parish, index) => CustomListItem(
              title: "${parish.name} Parish",
              subtitle: "{parish.groupIDs.length} Groups",
              trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.black),
              onTap: () {
                Get.toNamed(Routes.PARISH, arguments: {'parish': parish.id});
                print("Parish To Open: ${parish.name}");
              },
            ),
          ),
        ),
      );
    });
  }
}
