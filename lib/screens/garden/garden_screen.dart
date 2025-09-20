import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:kijani_pgc_app/components/app_bar.dart';
import 'package:kijani_pgc_app/components/reusable_body.dart';
import 'package:kijani_pgc_app/components/widgets/list_tile.dart';
import 'package:kijani_pgc_app/models/grid_item.dart';
import 'package:kijani_pgc_app/routes/app_pages.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';

import '../../controllers/garden_controller.dart';
import '../../models/garden.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GardenController gardenController = Get.put(GardenController());

    return Obx(() {
      // final farmers = groupController.farmers;
      final garden = gardenController.activeGarden.value;
      var isLoading = gardenController.isGardenDataLoading.value;

      Garden gardenData = gardenController.garden;

      return Scaffold(
        appBar: MyAppBar(
          title: garden,
          menuActions: [
            AppMenuAction(
              id: 'compliance',
              label: 'Submit garden compliance Report',
              icon: HugeIcons.strokeRoundedTeacher,
              onTap: () {
                if (kDebugMode) {
                  print("Opening compliance report screen);");
                }
                Get.toNamed(Routes.GARDENCOMPLIANCEREPORT, arguments: garden);
              },
            ),
            AppMenuAction(
              id: 'gardenMap',
              label: 'View Garden on the map',
              icon: HugeIcons.strokeRoundedMapsLocation01,
              onTap: () {
                if (kDebugMode) {
                  print("Refreshing data");
                }
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: isLoading
            ? const ReusableScreenBodySkeleton()
            : ReusableScreenBody(
                gridItems: [
                  GridItem(
                    title: "Trees planted",
                    value: "${gardenData.treesPlanted}",
                    icon: HugeIcons.strokeRoundedPlant02,
                    color: kijaniBlue,
                  ),
                  GridItem(
                    title: "Total Species",
                    value: gardenData.speciesData.length.toString(),
                    icon: HugeIcons.strokeRoundedLeaf03,
                    color: kijaniBrown,
                  ),
                  // GridItem(
                  //   title: "Area (Acres)",
                  //   value: "45",
                  //   icon: HugeIcons.strokeRoundedMapsLocation01,
                  //   color: kijaniGreen,
                  // ),
                  // GridItem(
                  //   title: "Farmers",
                  //   value: "12",
                  //   icon: HugeIcons.strokeRoundedUser,
                  //   color: kijaniGreen,
                  // ),
                ],
                summaryTitle: 'Garden Compliance Overview',
                summaryData: [
                  MapEntry('Planting Season', gardenData.season),
                  MapEntry('Initial Planting Date', gardenData.plantingDate),
                ],
                summaryActionText: 'Garden Compliance Report',
                onSummaryAction: () {
                  // e.g., navigate to report screen
                  Get.toNamed(Routes.GARDENCOMPLIANCEREPORT, arguments: garden);
                },
                listTitle: "Garden Species",
                items: gardenData.speciesData,
                itemBuilder: (context, data, index) => CustomListItem(
                  title: data['species'],
                  subtitle: "${data['planted']} trees planted",
                  trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                      color: Colors.black),
                  onTap: () async {
                    final speciesName = (data['species'] ?? '').toString();
                    final planted = int.tryParse("${data['planted']}") ?? 0;
                    final current = int.tryParse("${data['survival'] ?? ''}");

                    final updated = await showUpdateSurvivalDialog(
                      speciesName: speciesName,
                      planted: planted,
                      initialSurvival: current,
                    );

                    if (updated != null) {
                      // Update your data source and UI here
                      data['survival'] = updated;
                      // If using a controller/obs list, trigger refresh appropriately.
                      // Example:
                      // controller.updateSurvival(index, updated);
                      // or setState(() {});
                    }
                  },
                ),
              ),
      );
    });
  }
}

Future<int?> showUpdateSurvivalDialog({
  required String speciesName,
  required int planted,
  int? initialSurvival,
  String confirmText = 'Save',
  String cancelText = 'Cancel',
}) {
  final controller = TextEditingController(
    text: (initialSurvival ?? '').toString(),
  );

  String? errorText;

  void validateAndSave(void Function(void Function()) setState) {
    final raw = controller.text.trim();
    if (raw.isEmpty) {
      setState(() => errorText = 'Please enter a number.');
      return;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null) {
      setState(() => errorText = 'Enter a valid whole number.');
      return;
    }
    if (parsed < 0) {
      setState(() => errorText = 'Survival cannot be negative.');
      return;
    }
    if (parsed > planted) {
      setState(() => errorText = 'Survival cannot exceed planted ($planted).');
      return;
    }
    Get.back(result: parsed);
  }

  return Get.dialog<int?>(
    StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color: kijaniGreen.withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  Icons.nature,
                  color: kijaniGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Update Survival Count',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Context / instructions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(speciesName,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Enter the current number of surviving trees. '
                      'It must be between 0 and the total planted.',
                      style: GoogleFonts.roboto(
                        fontSize: 13.5,
                        height: 1.35,
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.local_florist,
                            size: 18,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text('Planted: $planted',
                            style: GoogleFonts.roboto(fontSize: 13.5)),
                        if (initialSurvival != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.favorite,
                              size: 18,
                              color:
                                  theme.colorScheme.primary.withOpacity(0.9)),
                          const SizedBox(width: 6),
                          Text('Current survival: $initialSurvival',
                              style: GoogleFonts.roboto(fontSize: 13.5)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Input
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Survival count',
                  hintText: '0 – $planted',
                  helperText: 'Use a whole number only',
                  errorText: errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.analytics_outlined),
                ),
                onSubmitted: (_) => validateAndSave(setState),
              ),

              const SizedBox(height: 8),

              // Quick +/- controls (optional nicety)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.outlined(
                    tooltip: 'Decrement',
                    onPressed: () {
                      final v = int.tryParse(controller.text) ?? 0;
                      if (v > 0) controller.text = '${v - 1}';
                      setState(() => errorText = null);
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    tooltip: 'Increment',
                    onPressed: () {
                      final v = int.tryParse(controller.text) ?? 0;
                      if (v < planted) controller.text = '${v + 1}';
                      setState(() => errorText = null);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: null),
              child: Text(cancelText),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  kijaniGreen,
                ),
                foregroundColor: WidgetStateProperty.all(
                  Colors.white,
                ),
              ),
              onPressed: () => validateAndSave(setState),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.save_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(confirmText),
                ],
              ),
            ),
          ],
        );
      },
    ),
    barrierDismissible: false,
  );
}
