import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {

  static String _tagForDocument(String documentTag) {
    switch (documentTag) {
      case 'medical_cert':
        return '["healthcare"="clinic"]';

      case 'government_id':
        return '["office"="government"]';

      case 'police_clearance':
        return '["amenity"="police"]';

      case 'barangay_clearance':
        return '["office"="government"]["government"="barangay"]';

      default:
        return '["office"="government"]';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNearbyOffices(
    double lat,
    double lng,
    double radiusInMeters,
    String documentTag,
  ) async {

    final filter = _tagForDocument(documentTag);

    final query = '''
[out:json];
node(around:$radiusInMeters,$lat,$lng)$filter;
out;
''';

    final response = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      body: query,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch nearby offices");
    }

    final json = jsonDecode(response.body);
    final elements = json['elements'] as List;

    return elements.map((e) {
      final tags = e['tags'] ?? {};
      return {
        'name': tags['name'] ?? 'Unnamed Office',
        'lat': e['lat'],
        'lng': e['lon'],
      };
    }).toList();
  }
}
