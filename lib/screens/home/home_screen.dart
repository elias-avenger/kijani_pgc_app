import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pmc_app/components/app_drawer.dart';
import 'package:kijani_pmc_app/controllers/user_controller.dart';
import 'package:kijani_pmc_app/models/dashboard_tile.dart';
import 'package:kijani_pmc_app/models/user_model.dart';
import 'package:kijani_pmc_app/components/widgets/grid_card.dart';
import 'package:kijani_pmc_app/components/widgets/list_tile.dart';
import 'package:kijani_pmc_app/routes/app_pages.dart';
import 'package:kijani_pmc_app/utilities/constants.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final user = User.fromJson(userController.branchData);
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
              "Tue, 05 Dec",
              style: GoogleFonts.roboto(fontSize: 14, color: kGreyText),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.UNSYCEDDATA);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              child: badges.Badge(
                badgeContent: Text(
                  "5",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                  ),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedDatabaseSync01,
                ),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DashboardTileGrid(tiles: dashboardTiles),
              SizedBox(height: Get.height * 0.05),
              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevents conflicts
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  gridCard(
                    "Parishes",
                    user.parishes.split(",").length,
                    HugeIcons.strokeRoundedLocation03,
                    kijaniBlue,
                  ),
                  gridCard(
                    "",
                    0,
                    null,
                    kijaniBrown,
                  ),
                  gridCard("", 0, null, Colors.black), // Empty card
                  gridCard("", 0, null, kijaniGreen), // Empty card
                ],
              ),
              SizedBox(height: Get.height * 0.05),
              Text(
                "Assigned Parishes",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              SizedBox(
                height: user.parishes.split(",").length *
                    70, // Approximate height to avoid unbounded height error in Column
                child: ListView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // disable scrolling, rely on outer scroll
                  itemCount: user.parishes.split(",").length,
                  itemBuilder: (context, index) {
                    return CustomListItem(
                      title: "${user.parishes.split(",")[index]} Parish",
                      onTap: () {
                        // Get.toNamed(
                        //   '/parish',
                        //   arguments: user.parishes.split(",")[index],
                        // );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
