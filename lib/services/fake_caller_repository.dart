import 'dart:convert';

import '../models/fake_call_preset.dart';
import 'vault.dart';

/// Saves the user's own fake callers on the phone, so they can add, rename or
/// remove callers (e.g. "Mom", "Boss") with their own numbers. Works just like
/// the other simple repositories — a JSON list, encrypted in the [Vault].
class FakeCallerRepository {
  static const String _key = 'custom_fake_callers';

  Future<List<FakeCallPreset>> load() async {
    // Locked: let it throw. Returning [] here could later be saved over the
    // real list.
    final raw = await SecureStore.read(_key);
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
    final raw = jsonEncode(callers.map((c) => c.toJson()).toList());
    await SecureStore.write(_key, raw);
  }
}
