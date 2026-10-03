/// The user's Medical ID: details that help first responders in an emergency.
///
/// Like [EmergencyContact], this is a plain data class that can be turned into
/// and from a Map so it can be saved on the phone. Fields added later default
/// to '' so data saved by older app versions still loads.
class MedicalInfo {
  final String fullName;
  final String dateOfBirth;
  final String bloodGroup;
  final String allergies;
  final String conditions;
  final String medications;
  final String notes;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const MedicalInfo({
    this.fullName = '',
    this.dateOfBirth = '',
    this.bloodGroup = '',
    this.allergies = '',
    this.conditions = '',
    this.medications = '',
    this.notes = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
  });

  /// True until the user has filled in at least their name.
  bool get isEmpty => fullName.trim().isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'conditions': conditions,
      'medications': medications,
      'notes': notes,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }

  factory MedicalInfo.fromMap(Map<String, dynamic> map) {
    String read(String key) => (map[key] ?? '') as String;
    return MedicalInfo(
      fullName: read('fullName'),
      dateOfBirth: read('dateOfBirth'),
      bloodGroup: read('bloodGroup'),
      allergies: read('allergies'),
      conditions: read('conditions'),
      medications: read('medications'),
      notes: read('notes'),
      emergencyContactName: read('emergencyContactName'),
      emergencyContactPhone: read('emergencyContactPhone'),
    );
  }
}
