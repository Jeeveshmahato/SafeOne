import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/safety_event.dart';
import 'vault.dart';

/// The single, real safety log. Persists every safety action the user takes
/// (SOS sent, check-in, location shared, fake call) plus any incident the user
/// logs by hand — a JSON list, newest first, encrypted in the [Vault] (it
/// holds times and places).
///
/// An SOS can happen while the app is locked (e.g. a shake behind the lock
/// screen). The log can't be read then, so new events are sealed one by one
/// into a pending list and merged into the log at the next unlock.
class SafetyEventRepository {
  static const String _key = 'safety_events';
  static const String _pendingKey = 'safety_events_pending';
  static const int _maxEvents = 500;

  /// Throws [VaultLockedException] while the app is locked.
  Future<List<SafetyEvent>> load() async {
    final events = await _loadSaved();
    final pending = await _takePending();
    if (pending.isNotEmpty) {
      events.addAll(pending);
      await _save(events);
    }
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  Future<List<SafetyEvent>> _loadSaved() async {
    // Locked: let it throw. Returning [] here would be saved over the log.
    final raw = await SecureStore.read(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SafetyEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Decrypt and remove the events saved while the app was locked.
  Future<List<SafetyEvent>> _takePending() async {
    final prefs = await SharedPreferences.getInstance();
    final sealed = prefs.getStringList(_pendingKey) ?? const [];
    if (sealed.isEmpty) return [];
    final events = <SafetyEvent>[];
    for (final item in sealed) {
      try {
        final json = await Vault.instance.unseal(item);
        events.add(SafetyEvent.fromJson(jsonDecode(json) as Map<String, dynamic>));
      } on VaultLockedException {
        rethrow;
      } catch (_) {/* skip a damaged entry */}
    }
    await prefs.remove(_pendingKey);
    return events;
  }

  Future<void> add(SafetyEvent event) async {
    if (!Vault.instance.isOpen && await Vault.instance.exists()) {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? <String>[];
      pending.add(await Vault.instance.seal(jsonEncode(event.toJson())));
      await prefs.setStringList(_pendingKey, pending);
      return;
    }
    final events = await load()..insert(0, event);
    await _save(events);
  }

  Future<void> remove(String id) async {
    final events = await load()..removeWhere((e) => e.id == id);
    await _save(events);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_pendingKey);
  }

  Future<void> _save(List<SafetyEvent> events) async {
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    // Cap the history so the log can't grow without bound.
    final trimmed =
        events.length > _maxEvents ? events.sublist(0, _maxEvents) : events;
    await SecureStore.write(
        _key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
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
