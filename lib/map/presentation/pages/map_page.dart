import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../data/office_location.dart';
import '../../data/overpass_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class MapPage extends StatefulWidget {
  final OfficeLocation? location;

  const MapPage({super.key, this.location});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _mapController;
  List<OfficeLocation> _nearbyOffices = [];
  bool _loadingOffices = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // If no specific office is requested, load nearby offices around the user's location
    if (widget.location == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final auth = context.read<AuthController>();
        double lat = 14.5995;
        double lng = 120.9842;
        if (auth.userProfile != null) {
          lat = (auth.userProfile!['lat'] as num?)?.toDouble() ?? lat;
          lng = (auth.userProfile!['lng'] as num?)?.toDouble() ?? lng;
        }

        // Try getting live position first, fall back to registered coords
        LatLng startPos = LatLng(lat, lng);
        try {
          final livePos = await _getUserLocation();
          if (livePos != null) {
            startPos = livePos;
            _mapController.move(livePos, 15);
          }
        } catch (_) {}

        _fetchNearbyGovernmentOffices(startPos);
      });
    }
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

  Future<void> _fetchNearbyGovernmentOffices(LatLng center) async {
    if (_loadingOffices) return;
    setState(() => _loadingOffices = true);

    try {
      final overpass = OverpassService();
      // Query government offices within 5000 meters
      final offices = await overpass.getNearbyOffices(
        userLat: center.latitude,
        userLon: center.longitude,
        radiusInMeters: 5000,
        tags: ['office=government', 'amenity=townhall', 'amenity=police'],
      );
      if (mounted) {
        setState(() {
          _nearbyOffices = offices;
        });
      }
    } catch (e) {
      debugPrint("Error fetching nearby government offices: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingOffices = false);
      }
    }
  }

  /// Reverse-geocode using OSM Nominatim
  Future<Map<String, dynamic>?> fetchPlaceDetails(LatLng coord) async {
    final url = Uri.https(
      "nominatim.openstreetmap.org",
      "/reverse",
      {
        "lat": coord.latitude.toString(),
        "lon": coord.longitude.toString(),
        "format": "json",
        "addressdetails": "1",
      },
    );

    final res = await http.get(url, headers: {"User-Agent": "FastLaneApp/1.0 (support@fastlane.com)"});
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
    return parts.join(", ");
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
    final auth = context.watch<AuthController>();
    double defaultLat = 14.5995;
    double defaultLng = 120.9842;
    if (auth.userProfile != null) {
      defaultLat = (auth.userProfile!['lat'] as num?)?.toDouble() ?? defaultLat;
      defaultLng = (auth.userProfile!['lng'] as num?)?.toDouble() ?? defaultLng;
    }

    final center = widget.location != null
        ? LatLng(widget.location!.latitude, widget.location!.longitude)
        : LatLng(defaultLat, defaultLng);

    // Philippines bounding box
    final philippinesBounds = LatLngBounds(
      const LatLng(4.225, 116.87),
      const LatLng(21.32, 126.60),
    );

    // Prepare markers
    final markers = <Marker>[];
    if (widget.location == null) {
      // User location marker
      markers.add(
        Marker(
          width: 50,
          height: 50,
          point: center,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 30,
          ),
        ),
      );

      // Office markers
      for (var office in _nearbyOffices) {
        markers.add(
          Marker(
            width: 80,
            height: 80,
            point: LatLng(office.latitude, office.longitude),
            child: GestureDetector(
              onTap: () async {
                final data = await fetchPlaceDetails(LatLng(office.latitude, office.longitude));
                if (data != null && mounted) {
                  showPlaceDetails(context, data);
                }
              },
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 36,
              ),
            ),
          ),
        );
      }
    } else {
      // Single specific office marker
      markers.add(
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
      );
    }

    final titleText = widget.location != null ? widget.location!.name : "Nearby Government Offices";

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: _loadingOffices
            ? [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
                    ),
                  ),
                )
              ]
            : null,
      ),
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
              MarkerLayer(markers: markers),
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
                  if (widget.location == null) {
                    _fetchNearbyGovernmentOffices(userPos);
                  }
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
