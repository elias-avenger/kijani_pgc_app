import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map/flutter_map.dart';
import 'package:kijani_pgc_app/services/route_map_args.dart';
import 'package:latlong2/latlong.dart';

import 'package:kijani_pgc_app/controllers/map_controller.dart' as gc;

class ReusableRouteGardensMap<TGarden> extends StatefulWidget {
  const ReusableRouteGardensMap({super.key});

  @override
  State<ReusableRouteGardensMap<TGarden>> createState() =>
      _ReusableRouteGardensMapState<TGarden>();
}

class _ReusableRouteGardensMapState<TGarden>
    extends State<ReusableRouteGardensMap<TGarden>> {
  late final gc.MapController c;
  late final RouteMapArgs<TGarden> args;

  static const LatLng _fallbackCenter = LatLng(0.3476, 32.5825); // Kampala

  @override
  void initState() {
    super.initState();
    c = Get.put(gc.MapController(), permanent: true);
    args = Get.arguments;

    if (args.autoFetch && args.start != null && args.end != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        c.fetchRouteDriving(
          start: args.start!,
          end: args.end!,
          via: args.via,
          geometries: args.geometries,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = args.gardens.isNotEmpty
        ? args.centerOf(args.gardens.first)
        : (args.start ?? _fallbackCenter);

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
        actions: [
          // Basemap toggle controlled by controller state (as requested)
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SegmentedButton<gc.Basemap>(
                  segments: const [
                    ButtonSegment(label: Text('OSM'), value: gc.Basemap.osm),
                    ButtonSegment(
                        label: Text('Satellite'),
                        value: gc.Basemap.mapboxSatellite),
                  ],
                  selected: {c.basemap.value},
                  onSelectionChanged: (s) => c.setBasemap(s.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ),
              )),
          // Steps sheet
          Obx(() {
            final hasSteps = c.routeSteps.isNotEmpty;
            return IconButton(
              tooltip: 'Show steps',
              onPressed: hasSteps ? _showSteps : null,
              icon: const Icon(Icons.format_list_bulleted),
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            final pts = c.routePoints;
            final center = pts.isNotEmpty ? pts.first : initialCenter;

            return FlutterMap(
              mapController: c.map,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  // enable rotation so “Reset North” makes sense
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPos, latlng) => _handleMapTap(latlng),
              ),
              children: [
                // --- BASEMAPS (controlled from controller) ---
                Obx(() {
                  switch (c.basemap.value) {
                    case gc.Basemap.osm:
                      return TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName:
                            'com.kijani.pgc', // change to your app id
                      );
                    case gc.Basemap.mapboxSatellite:
                      final token = c.accessToken;
                      if (token.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/{styleId}/tiles/512/{z}/{x}/{y}@2x?access_token={accessToken}',
                        additionalOptions: {
                          'styleId': c.mapboxStyleId
                              .value, // e.g. 'mapbox/satellite-v9'
                          'accessToken': token,
                        },
                        userAgentPackageName: 'com.kijani.pgc',
                        tileProvider: NetworkTileProvider(),
                      );
                  }
                }),

                // Route polyline
                if (pts.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                          points: pts.toList(),
                          strokeWidth: 5,
                          color: Colors.blueAccent),
                    ],
                  ),

                // Garden polygons
                if (args.gardens.isNotEmpty)
                  PolygonLayer(
                    polygons: [
                      for (final g in args.gardens)
                        Polygon(
                          points: args.polygonOf(g),
                          color: const Color(0x334CAF50),
                          borderColor: const Color(0xFF2E7D32),
                          borderStrokeWidth: 2,
                          label: args.nameOf(g),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            backgroundColor: Color(0x66FFFFFF),
                          ),
                        ),
                    ],
                  ),

                // Markers (route endpoints + garden centers)
                MarkerLayer(
                  markers: [
                    ..._routeMarkers(),
                    ..._gardenCenterMarkers(context),
                  ],
                ),

                fm.RichAttributionWidget(
                  alignment: AttributionAlignment.bottomRight,
                  attributions: [
                    if (c.basemap.value == gc.Basemap.osm)
                      const fm.TextSourceAttribution(
                          '© OpenStreetMap contributors'),
                    if (c.basemap.value == gc.Basemap.mapboxSatellite)
                      const fm.TextSourceAttribution(
                          '© Mapbox © OpenStreetMap'),
                  ],
                ),
              ],
            );
          }),

          // Distance • ETA chip
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Obx(() {
              final dist = c.distanceText.value;
              final eta = c.etaText.value;
              final loading = c.isLoadingRoute.value;
              if (loading || (dist.isEmpty && eta.isEmpty))
                return const SizedBox.shrink();
              return Center(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('$dist • $eta',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }),
          ),

          // Error banner
          Obx(() {
            final err = c.error.value;
            if (err == null) return const SizedBox.shrink();
            return Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Card(
                color: Colors.black.withOpacity(.85),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(err, style: const TextStyle(color: Colors.white)),
                ),
              ),
            );
          }),
        ],
      ),

      // Actions
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'resetNorth',
            onPressed: c.resetNorth,
            icon: const Icon(Icons.explore), // compass-ish
            label: const Text('Reset North'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fit',
            onPressed: () {
              final b = c.currentBounds();
              if (b != null) {
                c.map.fitCamera(fm.CameraFit.bounds(
                    bounds: b, padding: const EdgeInsets.all(60)));
              }
            },
            icon: const Icon(Icons.fit_screen),
            label: const Text('Fit route'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'clear',
            backgroundColor: Colors.grey.shade800,
            onPressed: c.clearRoute,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // --- UI helpers ---

  List<Marker> _routeMarkers() {
    final pts = c.routePoints;
    LatLng? startMarker;
    LatLng? endMarker;

    if (c.snappedWaypoints.isNotEmpty) {
      startMarker = c.snappedWaypoints.first;
      endMarker = c.snappedWaypoints.last;
    } else if (pts.isNotEmpty) {
      startMarker = pts.first;
      endMarker = pts.last;
    }

    return [
      if (startMarker != null)
        Marker(
            point: startMarker,
            width: 40,
            height: 40,
            child:
                const Icon(Icons.location_on, color: Colors.green, size: 36)),
      if (endMarker != null)
        Marker(
            point: endMarker,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 36)),
    ];
  }

  List<Marker> _gardenCenterMarkers(BuildContext context) {
    return [
      for (final g in args.gardens)
        Marker(
          point: args.centerOf(g),
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _promptVisitGarden(g),
            child: const Icon(Icons.forest, color: Colors.teal, size: 32),
          ),
        ),
    ];
  }

  void _handleMapTap(LatLng tap) {
    for (final g in args.gardens) {
      if (_pointInPolygon(tap, args.polygonOf(g))) {
        _promptVisitGarden(g);
        return;
      }
    }
  }

  Future<void> _promptVisitGarden(TGarden g) async {
    final name = args.nameOf(g);
    final center = args.centerOf(g);

    final choice = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 12,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.park),
                title: Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                subtitle: const Text('Do you want to visit this garden?'),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Visit'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == true) {
      final origin = await _resolveOrigin();
      await c.fetchRouteDriving(
          start: origin, end: center, geometries: args.geometries);

      final b =
          c.currentBounds() ?? fm.LatLngBounds.fromPoints(args.polygonOf(g));
      c.map.fitCamera(
          fm.CameraFit.bounds(bounds: b, padding: const EdgeInsets.all(60)));
    }
  }

  Future<LatLng> _resolveOrigin() async {
    if (args.start != null) return args.start!;
    if (c.snappedWaypoints.isNotEmpty) return c.snappedWaypoints.first;
    return c.map.camera.center;
  }

  // Ray-casting PIP (lat=X, lon=Y consistently)
  bool _pointInPolygon(LatLng p, List<LatLng> poly) {
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i].latitude, yi = poly[i].longitude;
      final xj = poly[j].latitude, yj = poly[j].longitude;
      final bool intersect = ((yi > p.longitude) != (yj > p.longitude)) &&
          (p.latitude <
              (xj - xi) *
                      (p.longitude - yi) /
                      ((yj - yi) == 0 ? 1e-12 : (yj - yi)) +
                  xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  void _showSteps() {
    if (c.routeSteps.isEmpty) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: c.routeSteps.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (_, i) => Text('• ${c.routeSteps[i]}'),
      ),
    );
  }
}
