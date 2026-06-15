enum EmergencyType {
  police,
  fire,
  medical,
  harassment,
  stalking,
  assault,
}

class EmergencyProtocol {
  final String id;
  final EmergencyType type;
  final String title;
  final String description;
  final String emergencyNumber;
  final List<String> steps;
  final String? localPoliceInfo;

  const EmergencyProtocol({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emergencyNumber,
    required this.steps,
    this.localPoliceInfo,
  });

  static const List<EmergencyProtocol> standardProtocols = [
    EmergencyProtocol(
      id: '1',
      type: EmergencyType.police,
      title: 'Police Emergency',
      description: 'Immediate danger, assault, stalking, or threatening behavior',
      emergencyNumber: '112',
      steps: [
        'Call 112 (national emergency) or 100 for police',
        'State your location clearly',
        'Describe the threat/attacker',
        'Follow the operator\'s instructions',
        'Stay on the line',
      ],
      localPoliceInfo: 'Police: 100 • National emergency: 112 • '
          'Women Helpline: 1091',
    ),
    EmergencyProtocol(
      id: '2',
      type: EmergencyType.harassment,
      title: 'Harassment or Threatening Behavior',
      description: 'Being followed, harassed, or receiving threats',
      emergencyNumber: '1091',
      steps: [
        'Go to a public place with people',
        'Call Women Helpline 1091 or 112 and report location',
        'Take photos of the person if safe',
        'Get witness contact information',
        'File a report with police (100)',
      ],
      localPoliceInfo: 'Women Helpline: 1091 / 181 • '
          'National emergency: 112 • Police: 100',
    ),
    EmergencyProtocol(
      id: '3',
      type: EmergencyType.stalking,
      title: 'Stalking or Suspicious Following',
      description: 'Someone following you or watching you',
      emergencyNumber: '112',
      steps: [
        'Do not go home - go to a public place',
        'Call a trusted contact AND police (112 / 100)',
        'Move to a well-lit area',
        'Note description of person/vehicle',
        'Ask for a police escort home',
      ],
      localPoliceInfo: 'National emergency: 112 • Police: 100 • '
          'Women Helpline: 1091',
    ),
    EmergencyProtocol(
      id: '4',
      type: EmergencyType.assault,
      title: 'Physical Assault',
      description: 'Being attacked or harmed',
      emergencyNumber: '112',
      steps: [
        'CALL 112 IMMEDIATELY (or Police 100)',
        'Get to safety first',
        'Do not shower or bathe (preserves evidence)',
        'Do not clean injuries',
        'Go to hospital for medical check & evidence collection',
      ],
      localPoliceInfo: 'National emergency: 112 • Police: 100 • '
          'Ambulance: 102 / 108 • Women Helpline: 1091',
    ),
    EmergencyProtocol(
      id: '5',
      type: EmergencyType.medical,
      title: 'Medical Emergency',
      description: 'Medical urgency, injury, or health crisis',
      emergencyNumber: '102',
      steps: [
        'Call 102 or 108 for an ambulance',
        'State the medical condition clearly',
        'Provide your location',
        'Follow the operator\'s instructions',
        'Stay calm and provide information',
      ],
      localPoliceInfo: 'Ambulance: 102 / 108 • National emergency: 112',
    ),
  ];
}
