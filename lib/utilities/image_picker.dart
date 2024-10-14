import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBrain {
  ImagePicker imagePicker = ImagePicker();

  // Take picture with camera
  Future<XFile?> takePicture(BuildContext context) async {
    try {
      //Uint8List? modifiedImage;

      final image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 90,
      );

      if (image != null) {
        // Uint8List bytes = await image.readAsBytes();
        // FlutterExif exif = FlutterExif.fromBytes(bytes);
        // final latlon = await exif.getLatLong();

        // if (latlon == null) {
        //   String location = await Locator().getPosition();
        //
        //   if (location != 'Permission Denied') {
        //     List latLong = location.split(", ");
        //     double latitude = double.parse(latLong[0]);
        //     double longitude = double.parse(latLong[1]);
        //     await exif.setLatLong(latitude, longitude);
        //     await exif.saveAttributes();
        //     modifiedImage = await exif.imageData;
        //
        //     // Overwrite the original image file with the modified image
        //     final tempFile = File(image.path);
        //     await tempFile.writeAsBytes(modifiedImage!);
        //
        //     // Return the modified image as an XFile
        //     return XFile(tempFile.path);
        //   } else {
        //     // Show location permission dialog
        //     if (kDebugMode) print('Location service disabled');
        //     _showLocationPermissionDialog(context);
        //   }
        // } else {
        //   if (kDebugMode) {
        //     print("!!!!!!!! LATLONG recorded : $latlon !!!!!!!!!!");
        //   }
        // }
      }
      return image;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      return null;
    }
  }

  // void _showLocationPermissionDialog(BuildContext context) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return const LocationSettingsDialog();
  //       },
  //     );
  //   });
  // }
}
