import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/medical_info.dart';
import 'vault.dart';

/// Saves and loads the user's medical info, encrypted in the [Vault]: it can
/// only be read while the app is unlocked.
class MedicalRepository {
  static const String _storageKey = 'medical_info';

  /// Bumped on every save so open screens (e.g. the QR card) can refresh.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// Read the saved medical info, or an empty one if nothing is saved yet.
  Future<MedicalInfo> load() async {
    final String? jsonText = await SecureStore.read(_storageKey);
    if (jsonText == null || jsonText.isEmpty) {
      return const MedicalInfo();
    }
    final Map<String, dynamic> map =
        jsonDecode(jsonText) as Map<String, dynamic>;
    return MedicalInfo.fromMap(map);
  }

  /// Save the medical info.
  Future<void> save(MedicalInfo info) async {
    await SecureStore.write(_storageKey, jsonEncode(info.toMap()));
    changes.value++;
  }
}
