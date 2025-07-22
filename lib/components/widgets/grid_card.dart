// **📌 Reusable Grid Card Widget**
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget gridCard(String title, int count, IconData? icon, Color color) {
  return Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    // padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: Get.width * 0.05,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 30),
              Text(
                "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget gridCardSkeleton() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title skeleton
        Container(
          height: 20,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon skeleton
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: Get.width * 0.05),
            // Count skeleton
            Container(
              height: 28,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
