import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/safety_event.dart';

/// The single, real safety log. Persists every safety action the user takes
/// (SOS sent, check-in, location shared, fake call) plus any incident the user
/// logs by hand — a JSON list in SharedPreferences, newest first.
///
/// Replaces the two old demo screens (Incident Vault + Safety Event Log) which
/// only showed hardcoded sample data.
class SafetyEventRepository {
  static const String _key = 'safety_events';
  static const int _maxEvents = 500;

  Future<List<SafetyEvent>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final events = list
          .map((e) => SafetyEvent.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } catch (_) {
      return [];
    }
  }

  Future<void> add(SafetyEvent event) async {
    final events = await load()..insert(0, event);
    // Cap the history so the log can't grow without bound.
    final trimmed =
        events.length > _maxEvents ? events.sublist(0, _maxEvents) : events;
    await _save(trimmed);
  }

  Future<void> remove(String id) async {
    final events = await load()..removeWhere((e) => e.id == id);
    await _save(events);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(List<SafetyEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  /// Convenience used across the app to record an event with one call. Failures
  /// are swallowed — logging must never get in the way of an actual SOS.
  Future<void> log(
    SafetyEventType type,
    String description, {
    String? location,
    List<String>? contacts,
  }) async {
    try {
      await add(SafetyEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: type,
        description: description,
        location: location,
        contactsNotified: contacts,
      ));
    } catch (_) {/* best-effort */}
  }
}
