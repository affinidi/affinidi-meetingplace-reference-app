/// Data returned by GET /vc for a deployed agent's Verifiable Credential.
class AgentVcData {
  const AgentVcData({
    required this.issuanceId,
    required this.issuedAt,
    required this.holderDid,
    this.credentialOfferUri,
    required this.claims,
  });

  final String issuanceId;
  final DateTime issuedAt;
  final String holderDid;
  final String? credentialOfferUri;
  final Map<String, dynamic> claims;

  factory AgentVcData.fromJson(Map<String, dynamic> json) => AgentVcData(
    issuanceId: json['issuanceId'] as String? ?? '',
    issuedAt:
        DateTime.tryParse(json['issuedAt'] as String? ?? '') ?? DateTime.now(),
    holderDid: json['holderDid'] as String? ?? '',
    credentialOfferUri: json['credentialOfferUri'] as String?,
    claims: (json['claims'] as Map<String, dynamic>?) ?? {},
  );
}
