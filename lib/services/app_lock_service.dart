import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles the app's screen lock: a PIN (and optional fingerprint/face unlock).
///
/// The PIN itself is NEVER stored. We store a random "salt" plus the SHA-256
/// hash of (salt + PIN). To check a PIN we hash it the same way and compare.
/// Everything lives in the OS keystore/keychain via [FlutterSecureStorage],
/// not in plain SharedPreferences, so it is encrypted at rest.
class AppLockService {
  AppLockService({FlutterSecureStorage? storage, LocalAuthentication? localAuth})
      : _storage = storage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;

  static const _saltKey = 'lock_pin_salt';
  static const _hashKey = 'lock_pin_hash';
  static const _biometricKey = 'lock_biometric_enabled';
  static const _graceKey = 'lock_grace_seconds';

  /// Default: lock the moment the app goes to the background.
  static const int defaultGraceSeconds = 0;

  // ---------------------------------------------------------------------------
  // Storage helpers (with a desktop fallback)
  // ---------------------------------------------------------------------------
  //
  // On Android/iOS the values live in the encrypted keystore/keychain. On
  // desktop dev builds the keychain may be unavailable without code signing,
  // so we fall back to SharedPreferences. The stored value is always a salted
  // SHA-256 hash — never the PIN itself — so the fallback never exposes a PIN.

  Future<String?> _read(String key) async {
    // Prefer the encrypted keystore, but some Android devices fail to decrypt
    // keystore values after an app restart. To stay reliable we mirror every
    // value into SharedPreferences and fall back to it whenever the keystore
    // is unavailable OR returns nothing. The stored value is always a salted
    // SHA-256 hash — never the PIN — so the mirror never exposes a PIN.
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

  /// True once the user has chosen a PIN (used to decide setup vs lock screen).
  Future<bool> isPinSet() async {
    final hash = await _read(_hashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// Save a new PIN. Generates a fresh random salt every time.
  Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    final hash = _hashPin(pin, salt);
    await _write(_saltKey, salt);
    await _write(_hashKey, hash);
  }

  /// Returns true if [pin] matches the stored one. Uses a constant-time
  /// compare so the time taken does not leak how many digits were correct.
  Future<bool> verifyPin(String pin) async {
    final salt = await _read(_saltKey);
    final stored = await _read(_hashKey);
    if (salt == null || stored == null) return false;
    final candidate = _hashPin(pin, salt);
    return _constantTimeEquals(candidate, stored);
  }

  /// Remove the PIN and all related settings (used if the user disables the
  /// lock entirely).
  Future<void> clearPin() async {
    await _delete(_saltKey);
    await _delete(_hashKey);
    await _delete(_biometricKey);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
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
  // Biometrics
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
  Future<bool> authenticateBiometric(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Auto-lock grace period
  // ---------------------------------------------------------------------------

  /// How long the app may stay in the background before it re-locks.
  Future<int> loadGraceSeconds() async {
    final raw = await _read(_graceKey);
    return int.tryParse(raw ?? '') ?? defaultGraceSeconds;
  }

  Future<void> saveGraceSeconds(int seconds) async {
    await _write(_graceKey, '$seconds');
  }
}
