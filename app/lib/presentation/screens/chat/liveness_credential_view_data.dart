class LivenessCredentialViewData {
  const LivenessCredentialViewData({
    required this.identityId,
    required this.issuedToDid,
    required this.displayIssuer,
    required this.issuedAt,
  });

  final String identityId;
  final String issuedToDid;
  final String displayIssuer;
  final DateTime issuedAt;
}
