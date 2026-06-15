/// The user's medical information, useful for first responders in an emergency.
///
/// Like [EmergencyContact], this is a plain data class that can be turned into
/// and from a Map so it can be saved on the phone.
class MedicalInfo {
  final String fullName;
  final String bloodGroup;
  final String allergies;
  final String medications;
  final String notes;

  const MedicalInfo({
    this.fullName = '',
    this.bloodGroup = '',
    this.allergies = '',
    this.medications = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'medications': medications,
      'notes': notes,
    };
  }

  factory MedicalInfo.fromMap(Map<String, dynamic> map) {
    return MedicalInfo(
      fullName: (map['fullName'] ?? '') as String,
      bloodGroup: (map['bloodGroup'] ?? '') as String,
      allergies: (map['allergies'] ?? '') as String,
      medications: (map['medications'] ?? '') as String,
      notes: (map['notes'] ?? '') as String,
    );
  }
}
