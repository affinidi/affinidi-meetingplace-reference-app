import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:ssi/ssi.dart' show ProofPurpose;
import 'package:uuid/uuid.dart';

import '../../domain/models/vtc/mock_credential_template.dart';

/// Issues test credentials on this phone, as a `did:key` any verifier can
/// resolve offline: a mock issuer, so a member can try joining a community
/// by credential without a real one.
///
/// Its seed stays in secure storage, created on first use, so the issuer is
/// the same for every credential and a community can be told to trust it.
/// The seed is never logged.
class MockCredentialIssuer {
  /// Creates a [MockCredentialIssuer] keeping its seed in [storage].
  MockCredentialIssuer([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(storageNamespace: _storeName),
            iOptions: IOSOptions(
              accountName: _storeName,
              accessibility: KeychainAccessibility.unlocked_this_device,
              synchronizable: false,
            ),
          );

  static const _storeName = 'mpx_mock_credential_issuer';
  static const _seedKey = 'seed';

  /// How long an issued credential is valid.
  static const validity = Duration(days: 365);

  final FlutterSecureStorage _storage;
  Ed25519DidKeySigner? _key;

  /// The issuer's DID.
  Future<String> did() async => (await _signer()).did;

  /// Issues [template] to [subjectDid], signed as the issuer for
  /// `assertionMethod`. Issuing the same template to the same subject again
  /// gives a credential of the same id, so importing it replaces the first.
  Future<Map<String, dynamic>> issue(
    MockCredentialTemplate template, {
    required String subjectDid,
    DateTime? now,
  }) async {
    final signer = await _signer();
    final issuedAt = (now ?? DateTime.now()).toUtc();
    // One name per template and subject, so the id is stable.
    final name = 'mpx-mock-credential:${template.id}:$subjectDid';
    final credential = <String, dynamic>{
      '@context': ['https://www.w3.org/ns/credentials/v2'],
      'id': 'urn:uuid:${const Uuid().v5(Namespace.url.value, name)}',
      'type': ['VerifiableCredential', template.type],
      'name': 'Mock ${template.title}',
      'issuer': signer.did,
      'validFrom': formatTrustTaskTime(issuedAt),
      'validUntil': formatTrustTaskTime(issuedAt.add(validity)),
      'credentialSubject': {'id': subjectDid, ...template.claims},
    };
    return EddsaJcs2022.sign(
      credential,
      signer: signer,
      purpose: ProofPurpose.assertionMethod,
      created: issuedAt,
    );
  }

  Future<Ed25519DidKeySigner> _signer() async {
    if (_key case final key?) return key;
    final stored = await _storage.read(key: _seedKey);
    final key = stored != null
        ? Ed25519DidKeySigner.fromSeed(
            Uint8List.fromList(base64Url.decode(stored)),
          )
        : Ed25519DidKeySigner.generate();
    if (stored == null) {
      await _storage.write(key: _seedKey, value: base64Url.encode(key.seed));
    }
    return _key = key;
  }
}
