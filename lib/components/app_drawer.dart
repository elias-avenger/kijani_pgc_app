import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/widgets/appdrawer.dart';
import 'package:kijani_pgc_app/components/widgets/avatar.dart';
import 'package:kijani_pgc_app/controllers/user_controller.dart';
import 'package:kijani_pgc_app/models/user_model.dart';

class CustomDrawer extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User user = User.fromJson(userController.branchData);

    return Drawer(
      backgroundColor: Colors.white,
      width: Get.width * 0.9,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.02,
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return DynamicCircleAvatar(
                          imageUrl: userController.userAvatar.value,
                        );
                      }),
                      //closing icon
                      GestureDetector(
                        child: const Icon(
                          HugeIcons.strokeRoundedCancelCircle,
                          size: 32,
                        ),
                        onTap: () => Get.back(),
                      )
                    ],
                  ),
                  //name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.toUpperCase(),
                        style: GoogleFonts.roboto(
                            fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                  Text(
                    "Plantation Growth Coordinator",
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  Text(
                    user.branch.toUpperCase(),
                    style: GoogleFonts.roboto(fontSize: 16),
                  )
                ],
              ),
            ),
            const Divider(),

            // Drawer Options
            Expanded(
              child: ListView(
                children: [
                  AppDrawerItem(
                    icon: HugeIcons.strokeRoundedSchoolReportCard,
                    title: 'Daily Reporting',
                    onTap: () => Get.toNamed('/dailyReport'),
                  ),
                  AppDrawerItem(
                    icon: HugeIcons.strokeRoundedRssError,
                    title: 'Report Grievance',
                    onTap: () => print('Go to grievance'),
                  ),
                  Obx(() {
                    return AppDrawerItem(
                      icon: HugeIcons.strokeRoundedDatabaseSync01,
                      title: 'View Unsynced Dataset',
                      onTap: () => print('Go to unsynced data'),
                      badgeCount: userController.unsyncedReports.value > 0
                          ? userController.unsyncedReports.value
                          : null,
                    );
                  }),
                  AppDrawerItem(
                    icon: HugeIcons.strokeRoundedLocationUpdate02,
                    title: 'Update all App local data',
                    onTap: () => print('Update data'),
                  ),
                  AppDrawerItem(
                    icon: HugeIcons.strokeRoundedCommentAdd01,
                    title: 'App Issue/ feedback',
                    onTap: () => print('Go to feedback'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedLogout05,
                  color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await Get.defaultDialog(
                  title: 'Logout?',
                  titlePadding: const EdgeInsets.all(12),
                  titleStyle: GoogleFonts.roboto(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  radius: 12,
                  backgroundColor: Colors.white,
                  barrierDismissible: false,
                  content: Column(
                    children: [
                      const Icon(
                        HugeIcons.strokeRoundedAlert02,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Are you sure you want to logout?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0.0,
                              ),
                              onPressed: () => Get.back(),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                await userController.logout();
                              },
                              child: const Text("Logout"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
