import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_left_membership.dart';
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
}
