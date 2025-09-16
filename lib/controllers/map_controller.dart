import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:kijani_pgc_app/utilities/keys.dart';
import 'package:latlong2/latlong.dart';
import 'package:kijani_pgc_app/services/osrm_services.dart'; // <-- update if needed

/// Basemaps controlled in the controller (as requested)
enum Basemap { osm, mapboxSatellite }

class MapController extends GetxController {
  // --- Map state ---
  final fm.MapController map = fm.MapController();
  final Rx<Basemap> basemap = Basemap.osm.obs;

  // Mapbox credentials/state from controller
  late final accessToken = mapboxAccessToken;
  final RxString mapboxStyleId =
      'mapbox/satellite-v9'.obs; // change from outside if you want

  // --- Routing state ---
  final OSRMServices _osrm = OSRMServices();
  final RxBool isLoadingRoute = false.obs;
  final RxnString error = RxnString();

  // decoded geometry
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  // human-readable step texts
  final RxList<String> routeSteps = <String>[].obs;
  // snapped OSRM waypoints
  final RxList<LatLng> snappedWaypoints = <LatLng>[].obs;

  // topline UI texts
  final RxString distanceText = ''.obs;
  final RxString etaText = ''.obs;

  // Configure from outside (e.g., before pushing the page)
  void setMapboxStyle(String styleId) => mapboxStyleId.value = styleId;
  void setBasemap(Basemap value) => basemap.value = value;

  /// Reset bearing to NORTH (0°)
  void resetNorth() {
    // flutter_map supports rotation via controller
    map.rotate(0);
  }

  /// Fetch a driving route and populate observables
  Future<void> fetchRouteDriving({
    required LatLng start,
    required LatLng end,
    List<LatLng> via = const [],
    String geometries = 'polyline6',
  }) async {
    isLoadingRoute.value = true;
    error.value = null;
    try {
      final res = await _osrm.getRoute(
        start: start,
        end: end,
        via: via,
        profile: 'driving',
        geometries: geometries,
        steps: true,
      );

      routePoints.assignAll(res.points);
      routeSteps.assignAll(res.steps.map((s) => s.text));
      snappedWaypoints.assignAll(res.snappedWaypoints);
      distanceText.value = res.distanceText;
      etaText.value = res.etaText;

      // Fit to route automatically
      final b = currentBounds();
      if (b != null) {
        map.fitCamera(
          fm.CameraFit.bounds(bounds: b, padding: const EdgeInsets.all(60)),
        );
      }
    } catch (e) {
      error.value = e.toString();
      routePoints.clear();
      routeSteps.clear();
      snappedWaypoints.clear();
      distanceText.value = '';
      etaText.value = '';
    } finally {
      isLoadingRoute.value = false;
    }
  }

  /// Bounds for current polyline (for camera fit)
  fm.LatLngBounds? currentBounds() {
    if (routePoints.isEmpty) return null;
    return fm.LatLngBounds.fromPoints(routePoints);
  }

  void clearRoute() {
    routePoints.clear();
    routeSteps.clear();
    snappedWaypoints.clear();
    distanceText.value = '';
    etaText.value = '';
    error.value = null;
  }

  @override
  void onClose() {
    _osrm.dispose();
    super.onClose();
  }
}
