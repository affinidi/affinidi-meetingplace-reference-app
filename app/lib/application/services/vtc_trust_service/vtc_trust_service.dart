import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
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

  /// How many reads a list of members sends to the community at once: each
  /// waits on the VTA's mediator, so reading together saves most of the
  /// wait, while a cap keeps a large community from flooding either.
  static const _parallelReads = 6;

  final Ref _ref;
  final VtcRepository _repository;

  /// Pictures fetched, by the digest that names each.
  final Map<String, Uint8List> _pictures = {};

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
    return _otherActiveEntries(
      communityDid,
      await _vtc.groupMembers(communityDid, groupId: groupId),
    );
  });

  /// The other active members of the groups of [communityDid] the member is
  /// in, each once, as the directory shows them to the member. A community
  /// puts every member in some groups, such as announcements, so these are
  /// the members the member can see without searching. A group that shows
  /// its members to administrators only is left out.
  ///
  /// Throws [VtcTrustException].
  Future<List<DirectoryEntry>> communityMembers(String communityDid) =>
      _guard('reading community members', () async {
        await _personaDid(communityDid);
        final groups = [
          for (final VtcGroupListing(:group, :standing)
              in await _vtc.memberGroups(communityDid))
            if (standing == GroupStanding.member &&
                group.showMembers != GroupAudience.admins)
              group,
        ];
        final members = <String, VtcGroupMember>{};
        for (final groupMembers in await Future.wait([
          for (final group in groups)
            _vtc.groupMembers(communityDid, groupId: group.groupId),
        ])) {
          for (final member in groupMembers) {
            // Active in one group is enough, whatever the others say.
            if (member.isActive) members[member.entryId] = member;
          }
        }
        return _otherActiveEntries(communityDid, members.values);
      });

  /// The directory entries of the active ones of [members], other than the
  /// member, that the directory shows the member.
  Future<List<DirectoryEntry>> _otherActiveEntries(
    String communityDid,
    Iterable<VtcGroupMember> members,
  ) async {
    final me = (await _vtc.myDirectoryCard(communityDid)).entryId;
    final others = members.where(
      (member) => member.isActive && member.entryId != me,
    );
    final entries = <DirectoryEntry>[];
    for (final batch in others.slices(_parallelReads)) {
      final read = await Future.wait([
        for (final member in batch)
          _vtc.memberEntry(communityDid, entryId: member.entryId),
      ]);
      entries.addAll(read.nonNulls);
    }
    return entries;
  }

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

  /// Shows every member of [communityDid] the picture of the identity the
  /// member joined with, [base64] as its contact card holds it, scaled for
  /// the directory; takes the picture off when [base64] is null or holds no
  /// picture.
  ///
  /// Throws [VtcTrustException].
  Future<void> setDirectoryPicture(
    String communityDid, {
    required String? base64,
  }) => _guard(
    'changing the directory picture',
    () => _vtc.setDirectoryPicture(
      communityDid,
      jpeg: base64 == null ? null : directoryPicture(base64),
    ),
  );

  /// The directory entry [entryId] of [communityDid] as the community shows
  /// it to the member, or null when it shows none or cannot be asked.
  Future<DirectoryEntry?> memberEntry(
    String communityDid, {
    required String entryId,
  }) => _shownOrNull(
    'reading an entry',
    () => _vtc.memberEntry(communityDid, entryId: entryId),
  );

  /// The picture the member of [entry] in [communityDid] shows the member,
  /// or null when they show none or it cannot be fetched. Kept while the
  /// app runs, by the digest that names it.
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required DirectoryEntry entry,
  }) async {
    final sha256 = entry.avatarSha256;
    if (sha256 == null) return null;
    if (_pictures[sha256] case final picture?) return picture;
    final picture = await _shownOrNull(
      'reading a picture',
      () => _vtc.memberPicture(
        communityDid,
        entryId: entry.entryId,
        sha256: sha256,
      ),
    );
    if (picture != null) _pictures[sha256] = picture;
    return picture;
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

/// Longest side of a picture on a directory card, in pixels.
const directoryPictureSide = 256;

/// Most bytes a community takes for a picture.
const directoryPictureMaxBytes = 256 * 1024;

/// [base64], an identity's picture, as a JPEG a community takes on a
/// directory card: no side longer than [directoryPictureSide], and no more
/// than [directoryPictureMaxBytes]. Null when it holds no picture.
Uint8List? directoryPicture(String base64) {
  final Uint8List bytes;
  try {
    bytes = base64Decode(base64);
  } on FormatException {
    return null;
  }
  // Only a picture's own signature reaches a decoder: decoders guessing at
  // other bytes can read past their end rather than answer null.
  if (!_isPicture(bytes)) return null;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final scaled = decoded.width >= decoded.height
      ? img.copyResize(decoded, width: min(decoded.width, directoryPictureSide))
      : img.copyResize(
          decoded,
          height: min(decoded.height, directoryPictureSide),
        );
  for (var quality = 85; quality >= 40; quality -= 15) {
    final jpeg = img.encodeJpg(scaled, quality: quality);
    if (jpeg.length <= directoryPictureMaxBytes) return jpeg;
  }
  return null;
}

/// Whether [bytes] start as a PNG, JPEG, GIF or WebP picture does.
bool _isPicture(Uint8List bytes) {
  bool startsWith(List<int> signature, [int at = 0]) =>
      bytes.length >= at + signature.length &&
      listEquals(bytes.sublist(at, at + signature.length), signature);
  return startsWith(const [0x89, 0x50, 0x4e, 0x47]) ||
      startsWith(const [0xff, 0xd8, 0xff]) ||
      startsWith(ascii.encode('GIF8')) ||
      (startsWith(ascii.encode('RIFF')) && startsWith(ascii.encode('WEBP'), 8));
}

/// The app's [VtcTrustService].
final vtcTrustServiceProvider = Provider<VtcTrustService>(
  VtcTrustService.new,
  name: 'vtcTrustServiceProvider',
);
