import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pgc_app/models/parish.dart';

class ParishDropdown extends StatefulWidget {
  final String label;
  final List<Parish> parishes;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const ParishDropdown({
    super.key,
    required this.label,
    required this.parishes,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  _ParishDropdownState createState() => _ParishDropdownState();
}

class _ParishDropdownState extends State<ParishDropdown> {
  String? _selectedValue;
  final TextEditingController _searchController = TextEditingController();
  List<Parish> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    _filteredItems = widget.parishes;
  }

  void _openDropdown() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const Text("Select Parish from the List",
                style: TextStyle(fontWeight: FontWeight.bold)),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (query) {
                setState(() {
                  _filteredItems = widget.parishes
                      .where((parish) => parish.name
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  Parish item = _filteredItems[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item.name} Parish",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          "[${item.id}]",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: _selectedValue == item.id
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedValue = item.id;
                      });
                      widget.onChanged(item.id);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDropdown,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedValue ?? widget.label,
              style: TextStyle(
                color: _selectedValue == null ? Colors.black54 : Colors.black,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
