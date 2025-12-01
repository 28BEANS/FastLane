// pages/map_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/office_location.dart';

class MapPage extends StatelessWidget {
  final OfficeLocation location;

  const MapPage({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    // Initial camera position. LatLng uses latlong2 package.
    final center = LatLng(location.latitude, location.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 15.0, // Closer zoom
        ),
        children: [
          // 1. Tile Layer (OpenStreetMap default tiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.your_app_name', // Must be unique
          ),
          // 2. Marker Layer for the Pinned Location
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: center,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}