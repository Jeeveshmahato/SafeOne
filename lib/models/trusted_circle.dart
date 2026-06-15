class TrustedCircle {
  final String id;
  final String name;
  final String description;
  final List<String> contactIds;
  final bool notifyOnSOS;
  final bool notifyOnCheckIn;
  final bool shareLocation;

  const TrustedCircle({
    required this.id,
    required this.name,
    required this.description,
    required this.contactIds,
    this.notifyOnSOS = true,
    this.notifyOnCheckIn = false,
    this.shareLocation = false,
  });

  TrustedCircle copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? contactIds,
    bool? notifyOnSOS,
    bool? notifyOnCheckIn,
    bool? shareLocation,
  }) {
    return TrustedCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      contactIds: contactIds ?? this.contactIds,
      notifyOnSOS: notifyOnSOS ?? this.notifyOnSOS,
      notifyOnCheckIn: notifyOnCheckIn ?? this.notifyOnCheckIn,
      shareLocation: shareLocation ?? this.shareLocation,
    );
  }
}
