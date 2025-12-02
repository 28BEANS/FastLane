import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/office_location.dart';

class MapPage extends StatefulWidget {
  final OfficeLocation location;

  const MapPage({super.key, required this.location});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  /// Request GPS permission and return user location
  Future<LatLng?> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    Position pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.location.latitude, widget.location.longitude);

    // Philippines bounding box (approx)
    final philippinesBounds = LatLngBounds(
      const LatLng(4.225, 116.87),  // Southwest boundary
      const LatLng(21.32, 126.60),  // Northeast boundary
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.location.name)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              minZoom: 4,
              maxZoom: 19,

              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),

              // Restrict map to Philippines
              cameraConstraint: CameraConstraint.contain(
                bounds: philippinesBounds,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.your_app_name',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    width: 80,
                    height: 80,
                    point: center,
                    child: const Icon(Icons.location_pin,
                        color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // ---- ZOOM IN BUTTON ----
          Positioned(
            bottom: 110,
            right: 10,
            child: FloatingActionButton(
              heroTag: "zoom_in",
              mini: true,
              onPressed: () {
                final zoom = _mapController.camera.zoom + 1;
                _mapController.move(_mapController.camera.center, zoom);
              },
              child: const Icon(Icons.add),
            ),
          ),

          // ---- ZOOM OUT BUTTON ----
          Positioned(
            bottom: 60,
            right: 10,
            child: FloatingActionButton(
              heroTag: "zoom_out",
              mini: true,
              onPressed: () {
                final zoom = _mapController.camera.zoom - 1;
                _mapController.move(_mapController.camera.center, zoom);
              },
              child: const Icon(Icons.remove),
            ),
          ),

          // ---- CENTER ON USER LOCATION ----
          Positioned(
            bottom: 160,
            right: 10,
            child: FloatingActionButton(
              heroTag: "gps",
              mini: true,
              onPressed: () async {
                final userPos = await _getUserLocation();
                if (userPos != null) {
                  _mapController.move(userPos, 17);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // ---- COMPASS RESET (RESET ROTATION) ----
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: "compass_reset",
              mini: true,
              onPressed: () {
                _mapController.rotate(0); // reset rotation to normal north-up
              },
              child: const Icon(Icons.explore),
            ),
          ),
        ],
      ),
    );
  }
}
