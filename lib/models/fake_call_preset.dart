/// Represents a saved fake caller preset for quick access.
/// This lets users save their favorite callers (Mom, Boss, etc.) with
/// custom phone numbers, so they don't have to type them every time.
class FakeCallPreset {
  final String id;
  final String name;
  final String phoneNumber;

  const FakeCallPreset({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  FakeCallPreset copyWith({
    String? id,
    String? name,
    String? phoneNumber,
  }) {
    return FakeCallPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'phoneNumber': phoneNumber};

  factory FakeCallPreset.fromJson(Map<String, dynamic> json) => FakeCallPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String,
      );
}
