import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/services/safety_monitor_service.dart';
import 'package:women_safety_app/services/settings_repository.dart';
import 'package:women_safety_app/widgets/duration_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('check-in timer survives the app closing', () {
    test('a running check-in is read back from what the alarm saved',
        () async {
      final started = DateTime(2026, 10, 11, 9);
      final deadline = DateTime(2026, 10, 11, 9, 30);
      // What MainActivity / CheckinScheduler write.
      SharedPreferences.setMockInitialValues({
        'checkin_active': true,
        'checkin_started_ms': started.millisecondsSinceEpoch,
        'checkin_deadline_ms': deadline.millisecondsSinceEpoch,
      });

      final status = await SafetyMonitorService.checkinStatus();

      expect(status, isNotNull);
      expect(status!.startedAt, started);
      expect(status.deadline, deadline);
    });

    test('no check-in once it was ended or ran out', () async {
      SharedPreferences.setMockInitialValues({
        'checkin_active': false,
        'checkin_deadline_ms': DateTime(2026).millisecondsSinceEpoch,
      });
      expect(await SafetyMonitorService.checkinStatus(), isNull);

      SharedPreferences.setMockInitialValues({'checkin_active': true});
      expect(await SafetyMonitorService.checkinStatus(), isNull);
    });
  });

  test('the last picked times are remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsRepository();
    const fallback = Duration(minutes: 15);

    expect(await settings.loadTimerPreset(TimerPreset.checkin, fallback),
        fallback);
    await settings.saveTimerPreset(
        TimerPreset.checkin, const Duration(hours: 2));
    expect(await settings.loadTimerPreset(TimerPreset.checkin, fallback),
        const Duration(hours: 2));
    // Each timer keeps its own.
    expect(
        await settings.loadTimerPreset(TimerPreset.journeyEta, fallback),
        fallback);
  });

  test('a saved time comes back in the unit it reads best in', () {
    const units = TimeUnit.minutesAndHours;
    expect(TimeUnit.bestFor(const Duration(hours: 2), units), TimeUnit.hours);
    expect(TimeUnit.bestFor(const Duration(minutes: 90), units),
        TimeUnit.minutes);
    expect(TimeUnit.bestFor(const Duration(minutes: 5), units),
        TimeUnit.minutes);
  });

  testWidgets('timers of a minute or more offer no seconds', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DurationField(
          initial: const Duration(minutes: 5),
          units: TimeUnit.minutesAndHours,
          onChanged: (_) {},
        ),
      ),
    ));
    await tester.tap(find.byType(DropdownMenu<TimeUnit>));
    await tester.pumpAndSettle();

    expect(find.text('Seconds'), findsNothing);
    expect(find.text('Hours'), findsWidgets);
  });
}
