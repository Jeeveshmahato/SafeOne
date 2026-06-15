class CallScenario {
  final String id;
  final String name;
  final String description;
  final String? suggestedMessage;
  final String? presetCallerName;

  const CallScenario({
    required this.id,
    required this.name,
    required this.description,
    this.suggestedMessage,
    this.presetCallerName,
  });
}
