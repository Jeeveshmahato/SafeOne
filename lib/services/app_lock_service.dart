import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vault.dart';

/// The app has two independent PINs:
///   * [app]      — unlocks SafeOne itself.
///   * [contacts] — a second PIN needed to add or remove emergency contacts,
///     so someone who gets hold of the unlocked app still can't quietly take
///     people off the SOS list.
enum PinKind { app, contacts }

/// Result of one PIN attempt.
class PinAttempt {
  const PinAttempt._(this.success, this.lockout);

  const PinAttempt.ok() : this._(true, Duration.zero);
  const PinAttempt.wrong(Duration lockout) : this._(false, lockout);

  final bool success;

  /// How long the user must wait before the next attempt (zero = no wait).
  final Duration lockout;

  bool get lockedOut => lockout > Duration.zero;
}

/// Handles the app's PINs (and optional fingerprint/face unlock).
///
/// The PIN itself is NEVER stored. A PIN check goes:
///   1. PBKDF2-HMAC-SHA256 of the PIN with a random salt (deliberately slow);
///   2. mixed with a key inside the phone's secure hardware ([HardwareBinding])
///      that can't be extracted, even with root;
///   3. stored only as an HMAC "verifier" of that result.
/// Because of step 2, a copy of the stored data can't be brute-forced on a
/// computer: every guess has to run on this phone's chip.
///
/// The correct app PIN also yields the key that opens the encrypted [Vault].
///
/// Wrong attempts are counted in storage (not in memory), so killing and
/// reopening the app does not reset the brute-force delay.
class AppLockService {
  AppLockService({FlutterSecureStorage? storage, LocalAuthentication? localAuth})
      : _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _biometricKey = 'lock_biometric_enabled';
  static const _graceKey = 'lock_grace_seconds';

  /// Default: lock the moment the app goes to the background.
  static const int defaultGraceSeconds = 0;

  /// PBKDF2 work factor. Stored with each hash, so it can be raised later and
  /// old hashes still verify (they are upgraded on the next correct entry).
  static const int pbkdf2Iterations = 50000;
  static const String _v3Prefix = 'v3';
  static const String _legacyPbkdf2Prefix = 'pbkdf2-sha256';

  /// Wrong attempts allowed before any delay kicks in.
  static const int freeAttempts = 4;

  /// Delays after the free attempts run out: 30s, 1m, 5m, then 15m each time.
  static const List<Duration> lockoutSteps = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  /// True while a system authentication screen (fingerprint, or the phone's
  /// own PIN/pattern) is showing. That screen pauses the app, which must not
  /// count as "the user left the app" for auto-lock.
  static bool systemPromptActive = false;

  // The app PIN keeps its original key names so existing installs still
  // unlock after an update.
  static String _saltKey(PinKind k) =>
      k == PinKind.app ? 'lock_pin_salt' : 'contacts_pin_salt';
  static String _hashKey(PinKind k) =>
      k == PinKind.app ? 'lock_pin_hash' : 'contacts_pin_hash';
  static String _failuresKey(PinKind k) =>
      k == PinKind.app ? 'lock_pin_failures' : 'contacts_pin_failures';
  static String _lockedUntilKey(PinKind k) =>
      k == PinKind.app ? 'lock_pin_locked_until' : 'contacts_pin_locked_until';

  // ---------------------------------------------------------------------------
  // Storage helpers (with a fallback)
  // ---------------------------------------------------------------------------

  Future<String?> _read(String key) async {
    // Prefer the encrypted keystore, but some Android devices fail to decrypt
    // keystore values after an app restart. To stay reliable we mirror every
    // value into SharedPreferences and fall back to it whenever the keystore
    // is unavailable OR returns nothing. Nothing stored here is secret on its
    // own: the PIN verifier is useless without this phone's hardware key.
    try {
      final secure = await _storage.read(key: key);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (_) {/* keystore unavailable — use the mirror */}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> _write(String key, String value) async {
    // Always mirror to prefs so reads are reliable; best-effort to keystore.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {/* keystore unavailable — mirror is enough */}
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {/* ignore */}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // ---------------------------------------------------------------------------
  // PIN
  // ---------------------------------------------------------------------------

  /// True once the user has chosen this PIN.
  Future<bool> isPinSet([PinKind kind = PinKind.app]) async {
    final hash = await _read(_hashKey(kind));
    return hash != null && hash.isNotEmpty;
  }

  /// Save a new PIN. Generates a fresh random salt every time, and clears any
  /// wrong-attempt delay (the user has just proved who they are).
  ///
  /// For the app PIN this also re-protects the data vault with the new PIN
  /// (or creates the vault on first setup). The vault must already be open
  /// if it exists: after the old PIN, or after the phone's screen lock.
  Future<void> setPin(String pin, [PinKind kind = PinKind.app]) async {
    final vault = Vault.instance;
    if (kind == PinKind.app && !vault.isOpen && await vault.exists()) {
      // A vault without an app PIN is left over from a setup that was
      // interrupted before the PIN was saved; it can never be opened.
      if (await isPinSet(PinKind.app)) throw VaultLockedException();
      await vault.discard();
    }
    final binding = await HardwareBinding.preferredKind();
    final salt = _randomSalt();
    final secret = await _pinSecret(pin, salt, pbkdf2Iterations, binding);
    final record = [
      _v3Prefix,
      binding,
      '$pbkdf2Iterations',
      base64Url.encode(_derive(secret, 'verify')),
    ].join(r'$');
    if (kind == PinKind.app) {
      final kek = _derive(secret, 'vault-kek');
      if (vault.isOpen) {
        await vault.rewrap(kek);
      } else {
        await vault.create(kek);
      }
    }
    await _write(_saltKey(kind), salt);
    await _write(_hashKey(kind), record);
    await clearFailures(kind);
  }

  /// Checks [pin], enforcing the wrong-attempt delay. While locked out the PIN
  /// is not even checked, so the delay can't be skipped by a faster UI.
  /// A correct app PIN also opens the data vault.
  Future<PinAttempt> attempt(String pin, [PinKind kind = PinKind.app]) async {
    final wait = await lockoutRemaining(kind);
    if (wait > Duration.zero) return PinAttempt.wrong(wait);
    if (await _matches(pin, kind)) {
      await clearFailures(kind);
      return const PinAttempt.ok();
    }
    return PinAttempt.wrong(await _recordFailure(kind));
  }

  Future<bool> _matches(String pin, PinKind kind) async {
    final salt = await _read(_saltKey(kind));
    final stored = await _read(_hashKey(kind));
    if (salt == null || stored == null) return false;
    final parts = stored.split(r'$');

    if (parts.length == 4 && parts[0] == _v3Prefix) {
      final iterations = int.tryParse(parts[2]);
      if (iterations == null) return false;
      final Uint8List secret;
      try {
        secret = await _pinSecret(pin, salt, iterations, parts[1]);
      } catch (_) {
        return false; // hardware key unavailable
      }
      final ok = _constantTimeEquals(
          base64Url.encode(_derive(secret, 'verify')), parts[3]);
      if (!ok) return false;
      if (kind == PinKind.app) await _openVault(secret);
      // Upgrade hashes made with a lower work factor.
      if (iterations < pbkdf2Iterations) await setPin(pin, kind);
      return true;
    }

    // Older formats: v1.3 PBKDF2 without hardware binding, and v1.2's single
    // SHA-256. On the first correct entry, re-hash with the current scheme
    // (which also creates the data vault and encrypts existing data).
    final bool ok;
    if (parts.length == 3 && parts[0] == _legacyPbkdf2Prefix) {
      final iterations = int.tryParse(parts[1]);
      if (iterations == null) return false;
      final key = await Isolate.run(
          () => _pbkdf2(utf8.encode(pin), utf8.encode(salt), iterations));
      ok = _constantTimeEquals(base64Url.encode(key), parts[2]);
    } else {
      final legacy = sha256.convert(utf8.encode('$salt:$pin')).toString();
      ok = _constantTimeEquals(legacy, stored);
    }
    if (ok) await setPin(pin, kind);
    return ok;
  }

  Future<void> _openVault(Uint8List secret) async {
    final vault = Vault.instance;
    final kek = _derive(secret, 'vault-kek');
    if (await vault.exists()) {
      await vault.openWithKek(kek);
    } else {
      await vault.create(kek);
    }
  }

  /// Remove a PIN and its attempt counter.
  Future<void> clearPin([PinKind kind = PinKind.app]) async {
    await _delete(_saltKey(kind));
    await _delete(_hashKey(kind));
    await clearFailures(kind);
    if (kind == PinKind.app) await _delete(_biometricKey);
  }

  /// Slow hash of the PIN on a background isolate, then bound to this
  /// phone's hardware key.
  static Future<Uint8List> _pinSecret(
      String pin, String salt, int iterations, String binding) async {
    final stretched = await Isolate.run(
        () => _pbkdf2(utf8.encode(pin), utf8.encode(salt), iterations));
    return HardwareBinding.bind(
        Uint8List.fromList([...utf8.encode('safeone-pin-v3:'), ...stretched]),
        binding);
  }

  /// Independent sub-keys of the PIN secret (verifier, vault key).
  static Uint8List _derive(Uint8List secret, String label) {
    return Uint8List.fromList(
        Hmac(sha256, secret).convert(utf8.encode('safeone-$label')).bytes);
  }

  /// PBKDF2-HMAC-SHA256 with a single 32-byte output block (RFC 8018).
  static List<int> _pbkdf2(List<int> password, List<int> salt, int iterations) {
    final hmac = Hmac(sha256, password);
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final result = List<int>.of(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  String _randomSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  // ---------------------------------------------------------------------------
  // Wrong-attempt throttling (persisted)
  // ---------------------------------------------------------------------------

  /// Time left before another attempt is allowed.
  Future<Duration> lockoutRemaining([PinKind kind = PinKind.app]) async {
    final until = int.tryParse(await _read(_lockedUntilKey(kind)) ?? '');
    if (until == null) return Duration.zero;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    if (left <= 0) return Duration.zero;
    // If the clock was moved backwards the deadline could be far in the
    // future; never make the user wait longer than the largest step.
    final max = lockoutSteps.last;
    return left > max.inMilliseconds ? max : Duration(milliseconds: left);
  }

  Future<Duration> _recordFailure(PinKind kind) async {
    final failures = (int.tryParse(await _read(_failuresKey(kind)) ?? '') ?? 0) + 1;
    await _write(_failuresKey(kind), '$failures');
    final over = failures - freeAttempts;
    if (over <= 0) return Duration.zero;
    final wait = lockoutSteps[min(over, lockoutSteps.length) - 1];
    final until = DateTime.now().add(wait).millisecondsSinceEpoch;
    await _write(_lockedUntilKey(kind), '$until');
    return wait;
  }

  Future<void> clearFailures([PinKind kind = PinKind.app]) async {
    await _delete(_failuresKey(kind));
    await _delete(_lockedUntilKey(kind));
  }

  // ---------------------------------------------------------------------------
  // Biometrics and the phone's own screen lock
  // ---------------------------------------------------------------------------

  /// True if the device actually has a fingerprint/face sensor set up.
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    return (await _read(_biometricKey)) == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _write(_biometricKey, enabled ? 'true' : 'false');
  }

  /// Prompt for fingerprint/face. Returns true if it succeeded.
  Future<bool> authenticateBiometric(String reason) {
    return _authenticate(reason, biometricOnly: true);
  }

  /// True if the phone has a screen lock (PIN, pattern, password or
  /// biometrics) that can be used to prove the owner is holding it.
  Future<bool> isDeviceSecure() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Ask for the phone's own screen lock (or biometrics). Used to reset a
  /// forgotten SafeOne PIN without a server.
  Future<bool> authenticateDevice(String reason) {
    return _authenticate(reason, biometricOnly: false);
  }

  Future<bool> _authenticate(String reason, {required bool biometricOnly}) async {
    systemPromptActive = true;
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    } finally {
      systemPromptActive = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Auto-lock grace period
  // ---------------------------------------------------------------------------

  /// The current grace period, kept in memory so the app gate can decide
  /// synchronously (the moment the app is backgrounded) whether to lock.
  static final ValueNotifier<int> graceSeconds =
      ValueNotifier<int>(defaultGraceSeconds);

  /// How long the app may stay in the background before it re-locks.
  Future<int> loadGraceSeconds() async {
    final raw = await _read(_graceKey);
    return graceSeconds.value = int.tryParse(raw ?? '') ?? defaultGraceSeconds;
  }

  Future<void> saveGraceSeconds(int seconds) async {
    graceSeconds.value = seconds;
    await _write(_graceKey, '$seconds');
  }

  /// Wipe everything this service stored (used by "Erase and start over").
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {/* keystore unavailable — prefs are cleared separately */}
  }
}
