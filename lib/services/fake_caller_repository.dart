import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fake_call_preset.dart';

/// Saves the user's own fake callers on the phone, so they can add, rename or
/// remove callers (e.g. "Mom", "Boss") with their own numbers. Works just like
/// the other simple repositories — a JSON list in SharedPreferences.
class FakeCallerRepository {
  static const String _key = 'custom_fake_callers';

  Future<List<FakeCallPreset>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FakeCallPreset.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<FakeCallPreset> callers) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(callers.map((c) => c.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
