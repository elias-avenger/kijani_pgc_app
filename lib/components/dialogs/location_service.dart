import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationSettingsDialog extends StatefulWidget {
  const LocationSettingsDialog({super.key});

  @override
  State<LocationSettingsDialog> createState() => _LocationSettingsDialogState();
}

class _LocationSettingsDialogState extends State<LocationSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Location Permission',
        style: GoogleFonts.roboto(color: Colors.green),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.12,
        child: const Column(
          children: [
            Text(
              'Location permissions are required to get your current location. Please enable location services in settings.',
            ),
            SizedBox(height: 10),
            Text(
              'Contact software@kijaniforestry.com for assistance',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Open Settings',
            style: TextStyle(color: Colors.green),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            await Geolocator.openAppSettings();
          },
        ),
      ],
    );
  }
}
