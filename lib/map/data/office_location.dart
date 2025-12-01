// models/office_location.dart
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
    // Overpass nodes (points) have 'lat' and 'lon'
    return OfficeLocation(
      id: json['id'] as int,
      name: json['tags']['name'] ?? 'Office Location',
      address: json['tags']['addr:full'] ?? json['tags']['addr:street'] ?? 'No Address',
      latitude: json['lat'] as double,
      longitude: json['lon'] as double,
    );
  }
}