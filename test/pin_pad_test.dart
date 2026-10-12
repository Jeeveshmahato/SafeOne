import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_app/widgets/pin_pad.dart';

void main() {
  // Each digit's position on screen, top-left first.
  List<String> layout(WidgetTester tester) {
    final digits = [for (var i = 0; i < 10; i++) '$i'];
    final found = [for (final d in digits) (d, tester.getCenter(find.text(d)))]
      ..sort(
        (a, b) => a.$2.dy != b.$2.dy
            ? a.$2.dy.compareTo(b.$2.dy)
            : a.$2.dx.compareTo(b.$2.dx),
      );
    return [for (final f in found) f.$1];
  }

  Future<void> pump(
    WidgetTester tester,
    String value, {
    bool scramble = false,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PinPad(value: value, scramble: scramble, onChanged: (_) {}),
        ),
      ),
    ),
  );

  testWidgets('keys are in the normal phone order', (tester) async {
    await pump(tester, '');
    const normal = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    expect(layout(tester), normal);

    // Still the same after a wrong PIN clears the entry.
    await pump(tester, '1234');
    await pump(tester, '');
    expect(layout(tester), normal);
  });

  testWidgets('a shuffled keypad (contacts PIN) changes every attempt', (
    tester,
  ) async {
    await pump(tester, '', scramble: true);
    final layouts = {layout(tester).join()};
    for (var i = 0; i < 5; i++) {
      await pump(tester, '12', scramble: true);
      await pump(tester, '', scramble: true);
      layouts.add(layout(tester).join());
    }
    // Ten digits each time, in (almost surely) different orders.
    expect(layouts.every((l) => l.split('').toSet().length == 10), isTrue);
    expect(layouts.length, greaterThan(1));
  });
}
