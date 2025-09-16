// section_one.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/components/widgets/checkbox.dart';
import 'package:kijani_pgc_app/components/widgets/file_upload_field.dart';
import 'package:kijani_pgc_app/components/widgets/my_text_input.dart';
import 'package:kijani_pgc_app/controllers/garden_compliance_report.dart';

class GardenComplianceSectionOne extends StatelessWidget {
  const GardenComplianceSectionOne({super.key});

  String? _requiredNumber(String? v, {bool allowZero = true}) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (!allowZero && n <= 0) return 'Must be greater than 0';
    if (allowZero && n < 0) return 'Must be ≥ 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GardenComplianceController>();

    return Form(
      key: c.section1FormKey, // 🔑 attach the key
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Compliance Status of the Garden',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Obx(() => MyCheckbox(
                label: 'Weeded',
                checked: c.weeded.value,
                onTap: () => c.weeded.value = !c.weeded.value,
              )),
          const SizedBox(height: 12),

          Obx(() => MyCheckbox(
                label: 'Gap Filling done (As needed)',
                checked: c.gapfilling.value,
                onTap: () => c.gapfilling.value = !c.gapfilling.value,
              )),
          const SizedBox(height: 12),

          Obx(() => MyCheckbox(
                label: 'Singling done (As needed)',
                checked: c.singling.value,
                onTap: () => c.singling.value = !c.singling.value,
              )),

          const SizedBox(height: 24),

          // Photo is required -> validate with a FormField wrapper
          FormField<List<String>>(
            initialValue: c.gardenPhotos.toList(),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Please upload the garden photo.'
                : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImagePickerWidget(
                  onImagesSelected: (values) {
                    c.gardenPhotos.value = values;
                    field.didChange(values); // ✅ notify form
                  },
                  label: "Garden Photo",
                  hintText: "Upload the garden photo",
                  maxImages: 1,
                ),
                if (field.errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 8),
                    child: Text(field.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12.5,
                        )),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text("Tree Planting status",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Trees by farmer
          MyTextInput(
            label: "Number of trees planted as reported by the farmer",
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => _requiredNumber(v, allowZero: true),
            onChanged: (v) => c.treesByFarmer.value = v,
          ),
          const SizedBox(height: 12),

          // Trees by PGC
          MyTextInput(
            label: "Number of trees planted as counted by PGC",
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => _requiredNumber(v, allowZero: true),
            onChanged: (v) => c.treesByPGC.value = v,
          ),
        ],
      ),
    );
  }
}
