import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:women_safety_app/models/medical_info.dart';
import 'package:women_safety_app/models/safety_event.dart';
import 'package:women_safety_app/services/app_lock_service.dart';
import 'package:women_safety_app/services/medical_repository.dart';
import 'package:women_safety_app/services/safety_event_repository.dart';
import 'package:women_safety_app/services/vault.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // An in-memory stand-in for the OS keystore.
  const secureChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  // A stand-in for the phone's secure chip: an HMAC key the app can use but
  // never read, plus a recovery key that needs the owner's screen lock.
  const vaultChannel = MethodChannel('com.safeone.app/vault');

  late Map<String, String> keystore;
  late List<int> chipSecret;
  late bool ownerJustAuthenticated;
  late bool phoneHasScreenLock;

  setUp(() {
    keystore = {};
    chipSecret = utf8.encode('this-phone-only');
    ownerJustAuthenticated = false;
    phoneHasScreenLock = true;
    SharedPreferences.setMockInitialValues({});
    Vault.instance.lock();
    messenger.setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map).cast<String, dynamic>();
      final key = args['key'] as String?;
      switch (call.method) {
        case 'read':
          return keystore[key];
        case 'write':
          keystore[key!] = args['value'] as String;
        case 'delete':
          keystore.remove(key);
        case 'deleteAll':
          keystore.clear();
      }
      return null;
    });
    messenger.setMockMethodCallHandler(vaultChannel, (call) async {
      final data = (call.arguments as Map?)?['data'] as Uint8List?;
      switch (call.method) {
        case 'bind':
          return Uint8List.fromList(Hmac(sha256, chipSecret).convert(data!).bytes);
        case 'ensureRecovery':
          return phoneHasScreenLock;
        case 'recoveryWrap':
          return Uint8List.fromList(data!.reversed.toList());
        case 'recoveryUnwrap':
          if (!ownerJustAuthenticated) {
            throw PlatformException(code: 'not_authenticated');
          }
          return Uint8List.fromList(data!.reversed.toList());
      }
      return null;
    });
  });

  Future<Map<String, Object>> prefsDump() async {
    final prefs = await SharedPreferences.getInstance();
    return {for (final k in prefs.getKeys()) k: prefs.get(k)!};
  }

  group('PIN', () {
    test('stores only a hardware-bound verifier, never the PIN', () async {
      final lock = AppLockService();
      await lock.setPin('482915');
      expect(await lock.isPinSet(), isTrue);
      expect(keystore['lock_pin_hash'], startsWith('v3\$hw\$'));
      final everything = [...keystore.values, ...(await prefsDump()).values];
      expect(everything.any((v) => '$v'.contains('482915')), isFalse);
      expect((await lock.attempt('482915')).success, isTrue);
      expect((await lock.attempt('482916')).success, isFalse);
    });

    test('easy PINs are allowed', () async {
      final lock = AppLockService();
      for (final pin in ['111111', '123456', '000000']) {
        await lock.setPin(pin);
        expect((await lock.attempt(pin)).success, isTrue, reason: pin);
      }
    });

    test('a copy of the data is useless on another phone', () async {
      await AppLockService().setPin('482915');
      // Same stored files, different secure chip.
      chipSecret = utf8.encode('attackers-phone');
      expect((await AppLockService().attempt('482915')).success, isFalse);
    });

    test('upgrades a v1.2 SHA-256 PIN hash on the next correct entry',
        () async {
      const salt = 'legacy-salt';
      keystore['lock_pin_salt'] = salt;
      keystore['lock_pin_hash'] =
          sha256.convert(utf8.encode('$salt:482915')).toString();
      final lock = AppLockService();

      expect((await lock.attempt('000000')).success, isFalse);
      expect((await lock.attempt('482915')).success, isTrue);
      expect(keystore['lock_pin_hash'], startsWith('v3\$'));
      expect((await lock.attempt('482915')).success, isTrue);
    });

    test('app and contacts PINs are independent', () async {
      final lock = AppLockService();
      await lock.setPin('482915', PinKind.app);
      expect(await lock.isPinSet(PinKind.contacts), isFalse);
      await lock.setPin('730264', PinKind.contacts);

      expect((await lock.attempt('730264', PinKind.app)).success, isFalse);
      expect((await lock.attempt('482915', PinKind.contacts)).success, isFalse);
      expect((await lock.attempt('730264', PinKind.contacts)).success, isTrue);
    });

    test('wrong attempts lock out, survive a restart, and block correct PINs',
        () async {
      await AppLockService().setPin('482915');
      for (var i = 0; i < AppLockService.freeAttempts; i++) {
        final r = await AppLockService().attempt('111111');
        expect(r.lockedOut, isFalse, reason: 'attempt ${i + 1} is free');
      }
      final r = await AppLockService().attempt('111111');
      expect(r.lockout, AppLockService.lockoutSteps.first);

      final fresh = AppLockService();
      expect(await fresh.lockoutRemaining(), greaterThan(Duration.zero));
      final blocked = await fresh.attempt('482915');
      expect(blocked.success, isFalse);
      expect(blocked.lockedOut, isTrue);
    });

    test('a moved-back clock never means waiting longer than the max step',
        () async {
      final far = DateTime.now().add(const Duration(days: 30));
      keystore['lock_pin_locked_until'] = '${far.millisecondsSinceEpoch}';
      expect(await AppLockService().lockoutRemaining(),
          AppLockService.lockoutSteps.last);
    });
  });

  group('Vault', () {
    const medical = 'medical_info';

    test('private data is encrypted at rest and unreadable while locked',
        () async {
      await AppLockService().setPin('482915');
      await MedicalRepository().save(const MedicalInfo(notes: 'Allergic to penicillin'));

      final stored = (await prefsDump())[medical] as String;
      expect(Vault.isSealed(stored), isTrue);
      expect(stored.contains('penicillin'), isFalse);

      Vault.instance.lock();
      await expectLater(
          MedicalRepository().load(), throwsA(isA<VaultLockedException>()));

      expect((await AppLockService().attempt('482915')).success, isTrue);
      expect((await MedicalRepository().load()).notes,
          'Allergic to penicillin');
    });

    test('a wrong PIN never opens the vault', () async {
      await AppLockService().setPin('482915');
      Vault.instance.lock();
      await AppLockService().attempt('482916');
      expect(Vault.instance.isOpen, isFalse);
    });

    test('plain-text data from older versions is encrypted on upgrade',
        () async {
      const salt = 'legacy-salt';
      keystore['lock_pin_salt'] = salt;
      keystore['lock_pin_hash'] =
          sha256.convert(utf8.encode('$salt:482915')).toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(medical, '{"notes":"Asthma"}');

      expect((await AppLockService().attempt('482915')).success, isTrue);
      final stored = prefs.getString(medical)!;
      expect(Vault.isSealed(stored), isTrue);
      expect((await MedicalRepository().load()).notes, 'Asthma');
    });

    test('changing the PIN keeps the data and retires the old PIN', () async {
      final lock = AppLockService();
      await lock.setPin('482915');
      await MedicalRepository()
          .save(const MedicalInfo(notes: 'Diabetic'));
      await lock.setPin('593017'); // vault is open: re-wrapped

      Vault.instance.lock();
      expect((await lock.attempt('482915')).success, isFalse);
      expect(Vault.instance.isOpen, isFalse);
      expect((await lock.attempt('593017')).success, isTrue);
      expect((await MedicalRepository().load()).notes, 'Diabetic');
    });

    test('setting a new PIN while the vault is locked is refused', () async {
      await AppLockService().setPin('482915');
      Vault.instance.lock();
      await expectLater(AppLockService().setPin('000000'),
          throwsA(isA<VaultLockedException>()));
    });

    test('screen-lock recovery opens the data only after the owner authenticates',
        () async {
      await AppLockService().setPin('482915');
      await MedicalRepository()
          .save(const MedicalInfo(notes: 'O negative'));
      Vault.instance.lock();

      expect(await Vault.instance.openWithRecovery(),
          RecoveryResult.needsStrongAuth);
      expect(Vault.instance.isOpen, isFalse);

      ownerJustAuthenticated = true;
      expect(await Vault.instance.openWithRecovery(), RecoveryResult.opened);
      // Forgot-PIN flow: choose a new PIN, the data survives.
      await AppLockService().setPin('111111');
      Vault.instance.lock();
      expect((await AppLockService().attempt('111111')).success, isTrue);
      expect((await MedicalRepository().load()).notes, 'O negative');
    });

    test('no screen lock means no recovery: only the PIN opens the data',
        () async {
      phoneHasScreenLock = false;
      await AppLockService().setPin('482915');
      Vault.instance.lock();
      ownerJustAuthenticated = true;
      expect(await Vault.instance.openWithRecovery(),
          RecoveryResult.unavailable);
    });

    test('an SOS logged while locked is kept and merged at unlock', () async {
      await AppLockService().setPin('482915');
      final log = SafetyEventRepository();
      await log.log(SafetyEventType.sos, 'first');
      Vault.instance.lock();

      await log.log(SafetyEventType.sos, 'while locked',
          location: '12.97,77.59');
      final dump = await prefsDump();
      expect('$dump'.contains('12.97'), isFalse,
          reason: 'locked writes are encrypted too');
      await expectLater(log.load(), throwsA(isA<VaultLockedException>()));

      await AppLockService().attempt('482915');
      final events = await log.load();
      expect(events.map((e) => e.description),
          containsAll(['first', 'while locked']));
    });
  });
}
