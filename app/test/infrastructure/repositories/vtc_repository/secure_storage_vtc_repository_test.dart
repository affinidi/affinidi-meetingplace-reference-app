import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_left_membership.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_member_link.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetter_desk.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetting.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';

void main() {
  final leftAt = DateTime.utc(2026, 11, 5, 9, 40);
  VtcLeftMembership left({String cardId = 'urn:uuid:card'}) =>
      VtcLeftMembership(
        communityDid: 'did:webvh:community',
        personaDid: 'did:webvh:persona',
        leftAt: leftAt,
        name: 'Football club',
        card: {'id': cardId, 'issuer': 'did:webvh:community'},
      );

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('SecureStorageVtcRepository left memberships', () {
    test('keeps a left membership with its last status', () async {
      final checkedAt = DateTime.utc(2026, 11, 5, 10);
      await SecureStorageVtcRepository().saveLeftMembership(
        left().withStatus(
          VtcStatusRecord(
            revoked: true,
            checkedAt: checkedAt,
            statusList: const {'type': 'BitstringStatusListCredential'},
          ),
        ),
      );

      final stored =
          (await SecureStorageVtcRepository().leftMemberships()).single;
      expect(stored.name, 'Football club');
      expect(stored.leftAt, leftAt);
      expect(stored.card?['id'], 'urn:uuid:card');
      expect(stored.lastStatus?.revoked, isTrue);
      expect(stored.lastStatus?.checkedAt, checkedAt);
    });

    test('replaces the record of the same card, keeps others', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveLeftMembership(left());
      await repository.saveLeftMembership(left(cardId: 'urn:uuid:other'));
      await repository.saveLeftMembership(
        left().withStatus(
          VtcStatusRecord(
            revoked: true,
            checkedAt: leftAt,
            statusList: const {},
          ),
        ),
      );

      final stored = await repository.leftMemberships();
      expect(stored.map((left) => left.key), [
        'urn:uuid:other',
        'urn:uuid:card',
      ]);
      expect(stored.last.lastStatus?.revoked, isTrue);
    });

    test('forgets left memberships when cleared', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveLeftMembership(left());

      await repository.clear();

      expect(await repository.leftMemberships(), isEmpty);
    });
  });

  group('SecureStorageVtcRepository vetting', () {
    VtcVetting vetting(String communityDid) => VtcVetting(
      communityDid: communityDid,
      criterionId: 'vetted',
      vetterRole: 'vetter',
      salt: 'salt-1',
      requests: [
        const VtcVettingRequest(
          vetterDid: 'did:webvh:bob',
          vetterName: 'Bob',
          request: {
            'id': 'urn:uuid:request',
            'type': VettingTask.request,
            'issuer': 'did:webvh:alice',
            'recipient': 'did:webvh:bob',
            'payload': <String, dynamic>{},
          },
        ).acceptedBy(
          AcceptedVetter(
            vetterDid: 'did:webvh:bob',
            requestId: 'vr-1',
            roleValidUntil: DateTime.utc(2027),
          ),
        ),
        const VtcVettingRequest(
          vetterDid: 'did:webvh:carol',
          request: {'id': 'urn:uuid:other'},
        ).refused(VettingFailure.invalidTicket),
      ],
    );

    test('keeps the vetting for each community', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveVetting(vetting('did:webvh:club'));
      await repository.saveVetting(vetting('did:webvh:other'));

      final stored = (await SecureStorageVtcRepository().findVetting(
        'did:webvh:club',
      ))!;
      expect(stored.salt, 'salt-1');
      final [bob, carol] = stored.requests;
      expect(bob.status, VtcVettingStatus.accepted);
      expect(bob.vetterName, 'Bob');
      expect(bob.accepted?.requestId, 'vr-1');
      expect(bob.accepted?.roleValidUntil, DateTime.utc(2027));
      expect(bob.requestDocument.id, 'urn:uuid:request');
      expect(carol.status, VtcVettingStatus.refused);
      expect(carol.failure, VettingFailure.invalidTicket);
      expect(carol.isOpen, isFalse);
    });

    test('replaces a vetter\'s earlier request', () async {
      final updated = vetting('did:webvh:club').withRequest(
        const VtcVettingRequest(
          vetterDid: 'did:webvh:carol',
          request: {'id': 'urn:uuid:again'},
        ),
      );

      expect(updated.requests.map((r) => r.vetterDid), [
        'did:webvh:bob',
        'did:webvh:carol',
      ]);
      expect(updated.requestTo('did:webvh:carol')?.isOpen, isTrue);
    });

    test('forgets a community\'s vetting, and all of it on clear', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveVetting(vetting('did:webvh:club'));
      await repository.saveVetting(vetting('did:webvh:other'));

      await repository.removeVetting('did:webvh:club');
      expect(await repository.findVetting('did:webvh:club'), isNull);
      expect(await repository.findVetting('did:webvh:other'), isNotNull);

      await repository.clear();
      expect(await repository.findVetting('did:webvh:other'), isNull);
    });
  });

  group('SecureStorageVtcRepository vetter desks', () {
    final now = DateTime.utc(2026, 11, 6, 9);
    const request = VetterRequest(
      requestId: 'vr-1',
      requestDocumentId: 'urn:uuid:request',
      threadId: 'urn:uuid:request',
      applicantDid: 'did:webvh:alice',
    );

    VtcVetterDesk desk(String communityDid) {
      final ticket = VetterTicket.mint(
        community: communityDid,
        vetter: 'did:webvh:bob',
        now: now,
      );
      return VtcVetterDesk(communityDid: communityDid)
          .withTicket(ticket, now)
          .withSession(const VtcVetterSession(request: request).confirmed());
    }

    test('keeps the desk for each community', () async {
      final repository = SecureStorageVtcRepository();
      final club = desk('did:webvh:club');
      await repository.saveVetterDesk(club);
      await repository.saveVetterDesk(desk('did:webvh:other'));

      final stored = (await SecureStorageVtcRepository().findVetterDesk(
        'did:webvh:club',
      ))!;
      expect(stored.tickets.single.toJson(), club.tickets.single.toJson());
      final session = stored.sessionFor('vr-1')!;
      expect(session.status, VtcVetterSessionStatus.accepted);
      expect(session.matchConfirmed, isTrue);
      expect(session.request.applicantDid, 'did:webvh:alice');
      expect(session.isOpen, isTrue);
    });

    test('replaces a ticket and a session, dropping spent tickets', () {
      final club = desk('did:webvh:club');
      final ticket = club.tickets.single;

      final updated = club
          .withTicket(ticket.spent(), now)
          .withSession(club.sessions.single.issued('urn:uuid:statement'));

      expect(updated.tickets.single.usesLeft, 0);
      expect(updated.liveTickets(now), isEmpty);
      expect(
        updated
            .withTicket(
              VetterTicket.mint(
                community: 'did:webvh:club',
                vetter: 'did:webvh:bob',
                now: now,
              ),
              now,
            )
            .tickets,
        hasLength(1),
      );
      expect(updated.sessions.single.status, VtcVetterSessionStatus.issued);
      expect(updated.sessions.single.statementId, 'urn:uuid:statement');
      expect(updated.sessions.single.isOpen, isFalse);
    });

    test('forgets a community\'s desk, and every desk on clear', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveVetterDesk(desk('did:webvh:club'));
      await repository.saveVetterDesk(desk('did:webvh:other'));

      await repository.removeVetterDesk('did:webvh:club');
      expect(await repository.findVetterDesk('did:webvh:club'), isNull);
      expect(await repository.findVetterDesk('did:webvh:other'), isNotNull);

      await repository.clear();
      expect(await repository.findVetterDesk('did:webvh:other'), isNull);
    });
  });

  group('SecureStorageVtcRepository member links', () {
    final linkedAt = DateTime.utc(2026, 11, 9, 9);
    VtcMemberLink link({
      String community = 'did:webvh:club',
      String channel = 'did:web:channel-bob',
      String entryId = 'dir_bob',
    }) => VtcMemberLink(
      communityDid: community,
      channelDid: channel,
      entryId: entryId,
      personaDid: 'did:webvh:bob',
      name: 'Bob',
      linkedAt: linkedAt,
    );

    test('keeps a contact\'s link, as stored', () async {
      await SecureStorageVtcRepository().saveMemberLink(link());

      final stored = (await SecureStorageVtcRepository().memberLinks()).single;
      expect(stored.communityDid, 'did:webvh:club');
      expect(stored.channelDid, 'did:web:channel-bob');
      expect(stored.entryId, 'dir_bob');
      expect(stored.personaDid, 'did:webvh:bob');
      expect(stored.name, 'Bob');
      expect(stored.linkedAt, linkedAt);
    });

    test('replaces a contact\'s link in the same community only', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveMemberLink(link());
      await repository.saveMemberLink(link(community: 'did:webvh:chess'));
      await repository.saveMemberLink(link(entryId: 'dir_bob_2'));

      final links = await repository.memberLinks();
      expect(links, hasLength(2));
      expect(
        links.firstWhere((l) => l.communityDid == 'did:webvh:club').entryId,
        'dir_bob_2',
      );
    });

    test('lists the links of one contact', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveMemberLink(link());
      await repository.saveMemberLink(link(channel: 'did:web:channel-carol'));

      final bobs = await repository.memberLinks(
        channelDid: 'did:web:channel-bob',
      );
      expect(bobs.single.channelDid, 'did:web:channel-bob');
    });

    test('forgets a community\'s links, and every link on clear', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveMemberLink(link());
      await repository.saveMemberLink(link(community: 'did:webvh:chess'));

      await repository.removeMemberLinks('did:webvh:club');
      expect((await repository.memberLinks()).map((l) => l.communityDid), [
        'did:webvh:chess',
      ]);

      await repository.clear();
      expect(await repository.memberLinks(), isEmpty);
    });
  });
}
