import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/components/my_dropdown.dart';
import 'package:kijani_pgc_app/controllers/garden_compliance_report.dart';

class GardenComplianceSectionTwo extends StatelessWidget {
  const GardenComplianceSectionTwo({super.key});

  // Options (edit to your exact wording)
  List<String> get levels => const [
        'Less than 25%',
        'Between 25% - 50%',
        'Between 50% - 75%',
        'Between 75% - 100%',
        '100% completed'
      ];

  List<String> get spacinglevels => const [
        'Less than 25%',
        'Between 25% - 50%',
        'Between 50% - 75%',
        'Between 75% - 100%',
        '100% Spacing',
        'Not Applicable'
      ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GardenComplianceController>();

    return Form(
      key: c.section2FormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Weeding Compliance
          Obx(() => MyDropdown<String>(
                label: 'Weed Compliance',
                value: c.weedingCompliance.value.isEmpty
                    ? null
                    : c.weedingCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.weedingCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select weeding compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Planting Compliance
          Obx(() => MyDropdown<String>(
                label: 'Planting Compliance',
                value: c.plantingCompliance.value.isEmpty
                    ? null
                    : c.plantingCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.plantingCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select planting compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Gap-filling Compliance
          Obx(() => MyDropdown<String>(
                label: 'Gap-filling Compliance',
                value: c.gapFillingCompliance.value.isEmpty
                    ? null
                    : c.gapFillingCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.gapFillingCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select gap-filling compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Singling Compliance
          Obx(() => MyDropdown<String>(
                label: 'Singling Compliance',
                value: c.singlingCompliance.value.isEmpty
                    ? null
                    : c.singlingCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.singlingCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select singling compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Fire-lines Compliance
          Obx(() => MyDropdown<String>(
                label: 'Fire-lines Compliance',
                value: c.firelinesCompliance.value.isEmpty
                    ? null
                    : c.firelinesCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.firelinesCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select firelines compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Pruning Compliance
          Obx(() => MyDropdown<String>(
                label: 'Pruning Compliance',
                value: c.pruningCompliance.value.isEmpty
                    ? null
                    : c.pruningCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.pruningCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select pruning compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Debudding Compliance
          Obx(() => MyDropdown<String>(
                label: 'Debudding Compliance',
                value: c.debuddingCompliance.value.isEmpty
                    ? null
                    : c.debuddingCompliance.value,
                items: levels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.debuddingCompliance.value = v ?? '',
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please select debudding compliance'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          const Divider(height: 32),
          const Text(
            'Tree Spacing',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F7A49)),
          ),
          const SizedBox(height: 12),

          // Charcoal Spacing
          Obx(() => MyDropdown<String>(
                label: 'Charcoal Species (2x2)',
                value: c.charcoalSpeciesSpacing.value.isEmpty
                    ? null
                    : c.charcoalSpeciesSpacing.value,
                items: spacinglevels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.charcoalSpeciesSpacing.value = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please select the level' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),
          const SizedBox(height: 16),

          // Timber Spacing
          Obx(() => MyDropdown<String>(
                label: 'Timber Species (4x4)',
                value: c.timberSpeciesSpacing.value.isEmpty
                    ? null
                    : c.timberSpeciesSpacing.value,
                items: spacinglevels
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => c.timberSpeciesSpacing.value = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please select the level' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                placeholder: 'Please select the level',
              )),

          const SizedBox(height: 24),
          const Divider(height: 32),

          // Polypots left in the garden? (Yes/No)
          const Text(
            'Polypots left in the garden?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final val = c.polypotsCompliance.value; // '' | 'Yes' | 'No'
            return Row(
              children: [
                // Yes
                _RadioPill(
                  label: 'Yes',
                  selected: val == 'Yes',
                  onTap: () => c.polypotsCompliance.value = 'Yes',
                ),
                const SizedBox(width: 24),
                // No
                _RadioPill(
                  label: 'No',
                  selected: val == 'No',
                  onTap: () => c.polypotsCompliance.value = 'No',
                ),
              ],
            );
          }),
          const SizedBox(height: 6),
          // Tiny validation message for Yes/No
          Obx(() => (c.polypotsCompliance.value.isEmpty)
              ? const Padding(
                  padding: EdgeInsets.only(left: 8, top: 2),
                  child: Text('Please select Yes or No',
                      style: TextStyle(color: Colors.red, fontSize: 12.5)),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// Small pill-style radio
class _RadioPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF1F7A49) : Colors.grey.shade400;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1F7A49),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
