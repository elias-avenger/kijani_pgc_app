import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kijani_pmc_app/screens/garden/register_garden.dart';

class GroupDashBoard extends StatefulWidget {
  const GroupDashBoard({super.key});

  @override
  State<GroupDashBoard> createState() => _GroupDashBoardState();
}

class _GroupDashBoardState extends State<GroupDashBoard> {
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
        title: const Text(
          'Hello World',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Hello world'),
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
                      onPressed: () {
                        Get.to(() => const GroupDashBoard());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "farmer $i",
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
              TextButton(
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(Colors.black),
                  foregroundColor: const WidgetStatePropertyAll(Colors.white),
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(20)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                onPressed: () {
                  Get.to(() => const NewGardenForm());
                },
                child: const Text('Add new Garden'),
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}
