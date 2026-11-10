import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// A step of leaving a community, in order, as the phone works on it.
enum VtcLeaveStep {
  /// Reading the membership card from the member's VTA, to keep a record.
  readingCard,

  /// Telling the community the member leaves, signed as their identity.
  tellingCommunity,

  /// Archiving the card on the VTA, so a later scan does not offer the
  /// membership back.
  archivingCard,
}

/// A membership that ended: the card the community had issued, the
/// community's signed answer to the member leaving or its signed notice
/// that it removed them, and the last status list that showed the card's
/// state. Kept on this phone once the community and
/// the VTA no longer show them.
class VtcLeftMembership {
  /// Creates a [VtcLeftMembership].
  const VtcLeftMembership({
    required this.communityDid,
    required this.personaDid,
    required this.leftAt,
    this.name,
    this.card,
    this.leaveExchange,
    this.removalNotice,
    this.lastStatus,
  });

  /// Restores a [VtcLeftMembership] stored with [toJson]. Parts that cannot
  /// be read are dropped, never the record.
  factory VtcLeftMembership.fromJson(Map<String, dynamic> json) {
    return VtcLeftMembership(
      communityDid: json['communityDid'] as String,
      personaDid: json['personaDid'] as String,
      leftAt: DateTime.parse(json['leftAt'] as String),
      name: json['name'] as String?,
      card: switch (json['card']) {
        final Map<String, dynamic> card => card,
        _ => null,
      },
      leaveExchange: _exchangeOf(json['leaveExchange']),
      removalNotice: _documentOf(json['removalNotice']),
      lastStatus: VtcStatusRecord._of(json['lastStatus']),
    );
  }

  static TrustTaskExchange? _exchangeOf(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    try {
      return TrustTaskExchange.fromJson(json);
    } on Object {
      return null;
    }
  }

  static TrustTaskDocument? _documentOf(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    try {
      return TrustTaskDocument.fromJson(json);
    } on MeetingPlaceVtcSDKException {
      return null;
    }
  }

  /// DID of the community left.
  final String communityDid;

  /// DID of the persona the member was known by there.
  final String personaDid;

  /// When the member left, or the community decided to remove them.
  final DateTime leftAt;

  /// Name of the community, if known.
  final String? name;

  /// The membership card the community had issued, as the VTA kept it, if
  /// it held one.
  final Map<String, dynamic>? card;

  /// The signed request to leave and the community's verified answer; none
  /// when the community already counted the persona as no member.
  final TrustTaskExchange? leaveExchange;

  /// The community's signed `members/removal-notice`, when it removed the
  /// member rather than they left.
  final TrustTaskDocument? removalNotice;

  /// The last status list read for [card], if any.
  final VtcStatusRecord? lastStatus;

  /// What names this record among the others: its card, else the
  /// membership.
  String get key => switch (card?['id']) {
    final String id => id,
    _ => '$communityDid $personaDid',
  };

  /// This record with [status] as its last.
  VtcLeftMembership withStatus(VtcStatusRecord status) => VtcLeftMembership(
    communityDid: communityDid,
    personaDid: personaDid,
    leftAt: leftAt,
    name: name,
    card: card,
    leaveExchange: leaveExchange,
    removalNotice: removalNotice,
    lastStatus: status,
  );

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'personaDid': personaDid,
    'leftAt': leftAt.toUtc().toIso8601String(),
    'name': ?name,
    'card': ?card,
    'leaveExchange': ?leaveExchange?.toJson(),
    'removalNotice': ?removalNotice?.toJson(),
    'lastStatus': ?lastStatus?.toJson(),
  };
}

/// What a community's status list said of a card, and the signed list that
/// said so.
class VtcStatusRecord {
  /// Creates a [VtcStatusRecord].
  const VtcStatusRecord({
    required this.revoked,
    required this.checkedAt,
    required this.statusList,
  });

  static VtcStatusRecord? _of(Object? json) {
    if (json case {
      'revoked': final bool revoked,
      'checkedAt': final String checkedAt,
      'statusList': final Map<String, dynamic> statusList,
    }) {
      if (DateTime.tryParse(checkedAt) case final at?) {
        return VtcStatusRecord(
          revoked: revoked,
          checkedAt: at,
          statusList: statusList,
        );
      }
    }
    return null;
  }

  /// Whether the list showed the card revoked.
  final bool revoked;

  /// When the list was read.
  final DateTime checkedAt;

  /// The list as the community signed it.
  final Map<String, dynamic> statusList;

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'revoked': revoked,
    'checkedAt': checkedAt.toUtc().toIso8601String(),
    'statusList': statusList,
  };
}
