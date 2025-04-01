import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kijani_pmc_app/utilities/exif_utils.dart';

class ImagePickerBrain {
  final ImagePicker _imagePicker = ImagePicker();

  // Take a single picture with the camera and handle EXIF location
  Future<XFile?> takePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 90,
      );

      if (image != null) {
        bool hasLocation = await ExifUtils.checkIfImageHasLocation(image.path);
        if (!hasLocation) {
          await ExifUtils.addLocationToImage(image.path);
        }
      }

      return image;
    } catch (e) {
      if (kDebugMode) print('Error taking picture: $e');
      return null;
    }
  }

  // Pick multiple images and handle EXIF location
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (images != null) {
        for (XFile image in images) {
          bool hasLocation =
              await ExifUtils.checkIfImageHasLocation(image.path);
          if (!hasLocation) {
            print('No Locations found, adding location to image');
            await ExifUtils.addLocationToImage(image.path);
          }
        }
      }

      return images ?? <XFile>[];
    } catch (e) {
      if (kDebugMode) print('Error picking multiple images: $e');
      return [];
    }
  }
}
