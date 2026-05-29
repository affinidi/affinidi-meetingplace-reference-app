import 'dart:convert';

class LivenessCredentialRecord {
  factory LivenessCredentialRecord.fromJson(Map<String, Object?> json) {
    return LivenessCredentialRecord(
      identityId: json['identityId']! as String,
      issuedToDid: json['issuedToDid']! as String,
      issuerName: json['issuerName']! as String,
      issuerDid: json['issuerDid'] as String? ?? '',
      issuedAt: DateTime.parse(json['issuedAt']! as String).toLocal(),
      expiresAt: DateTime.parse(json['expiresAt']! as String).toLocal(),
      w3cCredentialJson: json['w3cCredentialJson'] as String? ?? '',
      zkpSignedDocumentJson: json['zkpSignedDocumentJson'] as String? ?? '',
      zkpHolderPrivateKeyHex: json['zkpHolderPrivateKeyHex'] as String? ?? '',
      zkpIssuerAx: json['zkpIssuerAx'] as String? ?? '',
      zkpIssuerAy: json['zkpIssuerAy'] as String? ?? '',
    );
  }

  const LivenessCredentialRecord({
    required this.identityId,
    required this.issuedToDid,
    required this.issuerName,
    required this.issuerDid,
    required this.issuedAt,
    required this.expiresAt,
    required this.w3cCredentialJson,
    required this.zkpSignedDocumentJson,
    required this.zkpHolderPrivateKeyHex,
    required this.zkpIssuerAx,
    required this.zkpIssuerAy,
  });

  final String identityId;
  final String issuedToDid;
  final String issuerName;
  final String issuerDid;
  final DateTime issuedAt;
  final DateTime expiresAt;

  /// Canonical W3C Verifiable Credential (Data Integrity proof).
  final String w3cCredentialJson;

  /// vc_zkp signed document JSON used by the Groth16 circuit.
  final String zkpSignedDocumentJson;
  final String zkpHolderPrivateKeyHex;
  final String zkpIssuerAx;
  final String zkpIssuerAy;

  bool get hasPersistedZkpMaterial =>
      zkpSignedDocumentJson.isNotEmpty && zkpHolderPrivateKeyHex.isNotEmpty;

  bool get hasW3cCredential => w3cCredentialJson.isNotEmpty;

  Map<String, Object?> toJson() => {
    'identityId': identityId,
    'issuedToDid': issuedToDid,
    'issuerName': issuerName,
    'issuerDid': issuerDid,
    'issuedAt': issuedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'w3cCredentialJson': w3cCredentialJson,
    'zkpSignedDocumentJson': zkpSignedDocumentJson,
    'zkpHolderPrivateKeyHex': zkpHolderPrivateKeyHex,
    'zkpIssuerAx': zkpIssuerAx,
    'zkpIssuerAy': zkpIssuerAy,
  };
}

extension LivenessCredentialRecordX on LivenessCredentialRecord {
  Map<String, dynamic>? get w3cCredentialMap {
    if (w3cCredentialJson.isEmpty) return null;
    try {
      return jsonDecode(w3cCredentialJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
