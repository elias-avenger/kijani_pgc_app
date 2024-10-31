import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationServices {
  Future<Position> getCurrentLocation() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
    return await Geolocator.getCurrentPosition();
  }
}
