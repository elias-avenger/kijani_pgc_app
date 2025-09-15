import 'package:get/get.dart';
import 'package:kijani_pgc_app/services/osrm_services.dart';

class MapController extends GetxController {
  //OSRM Services
  OSRMServices osrm = OSRMServices();

  var isLoadingRoute = false.obs;

  //fetch route for driving directions
}
