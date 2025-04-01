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
