import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';

import '../../../mocks/fake_app_logger.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';
const _carol = 'did:webvh:QmCarol:vta.example:carol';

PublishedRelationship _edge(String id, String issuer, String subject) =>
    PublishedRelationship(
      id: id,
      issuerDid: issuer,
      subjectDid: subject,
      vrcDigestMultibase: 'zQm$id',
    );

/// The member's community, as far as vouching asks it.
class _FakeVtcService extends Fake implements VtcService {
  List<PublishedRelationship> edges = [];
  List<DirectoryEntry> found = [];
  MeetingPlaceVtcSDKException? refusal;
  Exception? failure;
  final List<String> published = [];
  final List<String> withdrawn = [];
  bool findable = false;

  Future<void> _fail() async {
    if (failure case final failure?) throw failure;
    if (refusal case final refusal?) throw refusal;
  }

  @override
  Future<List<PublishedRelationship>> relationshipsOf(
    String communityDid,
  ) async => edges;

  @override
  Future<PublishedRelationship> publishRelationship(
    String communityDid, {
    required String subjectDid,
  }) async {
    await _fail();
    published.add(subjectDid);
    final edge = _edge('edge-${published.length}', _me, subjectDid);
    edges = [...edges, edge];
    return edge;
  }

  @override
  Future<void> withdrawRelationship(
    String communityDid, {
    required String id,
  }) async {
    await _fail();
    withdrawn.add(id);
  }

  @override
  Future<List<DirectoryEntry>> searchMembers(
    String communityDid, {
    required String query,
  }) async {
    await _fail();
    return found;
  }

  List<VtcGroupMember> groupMembersList = const [];
  Map<String, DirectoryEntry> entries = const {};

  /// The groups the member is in, and each one's members by its id, else
  /// [groupMembersList].
  List<VtcGroupListing> groups = const [];
  Map<String, List<VtcGroupMember>> membersOf = const {};
  final List<String> groupsRead = [];

  @override
  Future<List<VtcGroupListing>> memberGroups(String communityDid) async {
    await _fail();
    return groups;
  }

  @override
  Future<List<VtcGroupMember>> groupMembers(
    String communityDid, {
    required String groupId,
  }) async {
    await _fail();
    groupsRead.add(groupId);
    return membersOf[groupId] ?? groupMembersList;
  }

  @override
  Future<DirectoryEntry?> memberEntry(
    String communityDid, {
    required String entryId,
  }) async => entries[entryId];

  List<PublishedRelationship> naming = [];
  Map<String, dynamic>? publicCard;
  MemberCredentials? membership;
  MeetingPlaceVtcSDKException? cardRefusal;
  MeetingPlaceVtcSDKException? membershipRefusal;

  @override
  Future<List<PublishedRelationship>> relationshipsNaming(
    String communityDid, {
    required String did,
  }) async {
    await _fail();
    return naming;
  }

  @override
  Future<Map<String, dynamic>?> memberPublicCard(
    String communityDid, {
    required String entryId,
  }) async {
    if (cardRefusal case final refusal?) throw refusal;
    return publicCard;
  }

  @override
  Future<MemberCredentials?> memberCredentials(
    String communityDid, {
    required String did,
  }) async {
    if (membershipRefusal case final refusal?) throw refusal;
    return membership;
  }

  final List<Uint8List?> pictures = [];
  int pictureFetches = 0;

  @override
  Future<void> setDirectoryPicture(
    String communityDid, {
    required Uint8List? jpeg,
  }) async {
    await _fail();
    pictures.add(jpeg);
  }

  @override
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required String entryId,
    required String sha256,
  }) async {
    pictureFetches++;
    return Uint8List.fromList([1, 2, 3]);
  }

  String? directoryName;

  @override
  Future<MyDirectoryCard> myDirectoryCard(String communityDid) async =>
      MyDirectoryCard(
        entryId: 'dir_me',
        isDidVisibleToMembers: findable,
        displayName: directoryName,
      );

  @override
  Future<void> setDirectoryName(
    String communityDid, {
    required String name,
  }) async {
    await _fail();
    directoryName = name;
  }

  @override
  Future<void> setFindableByMembers(
    String communityDid, {
    required bool findable,
  }) async {
    await _fail();
    this.findable = findable;
  }
}

void main() {
  late _FakeVtcService vtc;
  late SecureStorageVtcRepository repository;
  late VtcTrustService service;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    vtc = _FakeVtcService();
    repository = SecureStorageVtcRepository();
    await repository.saveCommunity(
      const VtcCommunity(
        communityDid: _club,
        personaDid: _me,
        contextId: 'vta',
        name: 'Football club',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        vtcServiceProvider.overrideWithValue(vtc),
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
        vtcTrustServiceProvider.overrideWith(
          (ref) => VtcTrustService(ref, repository: repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    service = container.read(vtcTrustServiceProvider);
  });

  Matcher throwsFailure(VtcTrustFailure failure) => throwsA(
    isA<VtcTrustException>().having((e) => e.failure, 'failure', failure),
  );

  group('VtcTrustService.communities', () {
    test('lists the communities the member belongs to only', () async {
      await repository.saveCommunity(
        const VtcCommunity(
          communityDid: 'did:webvh:QmChess:vtc.example',
          personaDid: _me,
          contextId: 'vta',
          isMember: false,
          joinRequestId: 'request-1',
        ),
      );

      final communities = await service.communities();

      expect(communities.map((c) => c.communityDid), [_club]);
    });
  });

  group('VtcTrustService.findMembers and link', () {
    test('finds other members, leaving out the member', () async {
      vtc.found = const [
        DirectoryEntry(entryId: 'dir_me', displayName: 'Me', did: _me),
        DirectoryEntry(entryId: 'dir_bob', displayName: 'Bob', did: _bob),
      ];

      final found = await service.findMembers(_club, query: 'Bob');

      expect(found.map((e) => e.entryId), ['dir_bob']);
    });

    test('says when a search is too short', () {
      vtc.refusal = MeetingPlaceVtcSDKException.refused(
        DirectoryTask.queryTooShort,
      );

      expect(
        service.findMembers(_club, query: 'Bo'),
        throwsFailure(VtcTrustFailure.searchTooShort),
      );
    });

    test('remembers which member a contact is', () async {
      await service.link(
        channelDid: 'did:web:channel-bob',
        communityDid: _club,
        entry: const DirectoryEntry(
          entryId: 'dir_bob',
          displayName: 'Bob',
          did: _bob,
        ),
      );

      final link = (await service.links('did:web:channel-bob')).single;
      expect(link.communityDid, _club);
      expect(link.personaDid, _bob);
      expect(link.name, 'Bob');
    });

    test('refuses a member who has not let members find them', () async {
      await expectLater(
        service.link(
          channelDid: 'did:web:channel-bob',
          communityDid: _club,
          entry: const DirectoryEntry(entryId: 'dir_bob', displayName: 'Bob'),
        ),
        throwsFailure(VtcTrustFailure.notFindable),
      );
      expect(await service.links('did:web:channel-bob'), isEmpty);
    });
  });

  group('VtcTrustService.groupMembers', () {
    test(
      'lists the other active members as the directory shows them',
      () async {
        vtc
          ..groupMembersList = const [
            VtcGroupMember(entryId: 'dir_me', state: 'active'),
            VtcGroupMember(entryId: 'dir_bob', state: 'active'),
            VtcGroupMember(entryId: 'dir_new', state: 'pending'),
            VtcGroupMember(entryId: 'dir_hidden', state: 'active'),
          ]
          ..entries = const {
            'dir_me': DirectoryEntry(entryId: 'dir_me', did: _me),
            'dir_bob': DirectoryEntry(
              entryId: 'dir_bob',
              displayName: 'Bob',
              did: _bob,
            ),
            'dir_new': DirectoryEntry(entryId: 'dir_new', displayName: 'New'),
          };

        final members = await service.groupMembers(_club, groupId: 'g1');

        expect(members.map((m) => m.entryId), ['dir_bob']);
      },
    );

    test('says when the group hides its members', () {
      vtc.refusal = MeetingPlaceVtcSDKException.refused('permissionDenied');

      expect(
        service.groupMembers(_club, groupId: 'g1'),
        throwsFailure(VtcTrustFailure.notAllowed),
      );
    });
  });

  group('VtcTrustService.communityMembers', () {
    VtcGroupListing listing(
      String groupId, {
      GroupStanding standing = GroupStanding.member,
      GroupAudience showMembers = GroupAudience.groupMembers,
    }) => VtcGroupListing(
      group: VtcGroup(
        groupId: groupId,
        groupDid: 'did:webvh:QmGroup:vtc.example:group-dids:$groupId',
        name: groupId,
        isDynamic: false,
        visibility: GroupAudience.members,
        showMembers: showMembers,
      ),
      standing: standing,
    );

    setUp(() {
      vtc.entries = const {
        'dir_me': DirectoryEntry(entryId: 'dir_me', did: _me),
        'dir_bob': DirectoryEntry(
          entryId: 'dir_bob',
          displayName: 'Bob',
          did: _bob,
        ),
        'dir_carol': DirectoryEntry(
          entryId: 'dir_carol',
          displayName: 'Carol',
          did: _carol,
        ),
      };
    });

    test(
      "lists the other active members of the member's groups once",
      () async {
        vtc
          ..groups = [listing('everyone'), listing('board')]
          ..membersOf = const {
            'everyone': [
              VtcGroupMember(entryId: 'dir_me', state: 'active'),
              VtcGroupMember(entryId: 'dir_bob', state: 'active'),
              VtcGroupMember(entryId: 'dir_carol', state: 'pending'),
            ],
            'board': [
              VtcGroupMember(entryId: 'dir_bob', state: 'active'),
              VtcGroupMember(entryId: 'dir_carol', state: 'active'),
            ],
          };

        final members = await service.communityMembers(_club);

        expect(members.map((m) => m.entryId), ['dir_bob', 'dir_carol']);
      },
    );

    test('leaves out groups the member is not in or cannot see', () async {
      vtc
        ..groups = [
          listing('everyone'),
          listing('waiting', standing: GroupStanding.pending),
          listing('admins', showMembers: GroupAudience.admins),
        ]
        ..membersOf = const {
          'everyone': [VtcGroupMember(entryId: 'dir_bob', state: 'active')],
        };

      final members = await service.communityMembers(_club);

      expect(members.map((m) => m.entryId), ['dir_bob']);
      expect(vtc.groupsRead, ['everyone']);
    });

    test('says why the community did not answer', () {
      vtc.failure = MeetingPlaceVtcSDKException.transportFailed('down');

      expect(
        service.communityMembers(_club),
        throwsFailure(VtcTrustFailure.network),
      );
    });
  });

  group('VtcTrustService.memberCredentials', () {
    const bobEntry = DirectoryEntry(
      entryId: 'dir_bob',
      displayName: 'Bob',
      did: _bob,
    );

    test('gathers what the community shows of a member', () async {
      vtc
        ..naming = [_edge('edge-1', _carol, _bob)]
        ..publicCard = {'@type': 'Card'}
        ..membership = const MemberCredentials(
          membershipCredential: {'id': 'urn:uuid:vmc'},
        );

      final shown = await service.memberCredentials(_club, entry: bobEntry);

      expect(shown.vouches.single.id, 'edge-1');
      expect(shown.publicCard, {'@type': 'Card'});
      expect(shown.membership?.membershipCredential, {'id': 'urn:uuid:vmc'});
      expect(shown.isEmpty, isFalse);
    });

    test('leaves out what the community will not show', () async {
      vtc
        ..naming = [_edge('edge-1', _bob, _me)]
        ..cardRefusal = MeetingPlaceVtcSDKException.transportFailed('down')
        ..membershipRefusal = MeetingPlaceVtcSDKException.refused(
          'permissionDenied',
        );

      final shown = await service.memberCredentials(_club, entry: bobEntry);

      expect(shown.vouches, hasLength(1));
      expect(shown.publicCard, isNull);
      expect(shown.membership, isNull);
    });

    test('reads no vouches of a member who shows no DID', () async {
      vtc.publicCard = {'@type': 'Card'};

      final shown = await service.memberCredentials(
        _club,
        entry: const DirectoryEntry(entryId: 'dir_bob', displayName: 'Bob'),
      );

      expect(shown.vouches, isEmpty);
      expect(shown.publicCard, isNotNull);
      expect(shown.membership, isNull);
    });

    test('says why the vouches could not be read', () {
      vtc.refusal = MeetingPlaceVtcSDKException.transportFailed('down');

      expect(
        service.memberCredentials(_club, entry: bobEntry),
        throwsFailure(VtcTrustFailure.network),
      );
    });
  });

  group('VtcTrustService pictures', () {
    String pictureOf(int width, int height) =>
        base64Encode(img.encodePng(img.Image(width: width, height: height)));

    test('scales an identity\'s picture for the directory', () {
      final jpeg = directoryPicture(pictureOf(1000, 500))!;

      final scaled = img.decodeJpg(jpeg)!;
      expect(scaled.width, directoryPictureSide);
      expect(scaled.height, directoryPictureSide ~/ 2);
      expect(jpeg.length, lessThanOrEqualTo(directoryPictureMaxBytes));
    });

    test('keeps a small picture its size', () {
      final scaled = img.decodeJpg(directoryPicture(pictureOf(100, 200))!)!;

      expect((scaled.width, scaled.height), (100, 200));
    });

    test('takes no picture from what is none', () {
      expect(directoryPicture('not base64!'), isNull);
      expect(directoryPicture(base64Encode([1, 2, 3])), isNull);
    });

    test('sends the identity\'s picture, or takes it off', () async {
      await service.setDirectoryPicture(_club, base64: pictureOf(10, 10));
      await service.setDirectoryPicture(_club, base64: null);

      expect(vtc.pictures.first, isNotNull);
      expect(vtc.pictures.last, isNull);
    });

    test('fetches a member\'s picture once', () async {
      const entry = DirectoryEntry(entryId: 'dir_bob', avatarSha256: 'abc');

      await service.memberPicture(_club, entry: entry);
      final again = await service.memberPicture(_club, entry: entry);

      expect(again, [1, 2, 3]);
      expect(vtc.pictureFetches, 1);
    });

    test('fetches nothing for a member who shows no picture', () async {
      final picture = await service.memberPicture(
        _club,
        entry: const DirectoryEntry(entryId: 'dir_bob'),
      );

      expect(picture, isNull);
      expect(vtc.pictureFetches, 0);
    });
  });

  group('VtcTrustService.edgesWith', () {
    test('tells the member\'s vouch from the other member\'s', () async {
      vtc.edges = [
        _edge('edge-1', _me, _bob),
        _edge('edge-2', _carol, _me),
        _edge('edge-3', _bob, _carol),
      ];

      final bob = await service.edgesWith(_club, _bob);
      final carol = await service.edgesWith(_club, _carol);

      expect(bob.outgoing?.id, 'edge-1');
      expect(bob.incoming, isNull);
      expect(bob.canVouchBack, isFalse);
      expect(carol.outgoing, isNull);
      expect(carol.incoming?.id, 'edge-2');
      expect(carol.canVouchBack, isTrue);
    });

    test('knows nothing of members without vouches', () async {
      final edges = await service.edgesWith(_club, _bob);

      expect(edges.outgoing, isNull);
      expect(edges.incoming, isNull);
    });
  });

  group('VtcTrustService.vouch', () {
    test('vouches for a member', () async {
      final edge = await service.vouch(_club, personaDid: _bob);

      expect(vtc.published, [_bob]);
      expect(edge.subjectDid, _bob);
    });

    test('publishes nothing while the member\'s vouch stands', () async {
      await service.vouch(_club, personaDid: _bob);
      final again = await service.vouch(_club, personaDid: _bob);

      expect(vtc.published, [_bob]);
      expect(again.id, 'edge-1');
    });

    test('vouches back for a member who vouched first', () async {
      vtc.edges = [_edge('edge-0', _bob, _me)];

      await service.vouch(_club, personaDid: _bob);

      expect(vtc.published, [_bob]);
    });

    test('refuses a community the member left', () async {
      await repository.removeCommunity(_club);

      await expectLater(
        service.vouch(_club, personaDid: _bob),
        throwsFailure(VtcTrustFailure.notMember),
      );
      expect(vtc.published, isEmpty);
    });

    for (final (code, failure) in [
      (RelationshipTask.subjectNotMember, VtcTrustFailure.contactNotMember),
      (RelationshipTask.vrcInvalid, VtcTrustFailure.proofRejected),
      ('permissionDenied', VtcTrustFailure.notAllowed),
      ('unavailable', VtcTrustFailure.tryLater),
      ('vtc/relationships/publish:somethingNew', VtcTrustFailure.failed),
    ]) {
      test('says ${failure.name} for the refusal $code', () {
        vtc.refusal = MeetingPlaceVtcSDKException.refused(code);

        expect(service.vouch(_club, personaDid: _bob), throwsFailure(failure));
      });
    }

    test('says when the community cannot be reached', () {
      vtc.refusal = MeetingPlaceVtcSDKException.transportFailed('down');

      expect(
        service.vouch(_club, personaDid: _bob),
        throwsFailure(VtcTrustFailure.network),
      );
    });

    test('says when no VTA is linked', () {
      vtc.failure = const VtaNotLinkedException();

      expect(
        service.vouch(_club, personaDid: _bob),
        throwsFailure(VtcTrustFailure.vtaUnavailable),
      );
    });
  });

  group('VtcTrustService.withdraw', () {
    test('withdraws the member\'s own vouch', () async {
      await service.withdraw(_club, _edge('edge-1', _me, _bob));

      expect(vtc.withdrawn, ['edge-1']);
    });

    test('never withdraws another member\'s vouch', () async {
      await expectLater(
        service.withdraw(_club, _edge('edge-2', _bob, _me)),
        throwsArgumentError,
      );
      expect(vtc.withdrawn, isEmpty);
    });
  });

  group('VtcTrustService directory card', () {
    test('reads and sets whether members can find the member', () async {
      expect((await service.directoryCard(_club)).isDidVisibleToMembers, false);

      await service.setFindable(_club, findable: true);

      expect((await service.directoryCard(_club)).isDidVisibleToMembers, true);
    });

    test('reads and sets the name members see', () async {
      expect((await service.directoryCard(_club)).displayName, isNull);

      await service.setDirectoryName(_club, name: 'Ada');

      expect((await service.directoryCard(_club)).displayName, 'Ada');
    });

    test('says when the community does not take the name', () {
      vtc.refusal = MeetingPlaceVtcSDKException.refused(
        DirectoryTask.valueRefused,
      );

      expect(
        service.setDirectoryName(_club, name: 'Ada'),
        throwsFailure(VtcTrustFailure.nameRefused),
      );
    });

    test('names the identity the member joined with', () async {
      expect(await service.identityDid(_club), _me);
      expect(await service.identityDid('did:webvh:QmOther:vtc.example'), null);
    });

    test('says when the community does not let members be found', () {
      vtc.refusal = MeetingPlaceVtcSDKException.refused(
        DirectoryTask.aboveCeiling,
      );

      expect(
        service.setFindable(_club, findable: true),
        throwsFailure(VtcTrustFailure.notAllowed),
      );
    });
  });
}
