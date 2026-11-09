import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_member_link.dart';
import '../../../domain/repositories/vtc_repository.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import '../vtc_service/vtc_service.dart';

/// Why vouching for a member, or finding one, did not work.
enum VtcTrustFailure {
  /// The phone no longer holds a membership of the community.
  notMember,

  /// The member vouched for is no member of the community any more.
  contactNotMember,

  /// The member has not let other members find them.
  notFindable,

  /// A search too short for the community.
  searchTooShort,

  /// The community does not take the name the member gave.
  nameRefused,

  /// The community did not accept the VTA's signature.
  proofRejected,

  /// The community's rules do not allow it.
  notAllowed,

  /// The community asks to try again later.
  tryLater,

  /// No VTA is linked to sign with.
  vtaUnavailable,

  /// The community or the VTA could not be reached.
  network,

  /// Anything else.
  failed,
}

/// Vouching for a member, or finding one, that did not work.
class VtcTrustException implements Exception {
  /// Creates a [VtcTrustException].
  const VtcTrustException(this.failure);

  /// Why.
  final VtcTrustFailure failure;

  @override
  String toString() => 'VtcTrustException(${failure.name})';
}

/// The vouches between the member and one other member of a community.
class VtcEdges {
  /// Creates a [VtcEdges].
  const VtcEdges({this.outgoing, this.incoming});

  /// The member's vouch for the other member.
  final PublishedRelationship? outgoing;

  /// The other member's vouch for the member.
  final PublishedRelationship? incoming;

  /// Whether the other member vouched for the member and has not been
  /// vouched for back.
  bool get canVouchBack => incoming != null && outgoing == null;
}

/// What the community shows the member of another member's credentials.
class VtcMemberCredentials {
  /// Creates [VtcMemberCredentials].
  const VtcMemberCredentials({
    this.vouches = const [],
    this.publicCard,
    this.membership,
  });

  /// Every vouch naming the other member, either way round and with anyone.
  final List<PublishedRelationship> vouches;

  /// The external card the other member published, as they signed it.
  final Map<String, dynamic>? publicCard;

  /// The membership pair the community holds for them, shown to an
  /// administrator who manages members only.
  final MemberCredentials? membership;

  /// Whether the community shows the member none at all.
  bool get isEmpty =>
      vouches.isEmpty && publicCard == null && membership == null;
}

/// Vouching for other members of the communities the member belongs to:
/// finding them in the community's directory, remembering which member a
/// contact is, and publishing, reading and withdrawing vouches.
///
/// A vouch names the identities the two joined the community with, never
/// a Meeting Place DID. The member only ever withdraws their own vouches,
/// and vouching again while one stands publishes nothing, as a new vouch
/// would replace the standing one. Never logs a DID or a name.
class VtcTrustService {
  /// Creates a [VtcTrustService].
  VtcTrustService(this._ref, {VtcRepository? repository})
    : _repository = repository ?? SecureStorageVtcRepository();

  static const _logKey = 'VtcTrustService';

  final Ref _ref;
  final VtcRepository _repository;

  VtcService get _vtc => _ref.read(vtcServiceProvider);

  AppLogger get _logger => _ref.read(appLoggerProvider);

  /// The communities the member can vouch in: those they are a member of.
  Future<List<VtcCommunity>> communities() async => [
    ...(await _repository.communities()).where((c) => c.isMember),
  ];

  /// The communities in which the member picked who the contact
  /// [channelDid] is.
  Future<List<VtcMemberLink>> links(String channelDid) =>
      _repository.memberLinks(channelDid: channelDid);

  /// The other members of [communityDid] whose entries match [query].
  ///
  /// Throws [VtcTrustException].
  Future<List<DirectoryEntry>> findMembers(
    String communityDid, {
    required String query,
  }) => _guard('finding members', () async {
    final me = await _personaDid(communityDid);
    final found = await _vtc.searchMembers(communityDid, query: query);
    return [...found.where((entry) => entry.did != me)];
  });

  /// The other active members of the group [groupId] of [communityDid], as
  /// the directory shows them to the member. A member whose entry shows
  /// the member nothing is left out.
  ///
  /// Throws [VtcTrustException].
  Future<List<DirectoryEntry>> groupMembers(
    String communityDid, {
    required String groupId,
  }) => _guard('reading group members', () async {
    await _personaDid(communityDid);
    final me = (await _vtc.myDirectoryCard(communityDid)).entryId;
    final entries = <DirectoryEntry>[];
    for (final member in await _vtc.groupMembers(
      communityDid,
      groupId: groupId,
    )) {
      if (!member.isActive || member.entryId == me) continue;
      final entry = await _vtc.memberEntry(
        communityDid,
        entryId: member.entryId,
      );
      if (entry != null) entries.add(entry);
    }
    return entries;
  });

  /// The credentials of the member of [entry] in [communityDid] that the
  /// community shows the member: the vouches naming them, their external
  /// card if they published one, and the membership pair when the member
  /// manages members. A card or pair the community will not show is left
  /// out.
  ///
  /// Throws [VtcTrustException] when the vouches cannot be read.
  Future<VtcMemberCredentials> memberCredentials(
    String communityDid, {
    required DirectoryEntry entry,
  }) async {
    final did = entry.did;
    final vouches = did == null
        ? const <PublishedRelationship>[]
        : await _guard(
            'reading vouches',
            () => _vtc.relationshipsNaming(communityDid, did: did),
          );
    return VtcMemberCredentials(
      vouches: vouches,
      publicCard: await _shownOrNull(
        'reading a public card',
        () => _vtc.memberPublicCard(communityDid, entryId: entry.entryId),
      ),
      membership: did == null
          ? null
          : await _shownOrNull(
              'reading a membership',
              () => _vtc.memberCredentials(communityDid, did: did),
            ),
    );
  }

  /// What [read] answers, or null when the community does not show it or
  /// cannot be asked: one credential missing leaves the others to show.
  Future<T?> _shownOrNull<T>(String action, Future<T?> Function() read) async {
    try {
      return await read();
    } on MeetingPlaceVtcSDKException catch (error) {
      _logger.info(
        'Not shown $action: ${error.refusalCode ?? error.code.name}',
        name: _logKey,
      );
      return null;
    }
  }

  /// Remembers that the contact [channelDid] is the member of [entry] in
  /// [communityDid].
  ///
  /// Throws [VtcTrustException] with [VtcTrustFailure.notFindable] when the
  /// entry shows no DID to vouch for.
  Future<VtcMemberLink> link({
    required String channelDid,
    required String communityDid,
    required DirectoryEntry entry,
  }) async {
    final personaDid = entry.did;
    if (personaDid == null) {
      throw const VtcTrustException(VtcTrustFailure.notFindable);
    }
    final link = VtcMemberLink(
      communityDid: communityDid,
      channelDid: channelDid,
      entryId: entry.entryId,
      personaDid: personaDid,
      name: entry.displayName ?? entry.nickname ?? '',
      linkedAt: DateTime.now(),
    );
    await _repository.saveMemberLink(link);
    return link;
  }

  /// The vouches between the member and [personaDid] in [communityDid].
  ///
  /// Throws [VtcTrustException].
  Future<VtcEdges> edgesWith(String communityDid, String personaDid) async =>
      (await edgesByMember(communityDid))[personaDid] ?? const VtcEdges();

  /// The vouches between the member and every other member of
  /// [communityDid], by that member's DID.
  ///
  /// Throws [VtcTrustException].
  Future<Map<String, VtcEdges>> edgesByMember(String communityDid) =>
      _guard('reading vouches', () async {
        final me = await _personaDid(communityDid);
        final edges = <String, VtcEdges>{};
        for (final edge in await _vtc.relationshipsOf(communityDid)) {
          if (edge.issuerDid == me) {
            final other = edges[edge.subjectDid] ?? const VtcEdges();
            edges[edge.subjectDid] = VtcEdges(
              outgoing: edge,
              incoming: other.incoming,
            );
          } else if (edge.subjectDid == me) {
            final other = edges[edge.issuerDid] ?? const VtcEdges();
            edges[edge.issuerDid] = VtcEdges(
              outgoing: other.outgoing,
              incoming: edge,
            );
          }
        }
        return edges;
      });

  /// Vouches for [personaDid] in [communityDid], or returns the member's
  /// standing vouch for them without publishing another.
  ///
  /// Throws [VtcTrustException].
  Future<PublishedRelationship> vouch(
    String communityDid, {
    required String personaDid,
  }) async {
    final standing = (await edgesWith(communityDid, personaDid)).outgoing;
    if (standing != null) return standing;
    return _guard(
      'vouching',
      () => _vtc.publishRelationship(communityDid, subjectDid: personaDid),
    );
  }

  /// Withdraws [edge], the member's own vouch in [communityDid].
  ///
  /// Throws [ArgumentError] for a vouch the member did not make, and
  /// [VtcTrustException].
  Future<void> withdraw(String communityDid, PublishedRelationship edge) async {
    final me = await _guard('withdrawing', () => _personaDid(communityDid));
    if (edge.issuerDid != me) {
      throw ArgumentError.value(edge.id, 'edge', 'is not the member\'s');
    }
    await _guard(
      'withdrawing',
      () => _vtc.withdrawRelationship(communityDid, id: edge.id),
    );
  }

  /// The member's own directory card in [communityDid]: the name other
  /// members see, and whether they can find the member.
  ///
  /// Throws [VtcTrustException].
  Future<MyDirectoryCard> directoryCard(String communityDid) => _guard(
    'reading the directory card',
    () => _vtc.myDirectoryCard(communityDid),
  );

  /// The DID of the identity the member joined [communityDid] with, or null
  /// when they are no member.
  Future<String?> identityDid(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    return community != null && community.isMember
        ? community.personaDid
        : null;
  }

  /// Sets the name other members of [communityDid] see for the member, or
  /// clears it when [name] is blank.
  ///
  /// Throws [VtcTrustException], with [VtcTrustFailure.nameRefused] when the
  /// community does not take the name.
  Future<void> setDirectoryName(String communityDid, {required String name}) =>
      _guard(
        'changing the directory name',
        () => _vtc.setDirectoryName(communityDid, name: name),
      );

  /// Lets other members of [communityDid] find the member when
  /// [findable], or stops them otherwise.
  ///
  /// Throws [VtcTrustException], with [VtcTrustFailure.notAllowed] when the
  /// community does not let members be found.
  Future<void> setFindable(String communityDid, {required bool findable}) =>
      _guard(
        'changing the directory card',
        () => _vtc.setFindableByMembers(communityDid, findable: findable),
      );

  Future<String> _personaDid(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) {
      throw const NotACommunityMemberException();
    }
    return community.personaDid;
  }

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on VtcTrustException {
      rethrow;
    } on NotACommunityMemberException {
      throw _failed(action, VtcTrustFailure.notMember);
    } on VtaNotLinkedException {
      throw _failed(action, VtcTrustFailure.vtaUnavailable);
    } on MeetingPlaceVtcSDKException catch (error) {
      throw _failed(action, _failureOf(error), code: error.refusalCode);
    }
  }

  VtcTrustException _failed(
    String action,
    VtcTrustFailure failure, {
    String? code,
  }) {
    _logger.warning('Failed $action: ${code ?? failure.name}', name: _logKey);
    return VtcTrustException(failure);
  }

  static VtcTrustFailure _failureOf(MeetingPlaceVtcSDKException error) =>
      switch (error.code) {
        MeetingPlaceVtcSDKErrorCode.refused => switch (error.refusalCode) {
          RelationshipTask.subjectNotMember => VtcTrustFailure.contactNotMember,
          RelationshipTask.vrcInvalid => VtcTrustFailure.proofRejected,
          DirectoryTask.queryTooShort => VtcTrustFailure.searchTooShort,
          DirectoryTask.valueInvalid ||
          DirectoryTask.valueRefused => VtcTrustFailure.nameRefused,
          DirectoryTask.aboveCeiling ||
          'permissionDenied' => VtcTrustFailure.notAllowed,
          'unavailable' => VtcTrustFailure.tryLater,
          final code? when code.endsWith(':rateLimited') =>
            VtcTrustFailure.tryLater,
          _ => VtcTrustFailure.failed,
        },
        MeetingPlaceVtcSDKErrorCode.transportFailed ||
        MeetingPlaceVtcSDKErrorCode.didResolutionFailed =>
          VtcTrustFailure.network,
        _ => VtcTrustFailure.failed,
      };
}

/// The app's [VtcTrustService].
final vtcTrustServiceProvider = Provider<VtcTrustService>(
  VtcTrustService.new,
  name: 'vtcTrustServiceProvider',
);
