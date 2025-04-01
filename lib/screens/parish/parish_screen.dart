import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';

class ParishScreen extends StatefulWidget {
  const ParishScreen({super.key, required this.parish});
  final String parish;
  @override
  State<ParishScreen> createState() => _ParishScreenState();
}

class _ParishScreenState extends State<ParishScreen> {
  final UserController pmcCtrl = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'images/kijani_logo.png',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff23566d),
        title: Text(
          widget.parish.split(" | ").last,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                for (int i = 0; i < 5; i++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              const WidgetStatePropertyAll(Color(0xff23566d)),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          minimumSize:
                              const WidgetStatePropertyAll(Size(300, 60)),
                          maximumSize:
                              const WidgetStatePropertyAll(Size(300, 60)),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "202$i Group",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    backgroundColor: WidgetStatePropertyAll(Colors.grey[400]),
                    minimumSize: const WidgetStatePropertyAll(Size(200, 50)),
                    maximumSize: const WidgetStatePropertyAll(Size(200, 50)),
                  ),
                  onPressed: () {},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt,
                          size: 24, color: Color(0xff23566d)),
                      //Icon(Icons.add, color: Color(0xff23566d)),
                      Text(
                        'Add Group',
                        style:
                            TextStyle(color: Color(0xff23566d), fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
