// lib/utilities/exif_utils.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kijani_pgc_app/services/location.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';

class ExifUtils {
  Locator locator = Locator();

  static Future<bool> checkIfImageHasLocation(String imagePath) async {
    try {
      Exif exif = await Exif.fromPath(imagePath);

      ExifLatLong? latLong = await exif.getLatLong();

      await exif.close();
      return latLong != null;
    } catch (e) {
      if (kDebugMode) print('Error reading EXIF data: $e');
      return false;
    }
  }

  static Future<void> addLocationToImage(
    String imagePath,
  ) async {
    try {
      //call geolocator to get the current location
      Position? position = await Locator().getPosition();

      if (position == null) {
        if (kDebugMode) print('Location not available');
        return;
      }
      Exif exif = await Exif.fromPath(imagePath);
      await exif.writeAttributes({
        'GPSLatitude': position.latitude.abs().toString(),
        'GPSLatitudeRef': position.latitude >= 0 ? 'N' : 'S',
        'GPSLongitude': position.longitude.abs().toString(),
        'GPSLongitudeRef': position.longitude >= 0 ? 'E' : 'W',
      });

      // Use path_provider to get the documents directory
      Directory dir = await getApplicationDocumentsDirectory();
      // Manually construct the path without 'path' package
      String newPath = '${dir.path}/temp_for_exif.jpg';
      File newFile = File(newPath);
      await newFile.writeAsBytes(await File(imagePath).readAsBytes());

      Exif newExif = await Exif.fromPath(newPath);
      ExifLatLong? latLong = await newExif.getLatLong();
      await newExif.close();

      await exif.close();
    } catch (e) {
      if (kDebugMode) print('Error writing EXIF data: $e');
    }
  }
}
