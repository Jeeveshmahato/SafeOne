// Widget tests for the fake-call feature: setup screen rendering & localization,
// and the incoming -> ongoing call flow including the looping ring vibration.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:women_safety_app/l10n/app_localizations.dart';
import 'package:women_safety_app/screens/fake_call_screen.dart';
import 'package:women_safety_app/screens/fake_call_setup_screen.dart';
import 'package:women_safety_app/screens/ongoing_call_screen.dart';
import 'package:women_safety_app/services/call_sound.dart';

/// A no-op ring sound that records start/stop calls instead of playing audio.
class FakeCallSound implements CallSound {
  int starts = 0;
  int stops = 0;
  bool _active = false;

  @override
  bool get isActive => _active;

  @override
  Future<void> start() async {
    starts++;
    _active = true;
  }

  @override
  Future<void> stop() async {
    stops++;
    _active = false;
  }

  @override
  Future<void> dispose() async {}
}

/// Wrap a screen with the same localization setup the real app uses, optionally
/// forcing a specific language.
Widget _app(Widget home, {Locale? locale}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Record vibration calls so we can assert that ringing starts and is
  // cancelled, without needing a real device.
  final vibrationCalls = <String>[];

  setUp(() {
    vibrationCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('vibration'),
      (call) async {
        vibrationCalls.add(call.method);
        if (call.method == 'hasVibrator' ||
            call.method == 'hasAmplitudeControl' ||
            call.method == 'hasCustomVibrationsSupport') {
          return true;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vibration'), null);
  });

  testWidgets('setup screen renders core controls in English',
      (tester) async {
    await tester.pumpWidget(_app(const FakeCallSetupScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Fake call'), findsWidgets);
    expect(find.text('Start fake call'), findsOneWidget);
    expect(find.text('Ring sound'), findsOneWidget);
    expect(find.text('Police siren'), findsOneWidget);
    expect(find.text('Phone ring'), findsOneWidget);
  });

  testWidgets('setup screen is fully translated (Hindi)', (tester) async {
    await tester.pumpWidget(
      _app(const FakeCallSetupScreen(), locale: const Locale('hi')),
    );
    await tester.pumpAndSettle();

    // Hindi label for "Start Fake Call".
    expect(find.text('नकली कॉल शुरू करें'), findsOneWidget);
    // No leftover English on the primary action.
    expect(find.text('Start fake call'), findsNothing);
  });

  testWidgets('incoming call starts the ring sound and shows accept/decline',
      (tester) async {
    final sound = FakeCallSound();
    await tester.pumpWidget(_app(
      FakeCallScreen(callerName: 'Mom', callerPhone: '123', sound: sound),
    ));
    await tester.pump(); // let initState's async ring kick off
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Mom'), findsOneWidget);
    expect(find.text('Incoming call…'), findsOneWidget);
    expect(find.byIcon(Icons.call), findsOneWidget); // accept
    expect(find.byIcon(Icons.call_end), findsOneWidget); // decline

    // The ring sound should be playing while the call is coming in.
    expect(sound.starts, 1);
    expect(sound.isActive, isTrue);
    // The buzz itself only fires on a physical device (hasVibrator is false on
    // the test host); cancellation on accept/decline is checked below.
  });

  testWidgets('accepting moves to the ongoing call and can hang up',
      (tester) async {
    final sound = FakeCallSound();
    await tester.pumpWidget(_app(
      FakeCallScreen(callerName: 'Mom', callerPhone: '123', sound: sound),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap accept (green call icon).
    await tester.tap(find.byIcon(Icons.call));
    await tester.pumpAndSettle();

    // Ringing feedback must stop when accepting.
    expect(vibrationCalls, contains('cancel'));
    expect(sound.stops, 1);

    // Ongoing call screen shows its End Call control and a timer (00:00).
    expect(find.byType(OngoingCallScreen), findsOneWidget);
    expect(find.text('End call'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    // Let the call timer tick once.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);

    // Hang up.
    await tester.tap(find.byIcon(Icons.call_end));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(OngoingCallScreen), findsNothing);
  });

  testWidgets('declining a non-repeating call closes the screen',
      (tester) async {
    final sound = FakeCallSound();
    // Host the call screen so pop() has somewhere to return to.
    await tester.pumpWidget(_app(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      FakeCallScreen(callerName: 'Boss', sound: sound),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(FakeCallScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.call_end)); // decline
    await tester.pumpAndSettle();

    expect(find.byType(FakeCallScreen), findsNothing);
    expect(vibrationCalls, contains('cancel'));
    expect(sound.stops, greaterThanOrEqualTo(1));
  });
}
