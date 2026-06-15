import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scheduled_fake_call.dart';

/// Persists the list of upcoming fake calls (a JSON list in SharedPreferences,
/// same pattern as the other repositories) and allocates the unique
/// notification id each scheduled call uses.
class ScheduledCallRepository {
  static const String _key = 'scheduled_fake_calls';
  // Notification ids 1001 (check-in) and 2001 (immediate call) are reserved by
  // NotificationService, so scheduled-call ids start above them.
  static const String _counterKey = 'scheduled_fake_call_next_id';
  static const int _idBase = 3000;

  /// Loads all scheduled calls, dropping any whose time has already passed
  /// (the OS already rang them) and persisting the pruned list back.
  Future<List<ScheduledFakeCall>> loadUpcoming() async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decode(prefs.getString(_key));
    final upcoming = all.where((c) => !c.hasFired).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    if (upcoming.length != all.length) {
      await _save(prefs, upcoming);
    }
    return upcoming;
  }

  /// Reserves the next unique notification id.
  Future<int> nextId() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_counterKey) ?? _idBase) + 1;
    await prefs.setInt(_counterKey, next);
    return next;
  }

  Future<void> add(ScheduledFakeCall call) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _decode(prefs.getString(_key))..add(call);
    await _save(prefs, list);
  }

  Future<void> update(ScheduledFakeCall call) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _decode(prefs.getString(_key));
    final i = list.indexWhere((c) => c.id == call.id);
    if (i == -1) {
      list.add(call);
    } else {
      list[i] = call;
    }
    await _save(prefs, list);
  }

  Future<void> remove(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _decode(prefs.getString(_key))
      ..removeWhere((c) => c.id == id);
    await _save(prefs, list);
  }

  List<ScheduledFakeCall> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ScheduledFakeCall.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(
      SharedPreferences prefs, List<ScheduledFakeCall> list) async {
    await prefs.setString(
        _key, jsonEncode(list.map((c) => c.toJson()).toList()));
  }
}
