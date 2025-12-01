import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<Map<String, double>?> getCoordinates(String address) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=$address&format=json&limit=1",
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'FastLaneApp/1.0 (support@fastlane.com)',
      },
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data.isEmpty) return null;

    return {
      "lat": double.parse(data[0]["lat"]),
      "lng": double.parse(data[0]["lon"]),
    };
  }
}
