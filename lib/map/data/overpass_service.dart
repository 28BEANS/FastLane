// services/overpass_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'office_location.dart';

// services/overpass_service.dart

class OverpassService {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  Future<List<OfficeLocation>> getNearbyOffices({
    required double userLat,
    required double userLon,
    required double radiusInMeters,
    required String queryTag, // Can now contain ' or '
  }) async {
    String createSearchLine(String tagFilter) {
      // Handles both simple and complex tags, assuming tagFilter is like ["key"="value"]
      // or ["key1"="val1"]["key2"="val2"]
      final around = '(around:$radiusInMeters, $userLat, $userLon)';
      return '''
        node$tagFilter$around;
        way$tagFilter$around;
        relation$tagFilter$around;
      ''';
    }

    String queryElements;

    if (queryTag.toLowerCase().contains(' or ')) {
      // --- UNION QUERY HANDLING (Multiple Tags) ---
      final tags = queryTag.split(' or ').map((t) => t.trim());
      
      // Combine the search line for each tag
      queryElements = tags.map((t) {
        final parts = t.split('=');
        final tagFilter = '["${parts[0]}"="${parts[1]}"]';
        return createSearchLine(tagFilter);
      }).join('\n');

    } else {
      // --- SINGLE TAG HANDLING ---
      // This assumes you have simplified your map function to only return key=value
      final parts = queryTag.split('=');
      final tagFilter = '["${parts[0]}"="${parts[1]}"]';
      queryElements = createSearchLine(tagFilter);
    }

    // 2. Construct the final query string
    final query = '''
      [out:json][timeout:60];
      (
        $queryElements
      );
      out center;
    ''';
    
    try {
      final response = await http.post(
        Uri.parse(_overpassUrl),
        body: query,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        // ... (rest of success parsing logic)
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        return elements
            .where((e) => e['type'] == 'node' && e.containsKey('lat'))
            .map((e) => OfficeLocation.fromJson(e))
            .toList();
      } else {
        print('Overpass query sent:\n$query'); // Log the query for debugging
        print('Overpass response body: ${response.body}');
        throw Exception(
            'Overpass API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby offices: $e');
      return [];
    }
  }
}