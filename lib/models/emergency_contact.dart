/// A single person who will be alerted when the SOS is triggered.
///
/// This is a plain "data class": it just holds a [name] and a [phone] number.
/// We convert it to and from a Map so it can be saved on the phone as JSON.
class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  /// Turn this contact into a simple Map (used before saving to storage).
  Map<String, dynamic> toMap() {
    return {'name': name, 'phone': phone};
  }

  /// Build a contact back from a Map (used after loading from storage).
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
    );
  }
}
