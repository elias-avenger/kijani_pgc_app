// screens/unsynced_data_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pmc_app/components/widgets/cards/unsynced_data_card.dart';
import 'package:kijani_pmc_app/controllers/syncing_controller.dart';

class UnsyncedDataScreen extends StatelessWidget {
  const UnsyncedDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final SyncingController controller = Get.put(SyncingController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Use GetX for navigation
          },
        ),
        title: Text(
          "Unsynced Data",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => Column(
          children: [
            // List of unsynced data items
            Expanded(
              child: controller.unsyncedDataList.isEmpty
                  ? Center(child: Text("No unsynced data"))
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.unsyncedDataList.length,
                      itemBuilder: (context, index) {
                        final data = controller.unsyncedDataList[index];
                        return UnsyncedDataCard(
                          title: data.title,
                          lastRecorded: data.lastRecorded,
                          count: data.count,
                          icon: data.icon,
                        );
                      },
                    ),
            ),
            // Sync All Button
            if (controller.unsyncedDataList.isNotEmpty)
              // SyncAllButton(
              //   onPressed: controller.syncAll,
              // ),
              PrimaryButton(text: "Sync All", onPressed: controller.syncAll)
          ],
        ),
      ),
    );
  }
}
