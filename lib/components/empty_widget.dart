import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyDataScreen extends StatelessWidget {
  const EmptyDataScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Light peach background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image or illustration
            Container(
              height: 160,
              width: 160,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/empty_folder.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main text
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confirm You are Online and Try Again',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: Get.height * 0.1),

            // Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Get.back();
              },
              child: const Text('GoBack'),
            ),
          ],
        ),
      ),
    );
  }
}
