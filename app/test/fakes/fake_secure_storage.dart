import 'dart:convert';
import 'dart:typed_data';

import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:ssi/ssi.dart' show StoredKey;

class FakeSecureStorage extends SecureStorage {
  FakeSecureStorage({
    this._debugMode,
    this._passphrase = 'test_passphrase',
    String unsentMessages = 'test_passphrase',
    this._preferredMediatorDid,
    this._shouldShowMeetingPlaceQR,
    this._savingPushTokenDuration,
  });

  final bool? _debugMode;
  final String _passphrase;
  final String? _preferredMediatorDid;
  final bool? _shouldShowMeetingPlaceQR;
  final int? _savingPushTokenDuration;

  static final _keyPairIndex = 'keypair_';
  static final _didPrefix = 'did_';

  final Map<String, String> _storedKeys = {};
  var _startedSavePushNotificationToken = 0;
  var _endSavePushNotificationToken = 0;

  @override
  Future<String> provideDatabasePassphrase() async {
    return _passphrase;
  }

  @override
  Future<String?> getPreferredMediatorDid() async {
    return _preferredMediatorDid;
  }

  @override
  Future<bool?> getDebugMode() async {
    return _debugMode;
  }

  @override
  Future<bool?> getShouldShowMeetingPlaceQR() async {
    return _shouldShowMeetingPlaceQR;
  }

  @override
  Future<String?> getPushNotificationToken() async {
    return _storedKeys['pushNotificationToken'];
  }

  @override
  Future<void> savePushNotificationToken(String pushNotificationToken) async {
    if (_savingPushTokenDuration == null) {
      _storedKeys['pushNotificationToken'] = pushNotificationToken;
      return;
    }

    _startedSavePushNotificationToken++;
    if (_startedSavePushNotificationToken - _endSavePushNotificationToken > 1) {
      throw Exception(
        'Cannot save multiple pushNotificationToken concurrently',
      );
    }

    await Future.delayed(Duration(milliseconds: _savingPushTokenDuration), () {
      _storedKeys['pushNotificationToken'] = pushNotificationToken;
    });

    _endSavePushNotificationToken++;
  }

  @override
  Future<bool> contains(String key) async => _storedKeys[key] != null;

  @override
  Future<StoredKey?> get(String key) async {
    final jsonString = _storedKeys[key];
    if (jsonString == null) return null;

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return StoredKey.fromJson(json);
  }

  @override
  Future<void> set(String key, StoredKey value) async {
    _storedKeys[key] = jsonEncode(value);
  }

  @override
  Future<KeyPair?> getKeyPair(String did) async {
    final value = _storedKeys['$_keyPairIndex$did'];
    if (value == null) return null;
    return KeyPair.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> saveKeyPair({
    required Uint8List privateKeyBytes,
    required Uint8List publicKeyBytes,
    required String did,
  }) async {
    _storedKeys['$_keyPairIndex$did'] = jsonEncode({
      'privateKeyBytes': privateKeyBytes,
      'publicKeyBytes': publicKeyBytes,
      'did': did,
    });
  }

  @override
  Future<void> saveKeyIdForDid({
    required String keyId,
    required String did,
  }) async {
    _storedKeys['$_didPrefix$did'] = keyId;
  }

  @override
  Future<Map<String, String>> getUnsentMessages() async {
    final jsonString = _storedKeys['unsent_messages'];
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(jsonString);
    return Map<String, String>.from(decoded as Map);
  }

  @override
  Future<void> saveUnsentMessages(Map<String, String> messages) async {
    if (messages.isEmpty) {
      _storedKeys.remove('unsent_messages');
    } else {
      _storedKeys['unsent_messages'] = jsonEncode(messages);
    }
  }

  @override
  Future<void> clearUnsentMessages() async {
    _storedKeys.remove('unsent_messages');
  }

  @override
  Future<String?> readLivenessCredentials() async {
    return _storedKeys['zkp_liveness_credentials'];
  }

  @override
  Future<void> writeLivenessCredentials(String json) async {
    _storedKeys['zkp_liveness_credentials'] = json;
  }

  @override
  Future<void> clearLivenessCredentials() async {
    _storedKeys.remove('zkp_liveness_credentials');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
