/// A fake call the user has scheduled for the future. Persisted so the list of
/// upcoming calls survives app restarts and can be shown, edited or cancelled.
///
/// [id] doubles as the flutter_local_notifications notification/alarm id, so it
/// must be unique and stable for the life of the schedule (see
/// [ScheduledCallRepository] which allocates it).
class ScheduledFakeCall {
  final int id;
  final String callerName;
  final String callerPhone;
  final DateTime scheduledAt;
  final int ringIndex;
  final bool shouldRepeat;
  final int? autoEndSeconds;

  const ScheduledFakeCall({
    required this.id,
    required this.callerName,
    required this.callerPhone,
    required this.scheduledAt,
    required this.ringIndex,
    required this.shouldRepeat,
    this.autoEndSeconds,
  });

  ScheduledFakeCall copyWith({
    int? id,
    String? callerName,
    String? callerPhone,
    DateTime? scheduledAt,
    int? ringIndex,
    bool? shouldRepeat,
    int? autoEndSeconds,
    bool clearAutoEnd = false,
  }) {
    return ScheduledFakeCall(
      id: id ?? this.id,
      callerName: callerName ?? this.callerName,
      callerPhone: callerPhone ?? this.callerPhone,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      ringIndex: ringIndex ?? this.ringIndex,
      shouldRepeat: shouldRepeat ?? this.shouldRepeat,
      autoEndSeconds:
          clearAutoEnd ? null : (autoEndSeconds ?? this.autoEndSeconds),
    );
  }

  /// True once the scheduled time has passed (the OS has already rung it).
  bool get hasFired => scheduledAt.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'callerName': callerName,
        'callerPhone': callerPhone,
        'scheduledAt': scheduledAt.toIso8601String(),
        'ringIndex': ringIndex,
        'shouldRepeat': shouldRepeat,
        'autoEndSeconds': autoEndSeconds,
      };

  factory ScheduledFakeCall.fromJson(Map<String, dynamic> json) =>
      ScheduledFakeCall(
        id: json['id'] as int,
        callerName: json['callerName'] as String,
        callerPhone: json['callerPhone'] as String? ?? '',
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        ringIndex: json['ringIndex'] as int? ?? 0,
        shouldRepeat: json['shouldRepeat'] as bool? ?? false,
        autoEndSeconds: json['autoEndSeconds'] as int?,
      );
}
