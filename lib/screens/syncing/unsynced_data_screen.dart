import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pgc_app/components/widgets/cards/unsynced_data_card.dart';
import 'package:kijani_pgc_app/controllers/syncing_controller.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';

class UnsyncedDataScreen extends StatelessWidget {
  const UnsyncedDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SyncingController controller = Get.put(SyncingController());
    final UserController userController = Get.find<UserController>();
    final ReportRepository reportRepo = ReportRepository();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Unsynced Data",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: userController.unsyncedReports < 1
                  ? const _NoUnsyncedDataWidget()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: controller.unsyncedDataList.length,
                      itemBuilder: (context, index) {
                        final data = controller.unsyncedDataList[index];
                        return UnsyncedDataCard(
                          title: "Daily Reports",
                          lastRecorded:
                              GetTimeAgo.parse(DateTime.parse(data.date)),
                          count: data.images.length,
                          icon: HugeIcons.strokeRoundedHugeicons,
                        );
                      },
                    ),
            ),
            if (controller.unsyncedDataList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  text: "Sync Data",
                  onPressed: controller.syncReportsData,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A widget displayed when there is no unsynced data.
class _NoUnsyncedDataWidget extends StatelessWidget {
  const _NoUnsyncedDataWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with a subtle background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1), // Light green background
            ),
            child: const Icon(
              Icons.cloud_done,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          // Main message
          const Text(
            "All Data Synced!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle with additional context
          Text(
            "You're up to date. No pending data to sync.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Optional action button (e.g., return to home)
          TextButton(
            onPressed: () => Get.offAndToNamed(Routes.HOME),
            child: const Text(
              "Back to Home",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
