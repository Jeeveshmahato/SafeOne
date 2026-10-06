// On-device end-to-end test for the fake-call feature.
//
// This launches the REAL app on a connected device/emulator and drives the
// actual UI, exercising the real vibration + audio plugins — the strongest
// "nothing is broken at runtime" check.
//
// Run with:  flutter test integration_test/fake_call_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:women_safety_app/main.dart' as app;
import 'package:women_safety_app/screens/home_screen.dart';
import 'package:women_safety_app/screens/fake_call_screen.dart';
import 'package:women_safety_app/screens/fake_call_setup_screen.dart';
import 'package:women_safety_app/screens/ongoing_call_screen.dart';

import 'pin_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home -> fake call setup -> incoming -> ongoing -> hang up',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Get past the app lock (first run creates a PIN, later runs unlock).
    await unlockApp(tester, HomeScreen);

    // Open the Fake Call feature from the home grid.
    final fakeCallTile = find.text('Fake call');
    await tester.scrollUntilVisible(fakeCallTile, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(fakeCallTile);
    await tester.pumpAndSettle();
    expect(find.byType(FakeCallSetupScreen), findsOneWidget);

    // Start the call immediately (default delay = Now).
    final startBtn = find.text('Start fake call');
    await tester.ensureVisible(startBtn);
    await tester.tap(startBtn);
    // NOTE: the call screens run continuous feedback (looping vibration, audio,
    // and a 1s ongoing-call timer that calls setState). pumpAndSettle would
    // never settle on those, so we use bounded pumps instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The incoming (ringing) call screen should appear.
    expect(find.byType(FakeCallScreen), findsOneWidget);
    expect(find.byIcon(Icons.call), findsOneWidget); // accept
    expect(find.byIcon(Icons.call_end), findsOneWidget); // decline

    // Accept the call -> ongoing call screen.
    await tester.tap(find.byIcon(Icons.call));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(OngoingCallScreen), findsOneWidget);
    expect(find.text('End call'), findsOneWidget);

    // Let the timer tick once, then hang up.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.call_end));
    // _endCall pops after a real 250ms delay; wait real wall-clock time on
    // device, then let the navigation settle.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byType(OngoingCallScreen), findsNothing);
  });
}
