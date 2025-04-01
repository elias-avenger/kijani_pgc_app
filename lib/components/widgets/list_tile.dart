import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String? subtitle; // Optional subtitle (e.g., "08 Farmers")
  final IconData icon;
  final Widget? trailing; // Optional trailing widget
  final VoidCallback? onTap;

  const CustomListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = HugeIcons.strokeRoundedLocation03, // Default icon
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300), // Subtle border
        ),
        child: Row(
          spacing: 16,
          children: [
            Icon(icon, color: Colors.black54, size: 24), // Leading Icon

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!, // Custom trailing widget
          ],
        ),
      ),
    );
  }
}
