import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/components/widgets/dialogs/multiselect.dart';

class MultiSelectField extends StatelessWidget {
  final String label;
  final List<String> options;
  final RxList<String> selectedOptions;

  const MultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Get.dialog(
              MultiSelectDialog(
                title: label,
                options: options,
                selectedOptions: selectedOptions,
                onConfirm: (newSelection) {
                  selectedOptions.assignAll(newSelection);
                },
              ),
            );
          },
          child: Column(
            spacing: Get.height * 0.02,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Select options",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Obx(
                () => Wrap(
                  children: selectedOptions.map((option) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option,
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              selectedOptions.remove(option);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
