enum SafetyEventType {
  sos,
  checkIn,
  fakeCall,
  incidentLogged,
  locationShared,
}

class SafetyEvent {
  final String id;
  final DateTime timestamp;
  final SafetyEventType type;
  final String description;
  final String? location;
  final List<String>? contactsNotified;

  const SafetyEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    this.location,
    this.contactsNotified,
  });

  String get typeLabel {
    switch (type) {
      case SafetyEventType.sos:
        return 'SOS Alert';
      case SafetyEventType.checkIn:
        return 'Check-in';
      case SafetyEventType.fakeCall:
        return 'Fake Call Used';
      case SafetyEventType.incidentLogged:
        return 'Incident Logged';
      case SafetyEventType.locationShared:
        return 'Location Shared';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'description': description,
        'location': location,
        'contactsNotified': contactsNotified,
      };

  factory SafetyEvent.fromJson(Map<String, dynamic> json) => SafetyEvent(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: SafetyEventType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => SafetyEventType.incidentLogged,
        ),
        description: json['description'] as String? ?? '',
        location: json['location'] as String?,
        contactsNotified: (json['contactsNotified'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );
}
