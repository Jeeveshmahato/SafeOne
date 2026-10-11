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
///
/// The background service (SafetyLog.kt) can't encrypt at all, so it leaves
/// each event in its own "native_event_*" preference, holding no location.
/// [importNativeEvents] moves them in as soon as the app runs.
class SafetyEventRepository {
  static const String _key = 'safety_events';
  static const String _pendingKey = 'safety_events_pending';
  static const String _nativePrefix = 'native_event_';
  static const int _maxEvents = 500;

  /// Throws [VaultLockedException] while the app is locked.
  Future<List<SafetyEvent>> load() async {
    final events = await _loadSaved();
    final pending = [...await _takePending(), ...await _takeNative()];
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

  /// Takes the events the background service recorded, removing them.
  Future<List<SafetyEvent>> _takeNative() async {
    final prefs = await SharedPreferences.getInstance();
    // Written by another part of the app since this cache was filled.
    await prefs.reload();
    final keys = prefs.getKeys().where((k) => k.startsWith(_nativePrefix));
    final events = <SafetyEvent>[];
    for (final key in keys.toList()) {
      final raw = prefs.getString(key);
      await prefs.remove(key);
      if (raw == null) continue;
      try {
        events.add(SafetyEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {/* skip a damaged entry */}
    }
    return events;
  }

  /// Moves what the background service recorded into the log, so it's in
  /// Records and encrypted. Works while the app is locked: the events are
  /// then sealed into the pending list. Best-effort.
  Future<void> importNativeEvents() async {
    try {
      if (!Vault.instance.isOpen && await Vault.instance.exists()) {
        for (final event in await _takeNative()) {
          await add(event);
        }
      } else {
        await load(); // merges them
      }
    } catch (_) {/* best-effort */}
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
