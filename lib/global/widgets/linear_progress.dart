import 'package:flutter/material.dart';
import 'package:kijani_pmc_app/global/enums/colors.dart';

class UpdatingProgressIndicator extends StatefulWidget {
  const UpdatingProgressIndicator({super.key});

  @override
  UpdatingProgressIndicatorState createState() =>
      UpdatingProgressIndicatorState();
}

class UpdatingProgressIndicatorState extends State<UpdatingProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: kfGreen.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            "Updating Data",
            style: TextStyle(
              fontSize: 14,
              color: kfGreen,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _controller.value,
            minHeight: 8.0,
            backgroundColor: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            valueColor: AlwaysStoppedAnimation<Color>(kfGreen),
            semanticsLabel: 'Updating data progress indicator',
          ),
        ],
      ),
    );
  }
}
