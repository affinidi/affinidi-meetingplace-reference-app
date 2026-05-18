class LivenessCredentialRecord {
  factory LivenessCredentialRecord.fromJson(Map<String, Object?> json) {
    return LivenessCredentialRecord(
      identityId: json['identityId']! as String,
      issuedToDid: json['issuedToDid']! as String,
      issuerName: json['issuerName']! as String,
      issuedAt: DateTime.parse(json['issuedAt']! as String).toLocal(),
      expiresAt: DateTime.parse(json['expiresAt']! as String).toLocal(),
    );
  }
  const LivenessCredentialRecord({
    required this.identityId,
    required this.issuedToDid,
    required this.issuerName,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String identityId;
  final String issuedToDid;
  final String issuerName;
  final DateTime issuedAt;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => {
    'identityId': identityId,
    'issuedToDid': issuedToDid,
    'issuerName': issuerName,
    'issuedAt': issuedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };
}
