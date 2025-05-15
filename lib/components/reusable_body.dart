// reusable_screen_body.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pgc_app/components/widgets/grid_card.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/controllers/syncing_controller.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';

class ReusableScreenBody<T> extends StatelessWidget {
  final String? listTitle;
  final List<GridItem> gridItems;
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final int crossAxisCount;

  const ReusableScreenBody({
    super.key,
    this.listTitle,
    required this.gridItems,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final unsyncedReports =
                Get.put(SyncingController()).unsyncedDataList.length;
            if (unsyncedReports == 0) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.all(10),
              height: Get.height * 0.08,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red[500]!,
                  width: 1.5,
                ),
                color: Colors.red[100],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You have unsynced data.",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.UNSYCEDDATA);
                      },
                      child: Text(
                        "Sync Now",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      )),
                ],
              ),
            );
          }),
          if (gridItems.isNotEmpty) ...[
            SizedBox(height: Get.height * 0.05),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: gridItems.map((item) {
                return gridCard(item.title, item.value, item.icon, item.color);
              }).toList(),
            ),
            SizedBox(height: Get.height * 0.05),
          ],
          if (listTitle != null)
            Text(
              listTitle!,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          if (items.isNotEmpty) ...[
            SizedBox(height: Get.height * 0.02),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index], index),
            ),
          ],
        ],
      ),
    );
  }
}

class ReusableScreenBodySkeleton<T> extends StatelessWidget {
  final String? listTitle;
  final int gridItemCount;
  final int listItemCount;
  final int crossAxisCount;

  const ReusableScreenBodySkeleton({
    super.key,
    this.listTitle,
    this.gridItemCount = 4,
    this.listItemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🛑 Unsynced message placeholder (optional)
          Container(
            padding: const EdgeInsets.all(10),
            height: Get.height * 0.08,
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red[100],
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 18,
                    width: 150,
                    color: Colors.red[300],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 36,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Get.height * 0.05),

          // 🔲 Grid skeleton
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: List.generate(
              gridItemCount,
              (_) => gridCardSkeleton(),
            ),
          ),

          SizedBox(height: Get.height * 0.05),

          // 📄 List title skeleton
          if (listTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 20,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

          // 📋 List items skeleton
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listItemCount,
            itemBuilder: (context, index) {
              return const CustomListItemSkeleton();
            },
          ),
        ],
      ),
    );
  }
}
