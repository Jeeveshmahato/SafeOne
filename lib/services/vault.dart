import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart' as hashing;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thrown when private data is read while the app is locked.
class VaultLockedException implements Exception {
  @override
  String toString() => 'The vault is locked';
}

/// Why opening the vault with the phone's screen lock didn't work.
enum RecoveryResult {
  opened,

  /// No vault yet (nothing is encrypted), so nothing needs unlocking.
  noVault,

  /// The owner must use the phone's PIN/pattern/password or a strong
  /// biometric first (a weak face unlock isn't enough).
  needsStrongAuth,

  /// Recovery can't work: no screen lock when the vault was made, or the
  /// screen lock was removed since. Only the SafeOne PIN opens the data.
  unavailable,
}

/// Mixes secrets with a key held in the phone's secure hardware.
///
/// On Android the key lives in the TEE/StrongBox and can't be extracted even
/// with root, so the PIN can only be guessed on this very phone, never on a
/// fast computer. Elsewhere it falls back to a random secret in the OS
/// keychain.
class HardwareBinding {
  HardwareBinding._();

  static const _channel = MethodChannel('com.safeone.app/vault');
  static const _softKey = 'vault_soft_binding';

  /// "hw" when the hardware key is used, "sw" for the keychain fallback.
  static Future<String> preferredKind() async {
    // Only Android implements the channel; elsewhere this throws.
    try {
      await _channel.invokeMethod<Uint8List>(
          'bind', {'data': Uint8List.fromList(const [0])});
      return 'hw';
    } catch (_) {
      return 'sw';
    }
  }

  /// HMAC of [data] with the binding key of [kind]. Throws if that key is
  /// unavailable (never silently switches kinds).
  static Future<Uint8List> bind(Uint8List data, String kind) async {
    if (kind == 'hw') {
      final out = await _channel.invokeMethod<Uint8List>('bind', {'data': data});
      if (out == null) throw StateError('hardware binding unavailable');
      return out;
    }
    final secret = await _softSecret();
    return Uint8List.fromList(hashing.Hmac(hashing.sha256, secret).convert(data).bytes);
  }

  static Future<List<int>> _softSecret() async {
    const storage = FlutterSecureStorage(
      // Never synced to iCloud or restored to another device.
      iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device),
    );
    final existing = await storage.read(key: _softKey);
    if (existing != null) return base64Decode(existing);
    final fresh = _randomBytes(32);
    await storage.write(key: _softKey, value: base64Encode(fresh));
    return fresh;
  }

  static Future<bool> ensureRecovery() async {
    try {
      return await _channel.invokeMethod<bool>('ensureRecovery') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List> recoveryWrap(Uint8List secret) async {
    final out =
        await _channel.invokeMethod<Uint8List>('recoveryWrap', {'data': secret});
    if (out == null) throw StateError('recovery unavailable');
    return out;
  }

  static Future<Uint8List> recoveryUnwrap(Uint8List blob) async {
    final out =
        await _channel.invokeMethod<Uint8List>('recoveryUnwrap', {'data': blob});
    if (out == null) throw StateError('recovery unavailable');
    return out;
  }

  static Future<void> deleteAll() async {
    try {
      await _channel.invokeMethod('deleteAll');
    } catch (_) {/* not Android */}
    try {
      await const FlutterSecureStorage().delete(key: _softKey);
    } catch (_) {/* keychain unavailable */}
  }
}

/// The encrypted store for everything private that the SOS doesn't need
/// while the phone is locked: medical info, the safety log, danger zones,
/// custom callers, recordings and photos.
///
/// How it works (the same idea as iOS "complete unless open" protection):
///   * The vault has an X25519 key pair. Data is SEALED with the public key,
///     so the app can still save things while locked (e.g. an SOS logged
///     from a shake), but only the private key can read them.
///   * The private key is stored only in encrypted form: once under a key
///     derived from the app PIN (bound to the phone's hardware), and once
///     under the hardware recovery key that needs the phone's own screen
///     lock. It is held in memory only while the app is unlocked.
///
/// So a copy of the phone's storage (rooted phone, forensic tool, lost
/// phone) reveals none of this data without the PIN or the phone's screen
/// lock.
class Vault {
  Vault._();
  static final Vault instance = Vault._();

  static const _pubKey = 'vault_public_key';
  static const _pinWrapKey = 'vault_private_pin';
  static const _recoveryWrapKey = 'vault_private_recovery';
  static const _sealedPrefix = 'sealed1:';

  /// Plain-text values saved by older versions, moved into the vault when it
  /// is created.
  static const migratedKeys = [
    'medical_info',
    'safety_events',
    'danger_zones',
    'custom_fake_callers',
  ];

  static final _x25519 = X25519();
  static final _aes = AesGcm.with256bits();
  static final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  SimpleKeyPair? _keyPair;

  bool get isOpen => _keyPair != null;

  Future<bool> exists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pubKey) != null && prefs.getString(_pinWrapKey) != null;
  }

  /// Make a new vault protected by [kek] and move older plain-text data in.
  Future<void> create(List<int> kek) async {
    final privateBytes = _randomBytes(32);
    final pair = await _x25519.newKeyPairFromSeed(privateBytes);
    final publicKey = await pair.extractPublicKey();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pubKey, base64Encode(publicKey.bytes));
    await prefs.setString(_pinWrapKey, await _wrap(kek, privateBytes));
    _keyPair = pair;
    await _storeRecovery(privateBytes);
    await _migratePlaintext();
  }

  /// Open with the key derived from the app PIN. False if it doesn't fit.
  Future<bool> openWithKek(List<int> kek) async {
    final prefs = await SharedPreferences.getInstance();
    final wrapped = prefs.getString(_pinWrapKey);
    if (wrapped == null) return false;
    try {
      final privateBytes = await _unwrap(kek, wrapped);
      _keyPair = await _x25519.newKeyPairFromSeed(privateBytes);
      // The phone may have gained a screen lock since the vault was made.
      if (prefs.getString(_recoveryWrapKey) == null) {
        await _storeRecovery(privateBytes);
      }
      return true;
    } on SecretBoxAuthenticationError {
      return false;
    }
  }

  /// Open with the hardware recovery key. Call right after the owner passed
  /// the phone's screen lock (or a strong biometric).
  Future<RecoveryResult> openWithRecovery() async {
    if (!await exists()) return RecoveryResult.noVault;
    final prefs = await SharedPreferences.getInstance();
    final wrapped = prefs.getString(_recoveryWrapKey);
    if (wrapped == null) return RecoveryResult.unavailable;
    try {
      final privateBytes =
          await HardwareBinding.recoveryUnwrap(base64Decode(wrapped));
      _keyPair = await _x25519.newKeyPairFromSeed(privateBytes);
      return RecoveryResult.opened;
    } on PlatformException catch (e) {
      return e.code == 'not_authenticated'
          ? RecoveryResult.needsStrongAuth
          : RecoveryResult.unavailable;
    } catch (_) {
      return RecoveryResult.unavailable;
    }
  }

  /// Re-protect the open vault with a new PIN key (PIN changed or reset).
  Future<void> rewrap(List<int> kek) async {
    final pair = _keyPair;
    if (pair == null) throw VaultLockedException();
    final privateBytes = await pair.extractPrivateKeyBytes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinWrapKey, await _wrap(kek, privateBytes));
  }

  /// Forget the private key (the app was locked).
  void lock() => _keyPair = null;

  Future<void> _storeRecovery(List<int> privateBytes) async {
    if (!await HardwareBinding.ensureRecovery()) return;
    try {
      final blob =
          await HardwareBinding.recoveryWrap(Uint8List.fromList(privateBytes));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recoveryWrapKey, base64Encode(blob));
    } catch (_) {/* recovery stays unavailable; the PIN still works */}
  }

  Future<void> _migratePlaintext() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in migratedKeys) {
      final value = prefs.getString(key);
      if (value != null && !value.startsWith(_sealedPrefix)) {
        await prefs.setString(key, await seal(value));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Sealing (public key in, private key out)
  // ---------------------------------------------------------------------------

  static bool isSealed(String value) => value.startsWith(_sealedPrefix);

  /// Encrypt [plaintext] so only the vault's private key can read it. Works
  /// while the app is locked.
  Future<String> seal(String plaintext) async {
    return _sealedPrefix +
        base64Encode(await sealBytes(utf8.encode(plaintext)));
  }

  Future<String> unseal(String sealed) async {
    if (!isSealed(sealed)) return sealed; // not migrated yet
    final bytes = base64Decode(sealed.substring(_sealedPrefix.length));
    return utf8.decode(await unsealBytes(bytes));
  }

  /// Layout: version(1) | ephemeral public key(32) | nonce(12) | ciphertext |
  /// tag(16). The AES key comes from X25519 + HKDF over both public keys.
  Future<Uint8List> sealBytes(List<int> plaintext) async {
    final prefs = await SharedPreferences.getInstance();
    final pubText = prefs.getString(_pubKey);
    if (pubText == null) throw StateError('no vault');
    final recipient =
        SimplePublicKey(base64Decode(pubText), type: KeyPairType.x25519);
    final ephemeral = await _x25519.newKeyPair();
    final ephemeralPublic = await ephemeral.extractPublicKey();
    final key = await _sharedKey(ephemeral, recipient, ephemeralPublic.bytes,
        recipient.bytes);
    final box = await _aes.encrypt(plaintext,
        secretKey: key, aad: const [1]);
    return Uint8List.fromList(
        [1, ...ephemeralPublic.bytes, ...box.nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  Future<List<int>> unsealBytes(Uint8List data) async {
    final pair = _keyPair;
    if (pair == null) throw VaultLockedException();
    if (data.isEmpty || data[0] != 1) throw const FormatException('unknown format');
    final ephemeralPublic = data.sublist(1, 33);
    final nonce = data.sublist(33, 45);
    final cipherText = data.sublist(45, data.length - 16);
    final mac = Mac(data.sublist(data.length - 16));
    final own = await pair.extractPublicKey();
    final key = await _sharedKey(
        pair,
        SimplePublicKey(ephemeralPublic, type: KeyPairType.x25519),
        ephemeralPublic,
        own.bytes);
    return _aes.decrypt(SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: key, aad: const [1]);
  }

  Future<SecretKey> _sharedKey(KeyPair own, SimplePublicKey other,
      List<int> ephemeralPublic, List<int> recipientPublic) async {
    final shared =
        await _x25519.sharedSecretKey(keyPair: own, remotePublicKey: other);
    return _hkdf.deriveKey(
      secretKey: shared,
      nonce: [...ephemeralPublic, ...recipientPublic],
      info: utf8.encode('safeone-seal-v1'),
    );
  }

  /// Encrypt a file in place: writes `<path>.sealed` and deletes the
  /// original. Returns the new path.
  Future<String> sealFile(String path) async {
    final file = File(path);
    final sealed = await sealBytes(await file.readAsBytes());
    final out = File('$path.sealed');
    await out.writeAsBytes(sealed, flush: true);
    await _overwriteAndDelete(file);
    return out.path;
  }

  /// Best-effort: overwrite before deleting so the plain bytes are less
  /// likely to linger on flash storage.
  static Future<void> _overwriteAndDelete(File file) async {
    try {
      final length = await file.length();
      await file.writeAsBytes(Uint8List(length), flush: true);
    } catch (_) {/* fall through to delete */}
    try {
      await file.delete();
    } catch (_) {/* already gone */}
  }

  // ---------------------------------------------------------------------------
  // Wrapping the private key under a PIN-derived key
  // ---------------------------------------------------------------------------

  Future<String> _wrap(List<int> kek, List<int> secret) async {
    final box = await _aes.encrypt(secret,
        secretKey: SecretKey(kek), aad: utf8.encode('safeone-vault-v1'));
    return base64Encode(box.concatenation());
  }

  Future<List<int>> _unwrap(List<int> kek, String wrapped) async {
    final box = SecretBox.fromConcatenation(base64Decode(wrapped),
        nonceLength: 12, macLength: 16);
    return _aes.decrypt(box,
        secretKey: SecretKey(kek), aad: utf8.encode('safeone-vault-v1'));
  }

  /// Drop a vault that can't be opened, with the data sealed into it.
  Future<void> discard() async {
    _keyPair = null;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_pubKey, _pinWrapKey, _recoveryWrapKey, ...migratedKeys]) {
      await prefs.remove(key);
    }
  }

  /// Remove the vault keys (used by "Erase and start over").
  Future<void> deleteAll() async {
    _keyPair = null;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_pubKey, _pinWrapKey, _recoveryWrapKey]) {
      await prefs.remove(key);
    }
    await HardwareBinding.deleteAll();
  }
}

/// Reads and writes one private value through the [Vault].
class SecureStore {
  SecureStore._();

  /// The stored text, decrypted. Throws [VaultLockedException] while locked.
  static Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null) return null;
    if (!Vault.isSealed(value)) return value;
    return Vault.instance.unseal(value);
  }

  /// Save [value] encrypted. Works while locked.
  static Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final vault = Vault.instance;
    // Before the first PIN exists there is no vault, and nothing private
    // can have been entered yet.
    final stored = await vault.exists() ? await vault.seal(value) : value;
    await prefs.setString(key, stored);
  }
}

Uint8List _randomBytes(int length) {
  final rng = Random.secure();
  return Uint8List.fromList(List<int>.generate(length, (_) => rng.nextInt(256)));
}
