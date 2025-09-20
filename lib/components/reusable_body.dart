// reusable_screen_body.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pgc_app/components/widgets/buttons/primary_button.dart';
import 'package:kijani_pgc_app/components/widgets/grid_card.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/controllers/syncing_controller.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';

/// A reusable screen scaffold that supports:
/// - Optional grid summary tiles (top)
/// - Optional "summary/report" section (key-value pairs + optional button)
/// - Optional list title and list of items
///
/// [T] is the type of list items rendered by [itemBuilder].
class ReusableScreenBody<T> extends StatelessWidget {
  // Header grid
  final List<GridItem> gridItems;
  final int crossAxisCount;

  // List
  final String? listTitle;
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? emptyListPlaceholder;

  // Summary/Report section (optional)
  /// Pass a list of pairs to render as "label : value" lines.
  final List<MapEntry<String, String>>? summaryData;

  /// Optional button under the summary.
  final String? summaryActionText;
  final VoidCallback? onSummaryAction;
  final Color summaryActionColor;

  /// Optional title for the summary box.
  final String? summaryTitle;

  const ReusableScreenBody({
    super.key,
    this.listTitle,
    required this.gridItems,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.emptyListPlaceholder,
    // summary/report
    this.summaryData,
    this.summaryActionText,
    this.onSummaryAction,
    this.summaryActionColor = Colors.black,
    this.summaryTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is available once.
    final syncingController = Get.put(SyncingController(), permanent: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔔 Unsynced data banner (auto-hides when none)
          Obx(() {
            final unsyncedReports = syncingController.unSyncedDataList.length;
            if (unsyncedReports == 0) return const SizedBox.shrink();

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
                    onPressed: () => Get.toNamed(Routes.UNSYCEDDATA),
                    child: Text(
                      "Sync Now",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // 🔲 Optional grid of summary tiles
          if (gridItems.isNotEmpty) ...[
            SizedBox(height: Get.height * 0.03),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: gridItems
                  .map((item) =>
                      gridCard(item.title, item.value, item.icon, item.color))
                  .toList(),
            ),
            SizedBox(height: Get.height * 0.03),
          ],

          // 🧾 Optional summary/report section
          if ((summaryData != null && summaryData!.isNotEmpty) ||
              summaryActionText != null) ...[
            Container(
              width: Get.width,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (summaryTitle != null) ...[
                    Text(
                      summaryTitle!,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (summaryData != null && summaryData!.isNotEmpty)
                    ...summaryData!.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                "${entry.key} :",
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 6,
                              child: Text(
                                entry.value,
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  // ⚡️ Optional quick action button
                  if (summaryActionText != null) ...[
                    SizedBox(height: Get.height * 0.02),
                    PrimaryButton(
                      text: summaryActionText!,
                      backgroundColor: summaryActionColor,
                      onPressed: onSummaryAction ?? () {},
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: Get.height * 0.02),
          ],

          // 📚 Optional list title
          if (listTitle != null)
            Text(
              listTitle!,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),

          // 📋 Items list or empty placeholder
          if (items.isNotEmpty) ...[
            SizedBox(height: Get.height * 0.02),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  itemBuilder(context, items[index], index),
            ),
          ] else if (emptyListPlaceholder != null) ...[
            SizedBox(height: Get.height * 0.02),
            emptyListPlaceholder!,
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
                width: 120,
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
