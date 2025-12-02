import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

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

  /// Reverse-geocode using OSM Nominatim
  Future<Map<String, dynamic>?> fetchPlaceDetails(LatLng coord) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse"
      "?lat=${coord.latitude}&lon=${coord.longitude}"
      "&format=json&addressdetails=1"
    );

    final res = await http.get(url, headers: {"User-Agent": "your_app_name"});
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  /// Format OSM address JSON to human-readable string
  String formatAddress(Map<String, dynamic> address) {
    final fields = [
      "office",
      "road",
      "quarter",
      "village",
      "city",
      "region",
      "postcode",
      "country",
    ];

    List<String> parts = [];
    for (var field in fields) {
      if (address[field] != null && address[field].toString().isNotEmpty) {
        parts.add(address[field]);
      }
    }
    return parts.join(", "); // or use "\n" for multi-line
  }

  /// Display bottom sheet with place details
  void showPlaceDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  data["display_name"] ?? "Unknown place",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (data["type"] != null)
                  Text("Type: ${data["type"]}"),

                if (data["address"] != null) ...[
                  const SizedBox(height: 12),
                  const Text("Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(formatAddress(Map<String, dynamic>.from(data["address"]))),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.location.latitude, widget.location.longitude);

    // Philippines bounding box
    final philippinesBounds = LatLngBounds(
      const LatLng(4.225, 116.87),
      const LatLng(21.32, 126.60),
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
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              cameraConstraint: CameraConstraint.contain(bounds: philippinesBounds),
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
                    child: GestureDetector(
                      onTap: () async {
                        final data = await fetchPlaceDetails(center);
                        if (data != null && mounted) {
                          showPlaceDetails(context, data);
                        }
                      },
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ---- ZOOM IN ----
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

          // ---- ZOOM OUT ----
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

          // ---- GPS BUTTON ----
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

          // ---- COMPASS RESET ----
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: "compass_reset",
              mini: true,
              onPressed: () {
                _mapController.rotate(0);
              },
              child: const Icon(Icons.explore),
            ),
          ),
        ],
      ),
    );
  }
}
