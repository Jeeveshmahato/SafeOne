/// A marked GPS location that the user considers unsafe or dangerous.
class DangerZone {
  final String id;
  final String name;
  final String note;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final DateTime createdAt;

  const DangerZone({
    required this.id,
    required this.name,
    required this.note,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 200,
    required this.createdAt,
  });

  /// Convert to Map for SharedPreferences storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Rebuild from a Map after loading from storage.
  factory DangerZone.fromMap(Map<String, dynamic> map) {
    return DangerZone(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      note: (map['note'] ?? '') as String,
      latitude: (map['latitude'] ?? 0.0) as double,
      longitude: (map['longitude'] ?? 0.0) as double,
      radiusMeters: (map['radiusMeters'] ?? 200) as int,
      createdAt: DateTime.parse((map['createdAt'] ?? DateTime.now().toIso8601String()) as String),
    );
  }
}
