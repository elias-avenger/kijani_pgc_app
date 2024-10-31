import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kijani_pmc_app/app/data/providers/greetings.dart';
import 'package:kijani_pmc_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:kijani_pmc_app/app/modules/mel/controllers/mel_controller.dart';
import 'package:kijani_pmc_app/app/modules/pmc/controllers/pmc_controller.dart';
import 'package:kijani_pmc_app/app/routes/routes.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';
import 'package:kijani_pmc_app/global/widgets/linear_progress.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final MelController melControler = Get.find<MelController>();
    final PmcController pmcControler = Get.find<PmcController>();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'images/kijani_logo.png',
            color: Colors.white,
          ),
        ),
        backgroundColor: kfGreen,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'logout') {
                authController.logout();
              }
              if (value == 'report') {
                if (authController.userRole.value == 'pmc') {
                  Get.toNamed(Routes.pmcReport);
                } else if (authController.userRole.value == 'bc') {
                  Get.toNamed(Routes.bcReport);
                } else if (authController.userRole.value == 'mel') {
                  Get.toNamed(Routes.melReport);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(
                        Icons.report,
                        color: kfGreen,
                      ),
                      const SizedBox(width: 16),
                      Text('Submit Report', style: GoogleFonts.lato()),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  print(
                      "isUpdating value: ${authController.isUpdating.value}"); // Debug print
                  return authController.isUpdating.value
                      ? const UpdatingProgressIndicator()
                      : const SizedBox.shrink();
                }),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TimeProvider().greeting(),
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Display user data and today's date
                Obx(() {
                  if (authController.userData.isEmpty) {
                    return const Text('No user data available');
                  }

                  final userData = authController.userData;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authController.userRole == 'bc'
                            ? '${userData['BC-Name'] ?? 'N/A'}'
                            : authController.userRole == 'mel'
                                ? '${userData['MEL Officer'].split('|')[1].trim() ?? 'N/A'}'
                                : '${userData['PMC'].split('|')[1].trim() ?? 'N/A'}',
                        style: GoogleFonts.lato(
                          color: kfGreen,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${userData['Branch']}",
                        style: GoogleFonts.lato(
                          color: const Color(0xff23566d),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),

                const SizedBox(height: 30),

                // Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => _buildSummaryCard(
                        title: "Reports Submitted",
                        count: authController.userRole == "mel"
                            ? melControler.reports.toString()
                            : authController.userRole == "pmc"
                                ? pmcControler.reports.toString()
                                : "0",
                        icon: Icons.assignment_turned_in,
                        color: kfGreen,
                      ),
                    ),
                    _buildSummaryCard(
                      title: "Parishes Assigned",
                      count: authController.parishData.length.toString(),
                      icon: Icons.location_city,
                      color: kfGreen,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  'Assigned Parishes',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                // Show list of parishes data
                Obx(() {
                  if (authController.parishData.isEmpty) {
                    return const Center(
                      child: Text(
                        'No parishes data available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    children: authController.parishData.map((parish) {
                      return GestureDetector(
                        onTap: () =>
                            Get.toNamed(Routes.parish, arguments: parish),
                        child: Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: kfGreen.withOpacity(0.1),
                              child: Icon(
                                Icons.location_on,
                                color: kfGreen,
                              ),
                            ),
                            title: Column(
                              children: [
                                Text(
                                  parish.name,
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for creating summary cards
  Widget _buildSummaryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                count,
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
