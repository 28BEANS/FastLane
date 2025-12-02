import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/checklist_controller.dart';

import '../../../map/data/overpass_service.dart'; // NEW import
import '../../../map/data/office_location.dart'; // NEW import
import '../../../map/presentation/pages/map_page.dart'; // NEW import

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  // NEW method to show the results modal
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

  // Helper function to map requirement label to Overpass Tag
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
    // --- PLACEHOLDER DATA: REPLACE WITH ACTUAL USER DATA ---
    const double userLatitude = 15.1373919; // Example: Manila
    const double userLongitude = 120.5903763;
    const double searchRadius = 5000; 
    // --- END PLACEHOLDER DATA ---

    final overpassService = OverpassService(); // Initialize service

    return Consumer<ChecklistController>(
      builder: (context, controller, child) {
        final tasks = controller.tasks;

        if (tasks.isEmpty) {
          return const Center(child: Text("No tasks yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final progressPercentage = (task.progress * 100).toInt();

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                // ... (title remains the same)
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
                // ... (children mapping logic)
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
                    // NEW: Trailing logic is now a Row containing the button and the original action button
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Essential for Row in trailing
                      children: [
                        // --- NEW: "Where to get button" ---
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Determine the Overpass tag based on the requirement label.
                            // You will need to map requirement names to specific OSM tags.
                            // Example: If label contains 'Medical' or 'Certificate', use 'amenity=clinic'.
                            // This mapping is crucial for accurate results.
                            

                            // Show a loading indicator while fetching
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Searching for nearby offices...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            final tags = _getQueryTagsForLabel(item.label);

                            final locations = await overpassService.getNearbyOffices(
                              userLat: userLatitude,
                              userLon: userLongitude,
                              radiusInMeters: searchRadius,
                              tags: tags,
                            );

                            // Display the results in a modal
                            _showOfficeLocationsModal(
                              context,
                              item.label,
                              locations,
                            );
                          },
                          icon: const Icon(Icons.location_on, size: 18),
                          label: const Text("Offices"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 8), // Spacer
                        // --- END NEW Button ---
                        
                        // Original "Done"/"Undone" button logic
                        item.done
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: () async {
                                  // ... (existing undone confirmation dialog)
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
                                  // ... (existing done confirmation dialog)
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