import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kijani_pmc_app/global/services/location_services.dart';
import 'package:native_exif/native_exif.dart';

class ImageServices {
  // Method to pick a single image from gallery or camera
  Future<String> pickImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: source);

    if (image == null) {
      print('No image selected');
      return '';
    }
    String imagePath = image.path;

    // Check if the image has location data
    bool hasLocation = await _checkIfImageHasLocation(imagePath);

    if (!hasLocation) {
      Position currentLocation = await LocationServices().getCurrentLocation();
      await _addLocationToImage(imagePath, currentLocation);
    }
    return imagePath;
  }

  // Method to pick multiple images from the gallery
  Future<List<String>> pickMultipleImages() async {
    ImagePicker imagePicker = ImagePicker();
    List<XFile>? images = await imagePicker.pickMultiImage();

    if (images == null || images.isEmpty) {
      print('No images selected');
      return [];
    }

    List<String> imagePaths = [];
    for (XFile image in images) {
      String imagePath = image.path;

      // Check if the image has location data
      bool hasLocation = await _checkIfImageHasLocation(imagePath);

      if (!hasLocation) {
        Position currentLocation =
            await LocationServices().getCurrentLocation();
        await _addLocationToImage(imagePath, currentLocation);
      }
      imagePaths.add(imagePath);
    }
    return imagePaths;
  }

  // Method to check if the image already has GPS location metadata
  Future<bool> _checkIfImageHasLocation(String imagePath) async {
    try {
      final Exif exif = await Exif.fromPath(imagePath);

      // Check for existing GPSLatitude and GPSLongitude
      String? latitude = await exif.getAttribute('GPSLatitude');
      String? longitude = await exif.getAttribute('GPSLongitude');

      await exif.close(); // Close Exif after usage

      // If both latitude and longitude exist, return true, otherwise false
      return latitude != null && longitude != null;
    } catch (e) {
      print('Error reading EXIF data: $e');
      return false;
    }
  }

  // Method to add GPS location to the image
  Future<void> _addLocationToImage(String imagePath, Position position) async {
    try {
      final Exif exif = await Exif.fromPath(imagePath);

      // Add the latitude and longitude to the image metadata
      await exif.writeAttributes({
        'GPSLatitude': position.latitude.toString(),
        'GPSLongitude': position.longitude.toString(),
        'GPSLatitudeRef': position.latitude >= 0 ? 'N' : 'S',
        'GPSLongitudeRef': position.longitude >= 0 ? 'E' : 'W',
      });

      await exif.close(); // Close Exif after writing
    } catch (e) {
      print('Error writing location data to image: $e');
    }
  }
}
