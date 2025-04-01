import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onConfirm;
  final String title;

  const MultiSelectDialog({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onConfirm,
    this.title = "Select Options",
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> _tempSelected = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedOptions);
    _filteredOptions = List.from(widget.options);
  }

  void _filterOptions(String query) {
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedCancelCircle,
                      color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(HugeIcons.strokeRoundedSearch02),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onChanged: _filterOptions,
            ),
          ),

          // Multi-Select List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredOptions.length,
              itemBuilder: (context, index) {
                String option = _filteredOptions[index];
                bool isSelected = _tempSelected.contains(option);
                return CheckboxListTile(
                  activeColor: Colors.green,
                  title: Text(
                    option,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _tempSelected.add(option);
                      } else {
                        _tempSelected.remove(option);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () {
                widget.onConfirm(_tempSelected);
                Get.back();
              },
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
