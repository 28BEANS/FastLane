// services/overpass_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'office_location.dart';

// services/overpass_service.dart

class OverpassService {
static const String _url = 'https://overpass-api.de/api/interpreter';


Future<List<OfficeLocation>> getNearbyOffices({
required double userLat,
required double userLon,
required double radiusInMeters,
required List<String> tags, // list of key=value strings
}) async {
// Build search lines for each tag and element type
String buildLine(String tag) {
final kv = tag.split('=');
if (kv.length != 2) return ''; // skip invalid tags
final key = kv[0].trim();
final value = kv[1].trim();
final filter = '["$key"="$value"]';
return 'node$filter(around:$radiusInMeters,$userLat,$userLon);\nway$filter(around:$radiusInMeters,$userLat,$userLon);\nrelation$filter(around:$radiusInMeters,$userLat,$userLon);';
}


final queryElements = tags.map(buildLine).join('\n');
final query = '''[out:json][timeout:60];($queryElements);out center;''';


try {
final res = await http.post(Uri.parse(_url),
headers: {'Content-Type': 'application/x-www-form-urlencoded'},
body: query);
if (res.statusCode != 200) throw Exception('Overpass error ${res.statusCode}');


final data = json.decode(res.body);
final elements = data['elements'] as List;


// Map all elements to OfficeLocation
return elements.map((e) {
double lat = 0.0;
double lon = 0.0;
if (e['type'] == 'node') {
lat = (e['lat'] as num).toDouble();
lon = (e['lon'] as num).toDouble();
} else if (e.containsKey('center')) {
lat = (e['center']['lat'] as num).toDouble();
lon = (e['center']['lon'] as num).toDouble();
}
final tags = e['tags'] ?? {};
return OfficeLocation(
id: e['id'] as int,
name: tags['name'] ?? 'Unknown Location',
address: tags['addr:full'] ?? tags['addr:street'] ?? 'No Address',
latitude: lat,
longitude: lon,
);
}).toList();
} catch (e) {
print('Overpass error: $e');
return [];
}
}
}