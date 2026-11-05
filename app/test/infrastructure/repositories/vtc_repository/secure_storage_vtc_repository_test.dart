import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_left_membership.dart';
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
}
