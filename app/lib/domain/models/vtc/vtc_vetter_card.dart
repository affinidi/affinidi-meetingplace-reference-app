/// The role card in which a community makes the member one of its
/// vetters, as their VTA keeps it.
class VtcVetterCard {
  /// Creates a [VtcVetterCard].
  const VtcVetterCard({
    required this.issuer,
    required this.vetterDid,
    required this.credential,
    this.validFrom,
    this.validUntil,
  });

  /// Reads [credential], a role card already checked to grant the vetter
  /// role; null when it names no issuer or subject.
  static VtcVetterCard? fromCredential(Map<String, dynamic> credential) {
    final issuer = switch (credential['issuer']) {
      final String id => id,
      {'id': final String id} => id,
      _ => null,
    };
    final vetterDid = switch (credential['credentialSubject']) {
      {'id': final String id} => id,
      [{'id': final String id}, ...] => id,
      _ => null,
    };
    if (issuer == null || vetterDid == null) return null;
    return VtcVetterCard(
      issuer: issuer,
      vetterDid: vetterDid,
      credential: credential,
      validFrom: _time(credential['validFrom']),
      validUntil: _time(credential['validUntil']),
    );
  }

  /// The community's DID, which issued the card.
  final String issuer;

  /// The persona's DID the card makes a vetter.
  final String vetterDid;

  /// When the card starts to hold, if it says.
  final DateTime? validFrom;

  /// When the card stops holding.
  final DateTime? validUntil;

  /// The credential exactly as the VTA keeps it.
  final Map<String, dynamic> credential;

  static DateTime? _time(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
