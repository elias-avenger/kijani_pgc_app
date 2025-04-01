import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModernDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const ModernDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  _ModernDropdownState createState() => _ModernDropdownState();
}

class _ModernDropdownState extends State<ModernDropdown> {
  String? _selectedValue;
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    _filteredItems = widget.items;
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
                  _filteredItems = widget.items
                      .where((item) =>
                          item.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  String item = _filteredItems[index];
                  return ListTile(
                    title: Text(item),
                    trailing: _selectedValue == item
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedValue = item;
                      });
                      widget.onChanged(item);
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
