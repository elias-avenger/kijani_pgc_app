import 'package:geolocator/geolocator.dart';

class Locator {
  // Method to check permission
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    bool hasPermission = await checkPermission();
    if (!hasPermission) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      return position;
    } catch (e) {
      //print('LOCATOR ERROR: $e');
      return null;
    }
  }

  Future<Position?> getPosition() async {
    if (await checkPermission()) {
      Position? currentPosition = await _getCurrentPosition();
      return currentPosition;
    } else {
      return null;
    }
  }

  Future<Position?> _getCurrentPoint() async {
    try {
      await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation),
      );

      return position;
    } catch (e) {
      //print('LOCATOR EROOR: $e');
      return null;
    }
  }

  Future<String> getPointCoordinates() async {
    String locationString = "Failed";
    Position? currentPosition = await _getCurrentPoint();
    if (currentPosition != null) {
      locationString =
          '${currentPosition.latitude}, ${currentPosition.longitude}, ${currentPosition.accuracy}';
      //print("location: $locationString");
    }
    //await Future.delayed(const Duration(seconds: 2));
    //print("Precision: ${currentPosition?.accuracy}");
    return locationString;
  }
}
