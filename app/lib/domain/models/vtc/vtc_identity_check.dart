/// A community's own check of the member's identity: a `vetted/1`
/// statement the community issued about the member's persona, as their VTA
/// keeps it, read for showing.
///
/// Only what the statement says; its proof is the VTA's to verify when it
/// stores it.
class VtcIdentityCheck {
  /// Creates a [VtcIdentityCheck].
  const VtcIdentityCheck({
    required this.memberDid,
    required this.method,
    required this.credential,
    this.documentClasses = const [],
    this.claimsVerified = const [],
    this.livenessConfirmed = false,
    this.validFrom,
    this.validUntil,
  });

  /// Reads [credential], or returns null unless it is a `vetted/1`
  /// statement [communityDid] issued for itself, naming itself.
  ///
  /// A role, membership card or endorsement is community-issued and names
  /// the member too: only the predicate tells an identity check apart.
  static VtcIdentityCheck? fromCredential(
    Map<String, dynamic> credential, {
    required String communityDid,
  }) {
    final types = switch (credential['type']) {
      final String type => {type},
      final List<dynamic> types => types.whereType<String>().toSet(),
      _ => const <String>{},
    };
    if (!types.contains(statementType)) return null;

    final issuer = switch (credential['issuer']) {
      final String id => id,
      {'id': final String id} => id,
      _ => null,
    };
    if (issuer != communityDid) return null;

    final subject = switch (credential['credentialSubject']) {
      final Map<String, dynamic> subject => subject,
      [final Map<String, dynamic> subject, ...] => subject,
      _ => null,
    };
    if (subject == null || subject['predicate'] != vettedPredicate) {
      return null;
    }
    final memberDid = subject['id'];
    final value = switch (subject['object']) {
      {'value': final Map<String, dynamic> value} => value,
      _ => null,
    };
    if (memberDid is! String || value == null) return null;
    if (value['community'] != communityDid) return null;
    final method = value['method'];
    if (method is! String) return null;

    return VtcIdentityCheck(
      memberDid: memberDid,
      method: method,
      documentClasses: _strings(value['documentClasses']),
      claimsVerified: _strings(value['claimsVerified']),
      livenessConfirmed: value['livenessConfirmed'] == true,
      validFrom: _time(credential['validFrom']),
      validUntil: _time(credential['validUntil']),
      credential: credential,
    );
  }

  /// The DTG catalog type every community statement carries.
  static const statementType = 'StatementCredential';

  /// The DTG VSC registry's identity-check predicate.
  static const vettedPredicate =
      'https://registry.trustoverip.org/dtg/vsc/vetted/1';

  /// The persona's DID the check is about.
  final String memberDid;

  /// How the community established the identity, such as `inPerson`; kept
  /// as sent, so a method this app does not know still shows.
  final String method;

  /// What the community relied on, such as `nationalId`.
  final List<String> documentClasses;

  /// The claims the community verified, such as `name.legal`.
  final List<String> claimsVerified;

  /// Whether the community confirmed the person was there.
  final bool livenessConfirmed;

  /// When the check was recorded, if it says.
  final DateTime? validFrom;

  /// When the check stops holding, if it says.
  final DateTime? validUntil;

  /// The statement exactly as the VTA keeps it.
  final Map<String, dynamic> credential;

  static List<String> _strings(Object? value) =>
      value is List ? List.unmodifiable(value.whereType<String>()) : const [];

  static DateTime? _time(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}
