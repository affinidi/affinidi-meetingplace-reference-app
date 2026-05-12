import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart' hide KeyPair;

import '../providers/app_logger_provider.dart';
import '../providers/shared_preferences_provider.dart';

enum _Key {
  mediatorDid,
  debugMode,
  databasePassphrase,
  pushNotificationToken,
  showMeetingPlaceQr,
}

/// Secure storage wrapper implementing [KeyRepository] and [KeyStore].
///
/// Provides encrypted storage for:
/// - Wallet seeds and key pairs
/// - Mediator DIDs and account indices
/// - Database passphrases
/// - Application preferences (debug mode, QR display flags)
///
/// Uses platform-specific secure storage:
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain with device-unlock accessibility
class SecureStorage implements KeyRepository, KeyStore {
  /// Creates a [SecureStorage] instance with optional custom storage.
  ///
  /// [secureStorage] - Custom [FlutterSecureStorage] instance.
  /// If null, uses platform-configured defaults.
  SecureStorage([FlutterSecureStorage? secureStorage])
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
              synchronizable: false,
            ),
          );

  Future<String>? _passphraseFuture;

  final FlutterSecureStorage _secureStorage;

  static final _didPrefix = 'did_';
  static final _indexPrefix = 'index_';
  static final _keyPairIndex = 'keypair_';

  /// Retrieves a stored key by [key] identifier.
  ///
  /// Returns null if the key doesn't exist.
  @override
  Future<StoredKey?> get(String key) async {
    final jsonString = await _secureStorage.read(key: key);
    if (jsonString == null) return null;

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return StoredKey.fromJson(json);
  }

  /// Stores a [value] under the given [key].
  @override
  Future<void> set(String key, StoredKey value) async {
    await _secureStorage.write(key: key, value: jsonEncode(value));
  }

  /// Checks if a [key] exists in storage.
  @override
  Future<bool> contains(String key) => _secureStorage.containsKey(key: key);

  /// Removes the entry for the given [key].
  @override
  Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clears all stored data from secure storage.
  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }

  /// Gets the keyId associated with the given [did].
  ///
  /// Returns null if no keyId is found for the DID.
  @override
  Future<String?> getKeyIdByDid({required String did}) =>
      _secureStorage.read(key: '$_didPrefix$did');

  /// Associates a [keyId] with the given [did].
  @override
  Future<void> saveKeyIdForDid({required String keyId, required String did}) =>
      _secureStorage.write(key: '$_didPrefix$did', value: keyId);

  /// Gets the last used account index.
  ///
  /// Defaults to 1 if no index is stored.
  @override
  Future<int> getLastAccountIndex() async {
    final value = await _secureStorage.read(key: _indexPrefix);
    return int.tryParse(value ?? '') ?? 1;
  }

  /// Sets the last used account [index].
  @override
  Future<void> setLastAccountIndex(int index) {
    return _secureStorage.write(key: _indexPrefix, value: '$index');
  }

  /// Gets the preferred mediator DID.
  ///
  /// Returns null if no mediator DID is configured.
  Future<String?> getPreferredMediatorDid() async {
    final value = await _secureStorage.read(key: _Key.mediatorDid.name);
    return value;
  }

  /// Sets the preferred mediator DID.
  Future<void> setPreferredMediatorDid(String value) {
    return _secureStorage.write(key: _Key.mediatorDid.name, value: value);
  }

  /// Gets the debug mode flag.
  ///
  /// Returns null if no debug mode preference is set.
  Future<bool?> getDebugMode() async {
    final value = await _secureStorage.read(key: _Key.debugMode.name);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Sets the debug mode flag.
  Future<void> saveDebugMode(bool debugMode) {
    return _secureStorage.write(
      key: _Key.debugMode.name,
      value: debugMode.toString(),
    );
  }

  /// Gets the meeting place QR code display preference.
  ///
  /// Returns null if no preference is set.
  Future<bool?> getShouldShowMeetingPlaceQR() async {
    final value = await _secureStorage.read(key: _Key.showMeetingPlaceQr.name);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Sets the meeting place QR code display preference.
  Future<void> saveShouldShowMeetingPlaceQR(bool showQr) {
    return _secureStorage.write(
      key: _Key.showMeetingPlaceQr.name,
      value: showQr.toString(),
    );
  }

  /// Provides a database passphrase, creating one if needed.
  ///
  /// Thread-safe: multiple calls return the same passphrase instance.
  /// The passphrase is a 32-byte base64url-encoded random string.
  Future<String> provideDatabasePassphrase() async {
    _passphraseFuture ??= _loadOrCreatePassphrase();
    try {
      return await _passphraseFuture!;
    } finally {
      _passphraseFuture = null;
    }
  }

  /// Loads existing passphrase or creates a new 32-byte random one.
  Future<String> _loadOrCreatePassphrase() async {
    var passphrase = await _secureStorage.read(
      key: _Key.databasePassphrase.name,
    );
    if (passphrase?.isNotEmpty == true) return passphrase!;

    passphrase = _generateRandomPassphrase();
    await _secureStorage.write(
      key: _Key.databasePassphrase.name,
      value: passphrase,
    );
    return passphrase;
  }

  /// Generates cryptographically secure random bytes.
  Uint8List _generateRandomBytes(int length) {
    final rng = math.Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  /// Generates a base64url-encoded random passphrase.
  ///
  /// [length] - Number of random bytes to generate (default: 32).
  String _generateRandomPassphrase([int length = 32]) {
    final bytes = _generateRandomBytes(length);
    return base64Url.encode(bytes);
  }

  /// Gets a key pair associated with the given [did].
  ///
  /// Returns null if no key pair exists for the DID.
  @override
  Future<KeyPair?> getKeyPair(String did) async {
    final value = await _secureStorage.read(key: '$_keyPairIndex$did');
    if (value == null) return null;
    return KeyPair.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  /// Saves a key pair for the given [did].
  @override
  Future<void> saveKeyPair({
    required Uint8List privateKeyBytes,
    required Uint8List publicKeyBytes,
    required String did,
  }) {
    return _secureStorage.write(
      key: '$_keyPairIndex$did',
      value: jsonEncode({
        'privateKeyBytes': privateKeyBytes,
        'publicKeyBytes': publicKeyBytes,
      }),
    );
  }

  /// Gets the stored push notification token.
  ///
  /// Returns null if no token is stored.
  Future<String?> getPushNotificationToken() async {
    return await _secureStorage.read(key: _Key.pushNotificationToken.name);
  }

  /// Saves the push notification token to secure storage.
  Future<void> savePushNotificationToken(String pushNotificationToken) async {
    await _secureStorage.write(
      key: _Key.pushNotificationToken.name,
      value: pushNotificationToken,
    );
  }

  /// Gets all unsent messages stored in secure storage.
  ///
  /// Returns a map of contact IDs to unsent message text.
  /// Returns an empty map if no unsent messages are stored.
  Future<Map<String, String>> getUnsentMessages() async {
    final json = await _secureStorage.read(key: 'unsent_messages');
    if (json == null || json.isEmpty) return {};

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return Map<String, String>.from(decoded);
    } catch (e) {
      return {};
    }
  }

  /// Saves unsent messages to secure storage.
  ///
  /// [messages] - Map of contact IDs to unsent message text.
  /// If the map is empty, the stored data will be deleted.
  Future<void> saveUnsentMessages(Map<String, String> messages) async {
    if (messages.isEmpty) {
      await _secureStorage.delete(key: 'unsent_messages');
    } else {
      final json = jsonEncode(messages);
      await _secureStorage.write(key: 'unsent_messages', value: json);
    }
  }

  /// Clears all unsent messages from secure storage.
  Future<void> clearUnsentMessages() async {
    await _secureStorage.delete(key: 'unsent_messages');
  }

  /// Gets whether liveness credential exists in wallet UI.
  Future<bool> getHasLivenessCredential() async {
    final value = await _secureStorage.read(key: 'zkp_has_liveness_credential');
    if (value == null) return false;
    return value.toLowerCase() == 'true';
  }

  /// Persists whether liveness credential exists in wallet UI.
  Future<void> saveHasLivenessCredential(bool hasCredential) async {
    await _secureStorage.write(
      key: 'zkp_has_liveness_credential',
      value: hasCredential.toString(),
    );
  }
}

/// Provides a configured [SecureStorage] instance.
///
/// On fresh installs (detected via SharedPreferences), clears any existing
/// keychain data to ensure a clean state. Marks the app as installed to
/// prevent future clearing.
final secureStorageProvider = FutureProvider<SecureStorage>((ref) async {
  final storage = SecureStorage();
  const logKey = 'secureStorageProvider';

  final prefs = ref.read(sharedPreferencesProvider);
  if (prefs.getBool(SharedPreferencesKeys.alreadyInstalled.name) != true) {
    final logger = ref.read(appLoggerProvider);
    logger.info('Fresh install: clearing Keychain', name: logKey);

    await storage.clear();
    await prefs.setBool(SharedPreferencesKeys.alreadyInstalled.name, true);
  }

  return storage;
}, name: 'secureStorageProvider');
