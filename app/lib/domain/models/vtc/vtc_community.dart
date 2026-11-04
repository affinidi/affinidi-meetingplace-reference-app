import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// A Verifiable Trust Community the member belongs to or applied to, and the
/// persona they are known by there.
class VtcCommunity {
  /// Creates a [VtcCommunity].
  const VtcCommunity({
    required this.communityDid,
    required this.personaDid,
    required this.contextId,
    this.name,
    this.signingKeyId,
    this.isMember = true,
    this.joinRequestId,
    this.listInDirectory = true,
    this.isSettled = true,
    this.rejectionReason,
    this.submitExchange,
  });

  /// Restores a [VtcCommunity] stored with [toJson].
  ///
  /// Records stored before applications were kept are memberships, and
  /// records stored before admissions were settled need nothing more. An
  /// application's documents that cannot be read are dropped, never the
  /// record.
  factory VtcCommunity.fromJson(Map<String, dynamic> json) {
    return VtcCommunity(
      communityDid: json['communityDid'] as String,
      personaDid: json['personaDid'] as String,
      contextId: json['contextId'] as String,
      name: json['name'] as String?,
      signingKeyId: json['signingKeyId'] as String?,
      isMember: json['isMember'] as bool? ?? true,
      joinRequestId: json['joinRequestId'] as String?,
      listInDirectory: json['listInDirectory'] as bool? ?? true,
      isSettled: json['isSettled'] as bool? ?? true,
      rejectionReason: json['rejectionReason'] as String?,
      submitExchange: _exchangeOf(json['submitExchange']),
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

  /// DID of the community.
  final String communityDid;

  /// DID of the member's persona in the community, held by their VTA.
  final String personaDid;

  /// VTA context of the persona.
  final String contextId;

  /// Name of the community, if known.
  final String? name;

  /// Id of the persona's signing key on the VTA, when it is not `#key-0`.
  final String? signingKeyId;

  /// Whether the community admitted the persona. False while applying, or
  /// after an application that did not succeed.
  final bool isMember;

  /// The community's id of the open application, if one is open.
  final String? joinRequestId;

  /// Whether the member agreed to be listed in the community's member
  /// directory. When not, their card is withdrawn once they are admitted.
  final bool listInDirectory;

  /// Whether an admission is complete on the community's side: the
  /// membership confirmed back and, unless listed, the directory card
  /// withdrawn. False until both succeeded; retried until then.
  final bool isSettled;

  /// The community's reason for turning the last application down, in its
  /// own words, if it gave one. Kept until the next application.
  final String? rejectionReason;

  /// The open application as the VTA signed it and the community answered
  /// it, both documents as they were on the wire, if this phone sent it.
  /// They carry what the member disclosed: kept in secure storage only.
  final TrustTaskExchange? submitExchange;

  /// What [submitExchange] shows, without its payloads.
  TrustTaskReceipt? get submitReceipt => submitExchange?.receipt;

  /// Whether an application is waiting for the community's decision.
  bool get isApplying => !isMember && joinRequestId != null;

  /// This record with the application's outcome: a member, or still
  /// applying under [requestId], sent and answered as [exchange] shows when
  /// this phone sent it, or neither. A new member is not settled until
  /// [settled] says so.
  VtcCommunity withApplication({
    required bool isMember,
    String? requestId,
    TrustTaskExchange? exchange,
  }) {
    return _copy(
      isMember: isMember,
      joinRequestId: isMember ? null : requestId,
      isSettled: !isMember || (this.isMember && isSettled),
      submitExchange: exchange,
    );
  }

  /// This record with the application turned down, for [reason].
  VtcCommunity rejected(String? reason) =>
      _copy(isMember: false, rejectionReason: reason);

  /// This record with whether the admission is complete on the community's
  /// side.
  VtcCommunity settled(bool isSettled) => _copy(isSettled: isSettled);

  /// This record with the member's directory choice.
  VtcCommunity withDirectoryChoice({required bool listInDirectory}) =>
      _copy(listInDirectory: listInDirectory);

  VtcCommunity _copy({
    bool? isMember,
    String? joinRequestId,
    bool? isSettled,
    bool? listInDirectory,
    String? rejectionReason,
    TrustTaskExchange? submitExchange,
  }) {
    return VtcCommunity(
      communityDid: communityDid,
      personaDid: personaDid,
      contextId: contextId,
      name: name,
      signingKeyId: signingKeyId,
      isMember: isMember ?? this.isMember,
      joinRequestId: isMember == null ? this.joinRequestId : joinRequestId,
      listInDirectory: listInDirectory ?? this.listInDirectory,
      isSettled: isSettled ?? this.isSettled,
      // A new outcome replaces the last rejection.
      rejectionReason: isMember == null
          ? this.rejectionReason
          : rejectionReason,
      // The documents belong to the open request: kept while it stays open,
      // dropped once it is decided or withdrawn.
      submitExchange: isMember == null
          ? this.submitExchange
          : submitExchange ??
                (joinRequestId != null && joinRequestId == this.joinRequestId
                    ? this.submitExchange
                    : null),
    );
  }

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'personaDid': personaDid,
    'contextId': contextId,
    'name': ?name,
    'signingKeyId': ?signingKeyId,
    'isMember': isMember,
    'joinRequestId': ?joinRequestId,
    'listInDirectory': listInDirectory,
    'isSettled': isSettled,
    'rejectionReason': ?rejectionReason,
    'submitExchange': ?submitExchange?.toJson(),
  };
}
