import 'package:latlong2/latlong.dart';

/// GetX arguments object for the reusable map.
/// We don't assume any fields on your Gardens model — supply extractors.
class RouteMapArgs<TGarden> {
  final List<TGarden> gardens;

  /// Extractors from your Gardens model (required)
  final List<LatLng> Function(TGarden) polygonOf;
  final LatLng Function(TGarden) centerOf;
  final String Function(TGarden) nameOf;

  /// Optional initial origin/destination for auto-routing (if desired)
  final LatLng? start;
  final LatLng? end;
  final List<LatLng> via;

  /// OSRM geometries
  final String geometries; // 'polyline6' or 'geojson'

  /// Screen title
  final String title;

  /// If true and start+end present, auto-fetch on load
  final bool autoFetch;

  RouteMapArgs({
    required this.gardens,
    required this.polygonOf,
    required this.centerOf,
    required this.nameOf,
    this.start,
    this.end,
    this.via = const [],
    this.geometries = 'polyline6',
    this.title = 'Gardens & Routes',
    this.autoFetch = false,
  });
}
