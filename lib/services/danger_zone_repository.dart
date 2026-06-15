import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/danger_zone.dart';

/// Saves and loads the list of danger zones (unsafe areas) on the phone.
class DangerZoneRepository {
  static const String _storageKey = 'danger_zones';

  /// Load all saved danger zones.
  Future<List<DangerZone>> loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonText = prefs.getString(_storageKey);

    if (jsonText == null || jsonText.isEmpty) {
      return [];
    }

    final List<dynamic> rawList = jsonDecode(jsonText) as List<dynamic>;
    return rawList
        .map((item) => DangerZone.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Save all danger zones, replacing whatever was there.
  Future<void> saveZones(List<DangerZone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> rawList =
        zones.map((z) => z.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(rawList));
  }

  /// Add a single zone and save.
  Future<void> addZone(DangerZone zone) async {
    final zones = await loadZones();
    zones.add(zone);
    await saveZones(zones);
  }

  /// Delete a zone by ID and save.
  Future<void> deleteZone(String id) async {
    final zones = await loadZones();
    zones.removeWhere((z) => z.id == id);
    await saveZones(zones);
  }
}
