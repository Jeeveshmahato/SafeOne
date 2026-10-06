import 'package:flutter_test/flutter_test.dart';
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
        '$link (last known location, from 25 min ago)');
    expect(
        describeLocation(link, now.subtract(const Duration(hours: 5)), now: now),
        '$link (last known location, from 5 h ago)');
  });

  test('no location still produces a clear message', () {
    expect(describeLocation(null, null, now: now), '(location unavailable)');
  });
}
