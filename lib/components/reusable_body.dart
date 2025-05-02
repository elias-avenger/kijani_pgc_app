// reusable_screen_body.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kijani_pgc_app/components/widgets/grid_card.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';

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
