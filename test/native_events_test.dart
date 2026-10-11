import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/models/safety_event.dart';
import 'package:women_safety_app/services/safety_event_repository.dart';
import 'package:women_safety_app/services/vault.dart';

/// Events the background service records (SafetyLog.kt) end up in Records.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Vault.instance.lock());

  // What SafetyLog.kt writes: one preference per event.
  String nativeEvent(String id, String type, String description) => jsonEncode({
        'id': id,
        'timestamp': '2026-10-11T09:15:30.000',
        'type': type,
        'description': description,
        'contactsNotified': ['Asha'],
      });

  test('background events move into Records and are removed', () async {
    SharedPreferences.setMockInitialValues({
      'native_event_1': nativeEvent(
          '1', 'sos', 'SOS was sent to your contact (you shook your phone)'),
      'native_event_2': nativeEvent('2', 'locationShared',
          'Your phone was switching off, so your contact got your last location'),
      'emergency_contacts': '[]',
    });
    final repo = SafetyEventRepository();

    await repo.importNativeEvents();

    final events = await repo.load();
    expect(events.map((e) => e.id), containsAll(['1', '2']));
    final sos = events.firstWhere((e) => e.id == '1');
    expect(sos.type, SafetyEventType.sos);
    expect(sos.contactsNotified, ['Asha']);
    expect(sos.timestamp, DateTime(2026, 10, 11, 9, 15, 30));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().where((k) => k.startsWith('native_event_')), isEmpty);
    expect(prefs.getString('emergency_contacts'), '[]'); // untouched

    // Importing again adds nothing twice.
    await repo.importNativeEvents();
    expect((await repo.load()).length, events.length);
  });

  test('a damaged entry is dropped without losing the others', () async {
    SharedPreferences.setMockInitialValues({
      'native_event_1': '{not json',
      'native_event_2': nativeEvent('2', 'sos', 'SOS was sent to your contact'),
    });
    final repo = SafetyEventRepository();

    await repo.importNativeEvents();

    final events = await repo.load();
    expect(events.map((e) => e.id), ['2']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().where((k) => k.startsWith('native_event_')), isEmpty);
  });
}
