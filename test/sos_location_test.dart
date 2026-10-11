import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_app/services/settings_repository.dart';
import 'package:women_safety_app/services/sos_service.dart';

void main() {
  const link = 'https://maps.google.com/?q=12.97,77.59';
  final now = DateTime(2026, 10, 6, 12);

  test('a fresh fix is sent as-is', () {
    expect(describeLocation(link, now.subtract(const Duration(minutes: 1)), now: now),
        link);
  });

  test('an old fix is labelled with its age', () {
    expect(
        describeLocation(link, now.subtract(const Duration(minutes: 25)), now: now),
        '$link (from 25 min ago)');
    expect(
        describeLocation(link, now.subtract(const Duration(hours: 5)), now: now),
        '$link (from 5 hours ago)');
  });

  test('no location is left for the caller to word', () {
    expect(describeLocation(null, null, now: now), isNull);
  });

  test('alert text uses only GSM SMS characters', () {
    // One character outside the GSM alphabet halves what fits in an SMS.
    final gsm = RegExp(r"^[A-Za-z0-9 \n.,:;!?()%/=&_+\-@']*$");
    for (final text in [
      SettingsRepository.defaultSosMessage,
      SettingsRepository.defaultSosMessageNoLocation,
      describeLocation(link, now.subtract(const Duration(minutes: 25)), now: now)!,
    ]) {
      expect(gsm.hasMatch(text.replaceAll('{location}', link)), isTrue,
          reason: text);
    }
  });
}
