import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/components/widgets/my_date_input.dart';
import 'package:kijani_pgc_app/controllers/garden_compliance_report.dart';
import 'package:kijani_pgc_app/utilities/constants.dart';

class GardenComplianceSectionThree extends StatelessWidget {
  const GardenComplianceSectionThree({super.key});

  String _formatDate(DateTime d) {
    // yyyy-mm-dd without extra deps
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<GardenComplianceController>();

    return Form(
      key: c.section3FormKey, // ensure this exists in your controller
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date of Next follow up visit
          Obx(
            () => MyDateInput(
              label: 'Date of Next follow Up Visit',
              value: c.nextFollowUpDate.value.isEmpty
                  ? null
                  : c.nextFollowUpDate.value,
              placeholder: 'Pick the date for follow up',
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => (c.nextFollowUpDate.value.isEmpty)
                  ? 'Please select a date'
                  : null,
              onPick: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate:
                      DateTime(now.year, now.month, now.day), // today or later
                  lastDate: DateTime(now.year + 5),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        datePickerTheme: kPickerStyle,
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.black, // Button text color (Cancel/OK)
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  c.nextFollowUpDate.value = _formatDate(picked);
                }
                return picked;
              },
            ),
          ),
          const SizedBox(height: 24),

          // Comments (textarea)
          const Text('General Comments on the garden',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Obx(() => TextFormField(
                initialValue: c.comments.value,
                maxLines: 6,
                onChanged: (v) => c.comments.value = v,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please add a comment'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Write your comments…',
                  alignLabelWithHint: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
          // Note: The "Submit Report" button is already in your entry point as the main PrimaryButton.
        ],
      ),
    );
  }
}
