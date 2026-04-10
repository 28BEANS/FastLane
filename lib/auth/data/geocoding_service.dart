import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<Map<String, double>?> getCoordinates(String address) async {
    final url = Uri(
      scheme: 'https',
      host: 'nominatim.openstreetmap.org',
      path: '/search',
      queryParameters: {
        'q': address,       // Uri handles encoding automatically
        'format': 'json',
        'limit': '1',
      },
    );

    debugPrint('[GEOCODING] URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FastLaneApp/1.0 (support@fastlane.com)',
        },
      );

      debugPrint('[GEOCODING] Status: ${response.statusCode}');
      debugPrint('[GEOCODING] Body: ${response.body}');

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data.isEmpty) return null;

      return {
        "lat": double.parse(data[0]["lat"]),
        "lng": double.parse(data[0]["lon"]),
      };
    } catch (e) {
      debugPrint('[GEOCODING] Error: $e');
      return null;
    }
  }
}