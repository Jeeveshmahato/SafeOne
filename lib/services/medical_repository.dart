import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/medical_info.dart';

/// Saves and loads the user's medical info ON THE PHONE (as JSON text),
/// the same way [ContactsRepository] saves contacts.
class MedicalRepository {
  static const String _storageKey = 'medical_info';

  /// Read the saved medical info, or an empty one if nothing is saved yet.
  Future<MedicalInfo> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonText = prefs.getString(_storageKey);
    if (jsonText == null || jsonText.isEmpty) {
      return const MedicalInfo();
    }
    final Map<String, dynamic> map =
        jsonDecode(jsonText) as Map<String, dynamic>;
    return MedicalInfo.fromMap(map);
  }

  /// Save the medical info.
  Future<void> save(MedicalInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(info.toMap()));
  }
}
