class EmergencyID {
  final String fullName;
  final String? bloodType;
  final String? allergies;
  final String? medicalConditions;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? dateOfBirth;

  const EmergencyID({
    required this.fullName,
    this.bloodType,
    this.allergies,
    this.medicalConditions,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.dateOfBirth,
  });

  EmergencyID copyWith({
    String? fullName,
    String? bloodType,
    String? allergies,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? dateOfBirth,
  }) {
    return EmergencyID(
      fullName: fullName ?? this.fullName,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
