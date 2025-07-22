import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';
import 'package:kijani_pgc_app/utilities/greetings.dart';

import '../controllers/user_controller.dart'; // adjust import
import '../routes/app_pages.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;

  const CustomHomeAppBar({
    super.key,
    required this.username,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();
    final Greetings greetings = Greetings();

    return AppBar(
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
        preferredSize: const Size.fromHeight(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Hi, $username",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class CustomHomeAppBarSkeleton extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomHomeAppBarSkeleton({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: const Padding(
        padding: EdgeInsets.all(12.0),
        child: CircleAvatar(backgroundColor: Colors.grey),
      ),
      title: Container(
        height: 14,
        width: 100,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 6),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 18),
          child: Icon(Icons.sync, color: Colors.grey),
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 20,
            width: 120,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
