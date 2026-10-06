import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_app/widgets/pin_pad.dart';

/// The app PIN used by the on-device tests. Not a repeat or a sequence, so
/// it passes the "too easy to guess" check.
const testAppPin = '482915';

/// Pump until [finder] matches (real time passes, e.g. for PIN hashing).
Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      final shown = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .whereType<String>()
          .join(' | ');
      throw TestFailure('Timed out waiting for $finder\nOn screen: $shown');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Type [pin] on the (scrambled) keypad and press the confirm key.
Future<void> enterPin(WidgetTester tester, String pin) async {
  final pad = find.byType(PinPad).last;
  for (final digit in pin.split('')) {
    await tester.tap(find.descendant(of: pad, matching: find.text(digit)));
    await tester.pump();
  }
  await tester.tap(find.descendant(
      of: pad, matching: find.byIcon(Icons.arrow_forward_rounded)));
  // Checking a PIN runs a deliberately slow hash on another isolate.
  await tester.pump(const Duration(milliseconds: 1500));
}

/// Gets past the app lock: creates [testAppPin] on a fresh install (enter +
/// confirm) or unlocks with it, then waits for the home screen.
Future<void> unlockApp(WidgetTester tester, Type homeType) async {
  final home = find.byType(homeType);
  await pumpUntilFound(tester,
      find.byWidgetPredicate((w) => w is PinPad || w.runtimeType == homeType),
      timeout: const Duration(seconds: 30));
  for (var round = 0; round < 2 && home.evaluate().isEmpty; round++) {
    await enterPin(tester, testAppPin);
  }
  await pumpUntilFound(tester, home);
  // Don't let the "PIN saved" message cover buttons the test taps next.
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
      .clearSnackBars();
  await tester.pump(const Duration(milliseconds: 300));
}
