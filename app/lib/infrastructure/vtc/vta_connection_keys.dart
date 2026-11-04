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

/// The signing keys of Meeting Place connection DIDs, held on the member's
/// VTA: the VTA creates each one and signs credentials with it, and this
/// device keeps only its id and public key, by DID.
///
/// Never logs a DID or key.
class VtaConnectionKeys implements ExternalSigningKeys {
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

  static const _keyPrefix = 'vta_connection_key_';

  final VtcService _service;
  final FlutterSecureStorage _storage;

  @override
  Future<ExternalSigningKey> createKey(String did) async {
    final key = await _call(_service.createConnectionKey);
    await _storage.write(
      key: '$_keyPrefix$did',
      value: jsonEncode({
        'keyId': key.keyId,
        'publicKey': base64Url.encode(key.publicKey),
      }),
    );
    return ExternalSigningKey(keyId: key.keyId, publicKey: key.publicKey);
  }

  @override
  Future<ExternalSigningKey?> findKey(String did) async {
    final stored = await _storage.read(key: '$_keyPrefix$did');
    if (stored == null) return null;
    final json = jsonDecode(stored) as Map<String, dynamic>;
    return ExternalSigningKey(
      keyId: json['keyId'] as String,
      publicKey: Uint8List.fromList(
        base64Url.decode(json['publicKey'] as String),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> signDocument(
    Map<String, dynamic> document, {
    required String keyId,
  }) => _call(() => _service.signConnectionDocument(document, keyId: keyId));

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
