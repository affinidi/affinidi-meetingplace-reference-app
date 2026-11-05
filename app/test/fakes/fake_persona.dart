import 'dart:typed_data';

import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:ssi/ssi.dart';
import 'package:x25519/x25519.dart' as x25519;

/// An identity as a VTA mints it: an Ed25519 key it signs with, a separate
/// X25519 key it agrees keys with, and a mediator its mail goes to.
///
/// Its DID is a `did:peer:2`, which resolves offline. The VTA lends its keys
/// through [exportAnswer], and it signs as the identity itself.
class FakePersona implements TrustTaskSigner {
  FakePersona._(this._signing, this._keyAgreementKey, this.document);

  factory FakePersona({required String mediatorDid}) {
    final signing = Ed25519KeyPair.generate().$1;
    final keyAgreement = x25519.generateKeyPair();
    final did = DidPeer.getDid(
      verificationMethods: [
        signing.publicKey,
        PublicKey(
          'key-agreement',
          Uint8List.fromList(keyAgreement.publicKey),
          KeyType.x25519,
        ),
      ],
      relationships: {
        VerificationRelationship.authentication: [0],
        VerificationRelationship.keyAgreement: [1],
      },
    );
    final json = DidPeer.resolve(did).toJson()
      ..['service'] = [
        {
          'id': '$did#didcomm',
          'type': didCommMessagingServiceType,
          'serviceEndpoint': {
            'uri': mediatorDid,
            'accept': ['didcomm/v2'],
          },
        },
      ];
    return FakePersona._(
      signing,
      Uint8List.fromList(keyAgreement.privateKey),
      DidDocument.fromJson(json),
    );
  }

  final Ed25519KeyPair _signing;
  final Uint8List _keyAgreementKey;

  /// The identity's DID document.
  final DidDocument document;

  @override
  String get did => document.id;

  @override
  String get verificationMethod => _absolute(document.authentication.first.id);

  @override
  Future<Uint8List> sign(Uint8List data) => _signing.sign(data);

  /// Ids of the identity's signing and key agreement keys.
  String get signingKeyId => verificationMethod;
  String get keyAgreementKeyId => _absolute(document.keyAgreement.first.id);

  /// What `keys/export-secret` answers for [keyId], as a VTA lends it.
  Map<String, dynamic> exportAnswer(Object? keyId) => switch (keyId) {
    _ when keyId == signingKeyId => {
      'keyId': keyId,
      'keyType': 'Ed25519',
      'privateKeyMultibase': toMultiBase(
        Uint8List.fromList([0x80, 0x26, ..._signing.getSeed()]),
      ),
    },
    _ when keyId == keyAgreementKeyId => {
      'keyId': keyId,
      'keyType': 'X25519',
      'privateKeyMultibase': toMultiBase(
        Uint8List.fromList([0x82, 0x26, ..._keyAgreementKey]),
      ),
    },
    _ => const {},
  };

  String _absolute(String id) => id.startsWith('#') ? '$did$id' : id;
}
