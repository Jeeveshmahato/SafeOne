// On-device smoke test for EVERY feature screen.
//
// Launches the real app and, for each tile in the home grid, opens the screen,
// confirms it rendered without crashing (a back button appears), then returns
// home. This exercises each screen's build()/initState() — where most runtime
// bugs (null derefs, bad plugin calls) surface.
//
// Run with:  flutter test integration_test/all_features_smoke_test.dart
//
// Tip: pre-grant runtime permissions so location/camera/mic screens don't block
// on native dialogs:
//   adb shell pm grant com.example.women_safety_app android.permission.ACCESS_FINE_LOCATION
//   adb shell pm grant com.example.women_safety_app android.permission.RECORD_AUDIO
//   adb shell pm grant com.example.women_safety_app android.permission.CAMERA

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:women_safety_app/main.dart' as app;
import 'package:women_safety_app/screens/home_screen.dart';

import 'pin_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Every navigable feature tile (tiles that push a new route). After the
  // feature curation these are the grouped hubs plus the standalone screens.
  const featureTiles = <String>[
    'Helplines',
    'Nearby help',
    'Fake call',
    'Live tracking',
    'Safety check-in',
    'Emergency profile',
    'Contacts',
    'Records',
    'Safety tips',
  ];

  /// Bounded pump: some screens run continuous timers/animations, so we never
  /// use pumpAndSettle (it could hang).
  Future<void> settle(WidgetTester tester,
      [Duration d = const Duration(milliseconds: 900)]) async {
    await tester.pump();
    await tester.pump(d);
  }

  /// Gets past the app lock. On the very first launch this creates a PIN
  /// (enter + confirm); on later launches it just unlocks with the same PIN.
  Future<void> unlock(WidgetTester tester) => unlockApp(tester, HomeScreen);

  testWidgets('opens every feature screen without crashing', (tester) async {
    app.main();
    await unlock(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    for (final label in featureTiles) {
      final tile = find.text(label);
      await tester.scrollUntilVisible(tile, 160,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(tile);
      await settle(tester);

      // A detail route opened if the root navigator can now pop. This works
      // even for screens with a custom/absent AppBar back button (e.g. the
      // Incident Log, which opens as a disguised calculator).
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      expect(nav.canPop(), isTrue,
          reason: 'Screen "$label" did not open (nothing to pop).');

      // Return home and confirm we're back at the root.
      nav.pop();
      await settle(tester);
      expect(nav.canPop(), isFalse,
          reason: 'Did not return home after "$label".');
      expect(find.byType(HomeScreen), findsOneWidget,
          reason: 'Home not visible after leaving "$label".');
    }
  });

  testWidgets('settings + language switch works', (tester) async {
    app.main();
    await unlock(tester);

    // Open settings via the gear icon.
    await tester.tap(find.byIcon(Icons.settings));
    await settle(tester);
    expect(find.text('Settings'), findsWidgets);

    // Open the language picker and switch to Hindi.
    await tester.tap(find.text('Language'));
    await settle(tester);
    await tester.tap(find.text('हिन्दी'));
    await settle(tester);

    // The settings title should now be in Hindi.
    expect(find.text('सेटिंग्स'), findsWidgets,
        reason: 'Language did not switch to Hindi.');

    // Switch back to English so we leave the app in a known state.
    await tester.tap(find.text('भाषा')); // "Language" in Hindi
    await settle(tester);
    await tester.tap(find.text('English'));
    await settle(tester);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('fake call: incoming -> accept -> ongoing -> hang up',
      (tester) async {
    app.main();
    await unlock(tester);

    final scrollable = find.byType(Scrollable).first;
    final tile = find.text('Fake call');
    await tester.scrollUntilVisible(tile, 160, scrollable: scrollable);
    await tester.tap(tile);
    await settle(tester);

    final startBtn = find.text('Start fake call');
    await tester.ensureVisible(startBtn);
    await tester.tap(startBtn);
    await settle(tester);

    expect(find.byIcon(Icons.call), findsOneWidget); // accept
    await tester.tap(find.byIcon(Icons.call));
    await settle(tester);
    expect(find.text('End call'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.call_end));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('End call'), findsNothing);
  });
}
