import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../application/services/vtc_service/vtc_service.dart';
import '../exceptions/app_exception.dart';

/// Thrown when an action needs the member's VTA to sign and it cannot: no
/// VTA is linked, or it cannot be reached or refuses.
class VtaSigningUnavailableException extends AppException {
  /// Creates a [VtaSigningUnavailableException].
  VtaSigningUnavailableException({required bool isLinked})
    : super(
        isLinked ? 'The VTA could not sign' : 'No VTA is linked to sign with',
        code: isLinked ? unreachableCode : notLinkedCode,
      );

  /// Code when the VTA cannot be reached or refuses.
  static const unreachableCode = 'vtaSigningUnavailable';

  /// Code when no VTA is linked.
  static const notLinkedCode = 'vtaNotLinked';
}

/// The keys of Meeting Place connection DIDs, held on the member's VTA:
/// the VTA creates them, signs credentials with the signing key, and lends
/// the DIDComm key when a message is sealed or unsealed. This device keeps
/// only their ids and public keys, by DID, and lent keys in memory.
///
/// Never logs a DID or key.
class VtaConnectionKeys implements ExternalConnectionKeys {
  /// Creates [VtaConnectionKeys] that reach the VTA through the VTC service.
  VtaConnectionKeys(this._service, [FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
              synchronizable: false,
            ),
          );

  static const _keyPrefix = 'vta_connection_keys_';

  final VtcService _service;
  final FlutterSecureStorage _storage;

  /// Creates the keys of [did] on the member's VTA, or returns null when no
  /// VTA is linked, so [did] keeps its keys on this device.
  ///
  /// Throws [VtaSigningUnavailableException] when a linked VTA cannot be
  /// reached or refuses.
  @override
  Future<ExternalDidKeys?> createKeys(String did) async {
    final ({VtaConnectionKey signing, VtaConnectionKey agreement}) keys;
    try {
      keys = await _call(_service.createConnectionKeys);
    } on VtaSigningUnavailableException catch (error) {
      if (error.code == VtaSigningUnavailableException.notLinkedCode) {
        return null;
      }
      rethrow;
    }
    await _storage.write(
      key: '$_keyPrefix$did',
      value: jsonEncode({
        'signing': _toJson(keys.signing),
        'agreement': _toJson(keys.agreement),
      }),
    );
    return ExternalDidKeys(
      signing: _toExternal(keys.signing),
      agreement: _toExternal(keys.agreement),
    );
  }

  @override
  Future<ExternalDidKeys?> findKeys(String did) async {
    final stored = await _storage.read(key: '$_keyPrefix$did');
    if (stored == null) return null;
    final json = jsonDecode(stored) as Map<String, dynamic>;
    return ExternalDidKeys(
      signing: _fromJson(json['signing'] as Map<String, dynamic>),
      agreement: _fromJson(json['agreement'] as Map<String, dynamic>),
    );
  }

  @override
  Future<Map<String, dynamic>> signDocument(
    Map<String, dynamic> document, {
    required String keyId,
  }) => _call(() => _service.signConnectionDocument(document, keyId: keyId));

  /// Borrows the DIDComm key [keyId] from the member's VTA, held in memory
  /// for as long as the link lasts.
  ///
  /// Throws [VtaSigningUnavailableException] when no VTA is linked, or it
  /// cannot be reached or refuses.
  @override
  Future<Uint8List> lendSecret(String keyId) =>
      _call(() => _service.lendConnectionKey(keyId));

  static Map<String, String> _toJson(VtaConnectionKey key) => {
    'keyId': key.keyId,
    'publicKey': base64Url.encode(key.publicKey),
  };

  static ExternalKey _toExternal(VtaConnectionKey key) =>
      ExternalKey(keyId: key.keyId, publicKey: key.publicKey);

  static ExternalKey _fromJson(Map<String, dynamic> json) => ExternalKey(
    keyId: json['keyId'] as String,
    publicKey: Uint8List.fromList(
      base64Url.decode(json['publicKey'] as String),
    ),
  );

  static Future<T> _call<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on VtaNotLinkedException {
      throw VtaSigningUnavailableException(isLinked: false);
    } on MeetingPlaceVtcSDKException {
      throw VtaSigningUnavailableException(isLinked: true);
    }
  }
}
