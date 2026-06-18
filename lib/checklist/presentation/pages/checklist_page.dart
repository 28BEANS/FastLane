import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/checklist_controller.dart';

import '../../../map/data/overpass_service.dart';
import '../../../map/data/office_location.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  LatLng? _deviceLocation;

  // Request GPS permission and fetch user location
  Future<LatLng?> _getUserLocation() async {
    if (_deviceLocation != null) return _deviceLocation;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      Position pos = await Geolocator.getCurrentPosition();
      _deviceLocation = LatLng(pos.latitude, pos.longitude);
      return _deviceLocation;
    } catch (_) {
      return null;
    }
  }

  // Show the results modal
  void _showOfficeLocationsModal(
    BuildContext context,
    String requirementLabel,
    List<OfficeLocation> locations,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Offices for "$requirementLabel"',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: locations.isEmpty
                      ? const Center(
                          child: Text("No nearby offices found."),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final office = locations[index];
                            return ListTile(
                              title: Text(office.name),
                              subtitle: Text(office.address),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal),
                                onPressed: () {
                                  // Navigate to the map page
                                  Navigator.pop(ctx); // Close the modal first
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapPage(
                                        location: office,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Show in Maps"),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper function to map requirement label to Overpass Tag (REVISED)
  List<String> _getQueryTagsForLabel(String label) {
    final l = label.toLowerCase();

    // LTO / ADL / Driver's License
    if (l.contains('adl') || l.contains('lto') || l.contains('license') || l.contains('permit')) {
      return ['office=government']; // LTO offices in PH
    }

    // Driving Schools / Student Permit
    if (l.contains('course') || l.contains('practical') || l.contains('tdc') || l.contains('student permit')) {
      return ['amenity=driving_school'];
    }

    // Medical
    if (l.contains('medical') || l.contains('health')) return ['amenity=clinic'];
    if (l.contains('hospital') || l.contains('emergency')) return ['amenity=hospital'];

    // Government ID / Clearance
    if (l.contains('id') || l.contains('clearance') || l.contains('city hall') || l.contains('government')) {
      return ['office=government', 'amenity=police'];
    }

    // Education
    if (l.contains('school') || l.contains('transcript')) return ['amenity=school'];

    // Fallback
    return ['office=government'];
  }

  @override
  Widget build(BuildContext context) {
    const double searchRadius = 5000;
    final overpassService = OverpassService(); // Initialize service

    return Consumer<ChecklistController>(
      builder: (context, controller, child) {
        final tasks = controller.tasks;

        if (tasks.isEmpty) {
          return const Center(child: Text("No tasks yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final progressPercentage = (task.progress * 100).toInt();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.taskName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: task.progress,
                            backgroundColor: Colors.grey.shade300,
                            color: Colors.blue,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("$progressPercentage%"),
                      ],
                    ),
                  ],
                ),
                children: task.items.map((item) {
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.done ? Colors.green : Colors.transparent,
                        border: Border.all(
                            color: item.done ? Colors.green : Colors.grey),
                      ),
                      child: item.done
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                    title: Text(item.label),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- "Where to get button" ---
                        ElevatedButton.icon(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Searching for nearby offices...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            final tags = _getQueryTagsForLabel(item.label);

                            // Resolve user location dynamically:
                            // 1. Try GPS location
                            // 2. Try registered Firestore address coords
                            // 3. Fall back to Manila coordinates
                            final auth = context.read<AuthController>();
                            double userLat = 15.1373919;
                            double userLon = 120.5903763;

                            final gpsCoords = await _getUserLocation();
                            if (gpsCoords != null) {
                              userLat = gpsCoords.latitude;
                              userLon = gpsCoords.longitude;
                            } else if (auth.userProfile != null) {
                              userLat = (auth.userProfile!['lat'] as num?)?.toDouble() ?? userLat;
                              userLon = (auth.userProfile!['lng'] as num?)?.toDouble() ?? userLon;
                            }

                            final locations = await overpassService.getNearbyOffices(
                              userLat: userLat,
                              userLon: userLon,
                              radiusInMeters: searchRadius,
                              tags: tags,
                            );

                            if (context.mounted) {
                              _showOfficeLocationsModal(
                                context,
                                item.label,
                                locations,
                              );
                            }
                          },
                          icon: const Icon(Icons.location_on, size: 18),
                          label: const Text("Offices"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Original "Done"/"Undone" button logic
                        item.done
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirm"),
                                      content: Text(
                                          "Mark '${item.label}' as incomplete?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm ?? false) {
                                    controller.toggleItemDone(task, item);
                                  }
                                },
                                child: const Text("Undone"),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Confirm"),
                                      content:
                                          Text("Mark '${item.label}' as done?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm ?? false) {
                                    controller.toggleItemDone(task, item);
                                  }
                                },
                                child: const Text("Done"),
                              ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}