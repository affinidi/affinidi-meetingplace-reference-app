import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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

  @override
  Future<MyDirectoryCard> myDirectoryCard(String communityDid) async =>
      MyDirectoryCard(entryId: 'dir_me', isDidVisibleToMembers: findable);

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

  group('VtcTrustService findable', () {
    test('reads and sets whether members can find the member', () async {
      expect(await service.isFindable(_club), isFalse);

      await service.setFindable(_club, findable: true);

      expect(await service.isFindable(_club), isTrue);
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
