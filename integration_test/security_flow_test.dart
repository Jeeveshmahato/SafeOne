// On-device test of the app lock and the contacts PIN.
//
// Run with:  flutter test integration_test/security_flow_test.dart
//
// Starts from a clean install state (it erases SafeOne's stored data first).

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/main.dart' as app;
import 'package:women_safety_app/screens/contacts_screen.dart';
import 'package:women_safety_app/screens/home_screen.dart';
import 'package:women_safety_app/screens/lock_screen.dart';
import 'package:women_safety_app/services/notification_service.dart';
import 'package:women_safety_app/services/vault.dart';

import 'pin_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const contactsPin = '730264';

  testWidgets('contacts PIN guards the list, and re-lock covers open screens',
      (tester) async {
    await (await SharedPreferences.getInstance()).clear();
    await const FlutterSecureStorage().deleteAll();

    await app.main();
    await pumpUntilFound(tester, find.text('Create a 6-digit PIN'));

    // ---- First run: create the app PIN.
    await enterPin(tester, testAppPin);
    await enterPin(tester, testAppPin);
    await pumpUntilFound(tester, find.byType(HomeScreen));

    // The PIN check is bound to the phone's secure hardware, and the
    // encrypted vault exists.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(prefs.getString('lock_pin_hash'), startsWith('v3\$hw\$'));
    expect(prefs.getString('vault_public_key'), isNotNull);
    expect(Vault.instance.isOpen, isTrue);

    // ---- Open Contacts and try to add someone: the contacts PIN is created.
    // Pushed on the root navigator, exactly like the home screen opens it.
    rootNavigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const ContactsScreen()));
    await pumpUntilFound(tester, find.byType(ContactsScreen));
    await tester.tap(find.text('Add contact'));
    await pumpUntilFound(tester, find.text('Set a contacts PIN'));

    // Re-using the app PIN is refused.
    await enterPin(tester, testAppPin);
    await pumpUntilFound(
        tester, find.text("Choose a PIN that's different from your app PIN."));

    await enterPin(tester, contactsPin);
    await enterPin(tester, contactsPin);

    // ---- The add-contact form opens straight after.
    await pumpUntilFound(tester, find.byType(AlertDialog));
    await tester.enterText(find.byType(TextFormField).at(0), 'Asha');
    await tester.enterText(find.byType(TextFormField).at(1), 'not a number');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text("That number doesn't look right"), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '+91 98765 43210');
    await tester.tap(find.text('Save'));
    await pumpUntilFound(tester, find.text('+919876543210'));

    // ---- Leave the app and come back: the lock must cover Contacts.
    // The same sequence Android reports when the user presses Home and
    // comes back.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await pumpUntilFound(tester, find.byType(LockScreen));
    expect(Vault.instance.isOpen, isFalse,
        reason: 'Locking must drop the key to the encrypted data');
    // Messages and the keyboard from before the lock must not stay on the
    // lock screen. (Wait for the keyboard to finish closing.)
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsNothing);
    expect(FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()));
    expect(find.text('+919876543210'), findsNothing,
        reason: 'Contacts must not be visible while locked');

    // A wrong PIN doesn't unlock; the right one returns to Contacts.
    await enterPin(tester, '730265');
    await pumpUntilFound(tester, find.text('Wrong PIN. Try again.'));
    await enterPin(tester, testAppPin);
    await pumpUntilFound(tester, find.text('+919876543210'));

    // ---- Leaving the app also forgot the contacts PIN: removing asks again.
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await pumpUntilFound(tester, find.text('Enter contacts PIN'));
    await enterPin(tester, contactsPin);
    await pumpUntilFound(tester, find.text('Asha removed'));
    expect(find.text('+919876543210'), findsNothing);
  });
}
