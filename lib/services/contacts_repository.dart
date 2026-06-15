import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/emergency_contact.dart';

/// Saves and loads the list of emergency contacts ON THE PHONE.
///
/// We use `shared_preferences`, which is a tiny key-value storage built into
/// the phone. We store the whole list as one JSON text string under one key.
///
/// "Repository" is just a common name for the class that talks to storage,
/// so the rest of the app never has to know HOW data is saved.
class ContactsRepository {
  // The name (key) under which we store the contacts. Any unique text works.
  static const String _storageKey = 'emergency_contacts';

  /// Read all saved contacts. Returns an empty list if nothing is saved yet.
  Future<List<EmergencyContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonText = prefs.getString(_storageKey);

    // Nothing saved yet -> return an empty list.
    if (jsonText == null || jsonText.isEmpty) {
      return [];
    }

    // The stored text is a JSON list, e.g. [{"name":"Mom","phone":"123"}].
    final List<dynamic> rawList = jsonDecode(jsonText) as List<dynamic>;
    return rawList
        .map((item) => EmergencyContact.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Save the full list of contacts, replacing whatever was there before.
  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> rawList =
        contacts.map((c) => c.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(rawList));
  }
}
