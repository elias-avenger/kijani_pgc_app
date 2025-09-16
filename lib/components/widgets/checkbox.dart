import 'package:flutter/material.dart';

class MyCheckbox extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback? onTap;

  const MyCheckbox({
    super.key,
    required this.label,
    this.checked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(
                color: checked ? Colors.green : Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: checked
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: checked ? Colors.black : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
