// A simple smoke test: it just checks that the app builds and shows the lock
// gate (a PIN must be set on first run) without crashing.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:women_safety_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // flutter_secure_storage talks to a native plugin that isn't available in
  // the test environment, so we stub it to behave like "no PIN set yet".
  const secureStorage =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorage, (call) async => null);
  });

  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const WomenSafetyApp());
    await tester.pump();

    // The app shell is up.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
