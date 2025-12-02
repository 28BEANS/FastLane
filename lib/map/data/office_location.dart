class OfficeLocation {
final int id;
final String name;
final String address;
final double latitude;
final double longitude;


OfficeLocation({
required this.id,
required this.name,
required this.address,
required this.latitude,
required this.longitude,
});


factory OfficeLocation.fromJson(Map<String, dynamic> json) {
final tags = json['tags'] ?? {};
double lat = 0.0;
double lon = 0.0;


if (json['type'] == 'node') {
lat = (json['lat'] as num).toDouble();
lon = (json['lon'] as num).toDouble();
} else if (json.containsKey('center')) {
lat = (json['center']['lat'] as num).toDouble();
lon = (json['center']['lon'] as num).toDouble();
}


return OfficeLocation(
id: json['id'] as int,
name: tags['name'] ?? 'Unknown Location',
address: tags['addr:full'] ?? tags['addr:street'] ?? 'No Address',
latitude: lat,
longitude: lon,
);
}
}