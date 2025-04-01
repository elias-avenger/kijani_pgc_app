import 'package:flutter/material.dart';

class TextAreaWidget extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const TextAreaWidget({
    super.key,
    required this.label,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
