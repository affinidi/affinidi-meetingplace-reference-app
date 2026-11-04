/// The membership card a community issued to the member's persona: a
/// `MembershipCredential`, as their VTA keeps it, read for showing.
///
/// Only what the credential states; its proof is the VTA's to verify when
/// it stores it.
class VtcMembershipCard {
  /// Creates a [VtcMembershipCard].
  const VtcMembershipCard({
    required this.issuer,
    required this.memberDid,
    required this.credential,
    this.validFrom,
    this.validUntil,
    this.personhood = false,
  });

  /// Reads [credential], or returns null when it is no membership card with
  /// an issuer and a subject.
  static VtcMembershipCard? fromCredential(Map<String, dynamic> credential) {
    final types = switch (credential['type']) {
      final String type => {type},
      final List<dynamic> types => types.whereType<String>().toSet(),
      _ => const <String>{},
    };
    if (!types.contains(_membershipType)) return null;

    final issuer = switch (credential['issuer']) {
      final String id => id,
      {'id': final String id} => id,
      _ => null,
    };
    final memberDid = switch (credential['credentialSubject']) {
      {'id': final String id} => id,
      [{'id': final String id}, ...] => id,
      _ => null,
    };
    if (issuer == null || memberDid == null) return null;

    return VtcMembershipCard(
      issuer: issuer,
      memberDid: memberDid,
      credential: credential,
      validFrom: _time(credential['validFrom']),
      validUntil: _time(credential['validUntil']),
      personhood: types.contains(_personhoodType),
    );
  }

  static const _membershipType = 'MembershipCredential';

  /// The type a community adds when the member proved personhood.
  static const _personhoodType = 'PersonhoodCredential';

  /// The community's DID, which issued the card.
  final String issuer;

  /// The persona's DID the card is about.
  final String memberDid;

  /// When the card starts to hold, if it says.
  final DateTime? validFrom;

  /// When the card stops holding, if it says.
  final DateTime? validUntil;

  /// Whether the card also states the member proved personhood.
  final bool personhood;

  /// The credential exactly as the VTA keeps it.
  final Map<String, dynamic> credential;

  static DateTime? _time(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
