import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// Where the approval key lives: its seed behind biometric access control,
/// and its DID without any, so naming the key never prompts.
abstract interface class UserVerificationKeyStorage {
  /// Reads the seed. Shows the biometric prompt.
  Future<String?> readSeed();

  /// Stores the seed behind biometric access control.
  Future<void> writeSeed(String seed);

  /// Reads the key's DID without prompting.
  Future<String?> readDid();

  /// Stores the key's DID.
  Future<void> writeDid(String did);

  /// Deletes the key.
  Future<void> delete();
}

/// [UserVerificationKeyStorage] in the platform keystore.
///
/// iOS: a Keychain item usable only with the currently enrolled biometrics,
/// on a device with a passcode, never synchronised; enrolling new
/// biometrics invalidates it. Android: a store of its own whose Keystore key
/// requires biometrics; an invalidated key resets only that store.
class SecureUserVerificationKeyStorage implements UserVerificationKeyStorage {
  /// Creates a [SecureUserVerificationKeyStorage]. [promptTitle] is shown in
  /// the Android biometric prompt.
  SecureUserVerificationKeyStorage({required String promptTitle})
    : _gated = FlutterSecureStorage(
        aOptions: AndroidOptions(
          enforceBiometrics: true,
          storageNamespace: _storeName,
          biometricPromptTitle: promptTitle,
        ),
        iOptions: const IOSOptions(
          accountName: _storeName,
          accessibility: KeychainAccessibility.passcode,
          accessControlFlags: [AccessControlFlag.biometryCurrentSet],
          synchronizable: false,
        ),
      ),
      _plain = const FlutterSecureStorage(
        aOptions: AndroidOptions(storageNamespace: '${_storeName}_did'),
        iOptions: IOSOptions(
          accountName: '${_storeName}_did',
          accessibility: KeychainAccessibility.unlocked_this_device,
          synchronizable: false,
        ),
      );

  static const _storeName = 'mpx_vtc_approval_key';
  static const _seedKey = 'seed';
  static const _didKey = 'did';

  final FlutterSecureStorage _gated;
  final FlutterSecureStorage _plain;

  @override
  Future<String?> readSeed() => _gated.read(key: _seedKey);

  @override
  Future<void> writeSeed(String seed) =>
      _gated.write(key: _seedKey, value: seed);

  @override
  Future<String?> readDid() => _plain.read(key: _didKey);

  @override
  Future<void> writeDid(String did) => _plain.write(key: _didKey, value: did);

  @override
  Future<void> delete() async {
    await _gated.delete(key: _seedKey);
    await _plain.delete(key: _didKey);
  }
}

/// The phone's biometric approval key: an Ed25519 `did:key` the member's VTA
/// knows as this device's user-verification key. Approving a sign-in signs
/// with it, which needs a fresh biometric check.
///
/// A software key behind biometric access control, not a Secure Enclave key:
/// the enclave holds only P-256 keys, and approvals are Ed25519.
class UserVerificationKey {
  /// Creates a [UserVerificationKey] kept in the given storage.
  UserVerificationKey(this._storage);

  final UserVerificationKeyStorage _storage;

  /// The key's DID, or null when the phone has no key yet.
  Future<String?> did() => _storage.readDid();

  /// Returns the key's DID, creating the key first if there is none.
  ///
  /// On Android, creating the key shows the biometric prompt once.
  Future<String> ensureKey() async {
    final existing = await _storage.readDid();
    if (existing != null) return existing;

    final key = Ed25519DidKeySigner.generate();
    await _storage.writeSeed(base64Url.encode(key.seed));
    await _storage.writeDid(key.did);
    return key.did;
  }

  /// Deletes the key, e.g. after it was lost; enrol a new one afterwards.
  Future<void> reset() => _storage.delete();

  /// A signer for approvals. Throws [UserVerificationException] with
  /// [UserVerificationError.lost] when the phone has no key.
  Future<TrustTaskSigner> signer() async {
    final did = await _storage.readDid();
    if (did == null) {
      throw const UserVerificationException(UserVerificationError.lost);
    }
    return _BiometricSigner(_storage, did);
  }
}

class _BiometricSigner implements TrustTaskSigner {
  _BiometricSigner(this._storage, this.did);

  static final _cancelled = RegExp(
    r'cancel|negative button|-128',
    caseSensitive: false,
  );

  final UserVerificationKeyStorage _storage;

  @override
  final String did;

  @override
  String get verificationMethod => '$did#${did.substring('did:key:'.length)}';

  @override
  Future<Uint8List> sign(Uint8List data) async {
    final String? encodedSeed;
    try {
      encodedSeed = await _storage.readSeed();
    } on PlatformException catch (error) {
      final text = '${error.code} ${error.message}';
      throw UserVerificationException(
        _cancelled.hasMatch(text)
            ? UserVerificationError.cancelled
            : UserVerificationError.unavailable,
      );
    }
    if (encodedSeed == null) {
      throw const UserVerificationException(UserVerificationError.lost);
    }

    final seed = Uint8List.fromList(base64Url.decode(encodedSeed));
    try {
      final key = Ed25519DidKeySigner.fromSeed(seed);
      if (key.did != did) {
        throw const UserVerificationException(UserVerificationError.lost);
      }
      return await key.sign(data);
    } finally {
      seed.fillRange(0, seed.length, 0);
    }
  }
}
