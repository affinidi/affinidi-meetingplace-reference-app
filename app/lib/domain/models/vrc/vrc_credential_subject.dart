class VrcCredentialSubject {
  const VrcCredentialSubject({required this.from, required this.to});

  factory VrcCredentialSubject.fromJson(Map<String, dynamic> json) =>
      VrcCredentialSubject(
        from: VrcIdentity.fromJson(json['from'] as Map<String, dynamic>? ?? {}),
        to: VrcIdentity.fromJson(json['to'] as Map<String, dynamic>? ?? {}),
      );

  final VrcIdentity from;
  final VrcIdentity to;
}

class VrcIdentity {
  const VrcIdentity({required this.did, required this.name});

  factory VrcIdentity.fromJson(Map<String, dynamic> json) => VrcIdentity(
    did: json['did'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );

  final String did;
  final String name;
}
