import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

/// Human-readable turn-by-turn step
class StepInstruction {
  final String type; // e.g., "turn", "depart", "arrive"
  final String modifier; // e.g., "left", "right"
  final String name; // street name
  final double distance; // meters
  final double duration; // seconds

  const StepInstruction({
    required this.type,
    required this.modifier,
    required this.name,
    required this.distance,
    required this.duration,
  });

  String get text {
    final capType = type.isEmpty
        ? ''
        : type[0].toUpperCase() + type.substring(1).replaceAll('_', ' ');
    final mod = modifier.isNotEmpty ? ' $modifier' : '';
    final street = name.isNotEmpty ? ' onto $name' : '';
    final dist = distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(1)} km'
        : '${distance.toStringAsFixed(0)} m';
    final mins = (duration / 60).round();
    final eta = mins < 60
        ? '$mins min'
        : '${mins ~/ 60} h ${(mins % 60).toString().padLeft(2, '0')} min';
    return '$capType$mod$street • $dist • $eta';
  }
}

/// Parsed route result (single best route)
class OsrmRouteResult {
  final double distanceMeters;
  final double durationSeconds;
  final String weightName; // e.g., "routability"
  final String summary; // roads summary
  final List<LatLng> points; // decoded geometry
  final List<LatLng> snappedWaypoints; // snapped start/end (and via) points
  final List<StepInstruction> steps;
  final Map<String, dynamic> raw; // full OSRM JSON (if you need more)
  final String requestUri; // helpful for debugging

  const OsrmRouteResult({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.weightName,
    required this.summary,
    required this.points,
    required this.snappedWaypoints,
    required this.steps,
    required this.raw,
    required this.requestUri,
  });

  String get distanceText => distanceMeters >= 1000
      ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
      : '${distanceMeters.toStringAsFixed(0)} m';

  String get etaText {
    final m = (durationSeconds / 60).round();
    return m < 60
        ? '$m min'
        : '${m ~/ 60} h ${(m % 60).toString().padLeft(2, '0')} min';
  }
}

class OsrmException implements Exception {
  final String message;
  OsrmException(this.message);
  @override
  String toString() => 'OsrmException: $message';
}

/// OSRM Route API client (Pusher-agnostic, works with public or self-hosted OSRM)
class OSRMServices {
  /// Public demo; replace with your self-hosted base (HTTPS) in production.
  final String baseUrl;
  final http.Client _client;

  OSRMServices({
    this.baseUrl = 'https://router.project-osrm.org',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Request a route from [start] -> (via...) -> [end].
  ///
  /// [profile]: 'driving' (public OSRM), 'car' (common self-host), 'foot', 'bike'
  /// [geometries]: 'polyline6' (default) or 'geojson'
  /// [polylinePrecision]: when using polyline; 6 for polyline6, 5 for polyline
  Future<OsrmRouteResult> getRoute({
    required LatLng start,
    required LatLng end,
    List<LatLng> via = const [],
    String profile = 'driving',
    bool steps = true,
    bool alternatives = false,
    String geometries = 'polyline6',
    int? polylinePrecision, // auto-derive from 'geometries' if null
    String overview = 'full',
    List<String> annotations = const ['distance', 'duration'],
    Map<String, String>?
        headers, // if your OSRM sits behind a proxy requiring headers
    Duration timeout = const Duration(seconds: 20),
  }) async {
    // Build coordinates string in lon,lat order (OSRM requirement)
    final coords = <LatLng>[start, ...via, end];
    final coordStr =
        coords.map((c) => '${c.longitude},${c.latitude}').join(';');

    // Query params
    final qp = <String, String>{
      'overview': overview,
      'geometries': geometries,
      if (steps) 'steps': 'true',
      if (alternatives) 'alternatives': 'true',
      if (annotations.isNotEmpty) 'annotations': annotations.join(','),
    };

    final uri = Uri.parse('$baseUrl/route/v1/$profile/$coordStr')
        .replace(queryParameters: qp);
    final res = await _client.get(uri, headers: headers).timeout(timeout);

    if (res.statusCode != 200) {
      throw OsrmException('OSRM HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['code'] != 'Ok') {
      throw OsrmException('OSRM error: ${data['code']}');
    }

    final routes = (data['routes'] as List);
    if (routes.isEmpty) throw OsrmException('No routes found');

    final r = routes.first as Map<String, dynamic>;
    final distance = (r['distance'] as num).toDouble();
    final duration = (r['duration'] as num).toDouble();
    final weightName = (r['weight_name'] ?? '').toString();

    // Summary from first leg (often helpful UI text)
    String summary = '';
    if (r['legs'] is List && (r['legs'] as List).isNotEmpty) {
      final firstLeg = (r['legs'] as List).first as Map<String, dynamic>;
      summary = (firstLeg['summary'] ?? '').toString();
    }

    // Decode geometry -> List<LatLng>
    final List<LatLng> points;
    if (geometries == 'geojson') {
      final coordsJson = (r['geometry']['coordinates'] as List);
      points = coordsJson
          .map<LatLng>(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    } else {
      // polyline* (default polyline6)
      final polyStr = (r['geometry'] as String);
      final exp = polylinePrecision ??
          (geometries.toLowerCase().endsWith('6')
              ? 6
              : 5); // 'polyline6' -> 6, 'polyline' -> 5
      final decoded = decodePolyline(polyStr, accuracyExponent: exp);
      points = decoded
          .map(
              (p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
          .toList();
    }

    // Steps
    final stepList = <StepInstruction>[];
    if (steps && r['legs'] is List) {
      for (final leg in (r['legs'] as List)) {
        for (final s in ((leg as Map<String, dynamic>)['steps'] as List)) {
          final man = (s['maneuver'] ?? {}) as Map<String, dynamic>;
          stepList.add(StepInstruction(
            type: '${man['type'] ?? ''}',
            modifier: '${man['modifier'] ?? ''}',
            name: '${s['name'] ?? ''}',
            distance: ((s['distance'] as num?) ?? 0).toDouble(),
            duration: ((s['duration'] as num?) ?? 0).toDouble(),
          ));
        }
      }
    }

    // Snapped waypoints (OSRM returns [lon,lat] -> convert)
    final snapped = <LatLng>[];
    if (data['waypoints'] is List) {
      for (final w in (data['waypoints'] as List)) {
        final loc = (w as Map<String, dynamic>)['location'] as List;
        snapped.add(
            LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble()));
      }
    }

    return OsrmRouteResult(
      distanceMeters: distance,
      durationSeconds: duration,
      weightName: weightName,
      summary: summary,
      points: points,
      snappedWaypoints: snapped,
      steps: stepList,
      raw: data,
      requestUri: uri.toString(),
    );
  }

  // Convenience wrappers
  Future<OsrmRouteResult> driving({
    required LatLng start,
    required LatLng end,
    List<LatLng> via = const [],
    bool steps = true,
    String geometries = 'polyline6',
  }) {
    return getRoute(
      start: start,
      end: end,
      via: via,
      profile: 'driving',
      steps: steps,
      geometries: geometries,
    );
  }

  Future<OsrmRouteResult> walking({
    required LatLng start,
    required LatLng end,
    List<LatLng> via = const [],
    bool steps = true,
    String geometries = 'polyline6',
  }) {
    return getRoute(
      start: start,
      end: end,
      via: via,
      profile: 'foot',
      steps: steps,
      geometries: geometries,
    );
  }

  Future<OsrmRouteResult> cycling({
    required LatLng start,
    required LatLng end,
    List<LatLng> via = const [],
    bool steps = true,
    String geometries = 'polyline6',
  }) {
    return getRoute(
      start: start,
      end: end,
      via: via,
      profile: 'bike',
      steps: steps,
      geometries: geometries,
    );
  }

  void dispose() => _client.close();
}
