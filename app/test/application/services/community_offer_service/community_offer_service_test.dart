import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/community_offer_service/community_offer_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';

import '../../../fakes/fake_community_offers.dart';

const _communityDid = 'did:webvh:community.example';
const _phrase = 'my-club';

void main() {
  late FakeOfferSdk sdk;
  late FakeAdminVtcService vtc;
  late CommunityOfferService service;

  setUp(() {
    sdk = FakeOfferSdk();
    vtc = FakeAdminVtcService();
    service = CommunityOfferService(sdk: () async => sdk, vtc: vtc);
  });

  Future<ConnectionOffer> publish({String phrase = _phrase}) =>
      service.publish(_communityDid, phrase: phrase, communityName: 'Club');

  group('CommunityOfferService.publish', () {
    test(
      'publishes only the statement, for the role card\'s lifetime',
      () async {
        final offer = await publish(phrase: ' $_phrase ');

        final request = sdk.requests.single;
        expect(request.customMnemonic, _phrase);
        expect(request.offerName, 'Club');
        expect(request.validUntil, DateTime.utc(2026, 12, 1, 10));
        expect(request.contactCard.type, CommunityOfferService.contactCardType);
        expect(request.contactCard.contactInfo.keys, [
          CommunityOffer.contactInfoKey,
        ]);
        expect(
          CommunityOfferService.statementOf(offer.contactCard)?['phrase'],
          _phrase,
        );
        expect((await service.published(_communityDid))?.mnemonic, _phrase);
      },
    );

    test('refuses a phrase already registered', () async {
      sdk.taken.add(_phrase);

      await expectLater(
        publish(),
        throwsA(isA<CommunityPhraseTakenException>()),
      );
      expect(vtc.vouched, isEmpty);
      expect(sdk.requests, isEmpty);
    });

    test('refuses a member who is no admin', () async {
      vtc.roleCard = null;

      await expectLater(publish(), throwsA(isA<NotCommunityAdminException>()));
      expect(sdk.requests, isEmpty);
    });

    test('replaces the phrase published before', () async {
      final first = await publish();

      await publish(phrase: 'my-club-2');

      expect(sdk.offers.first.isDeleted, isTrue);
      expect(sdk.offers.first.offerLink, first.offerLink);
      expect((await service.published(_communityDid))?.mnemonic, 'my-club-2');
    });

    test('keeps the phrase published before when signing fails', () async {
      await publish();
      vtc.roleCard = null;

      await expectLater(
        publish(phrase: 'my-club-2'),
        throwsA(isA<NotCommunityAdminException>()),
      );
      expect((await service.published(_communityDid))?.mnemonic, _phrase);
    });
  });

  test('CommunityOfferService.withdraw deregisters the phrase', () async {
    await publish();

    await service.withdraw(_communityDid);

    expect(sdk.offers.single.isDeleted, isTrue);
    expect(await service.published(_communityDid), isNull);
  });

  group('CommunityOfferService.refresh', () {
    test('publishes the phrase again with a renewed role card', () async {
      await publish();
      vtc.roleCard = fakeRoleCard('2026-12-31T10:00:00Z');

      await service.refresh();

      final current = await service.published(_communityDid);
      expect(current?.mnemonic, _phrase);
      expect(current?.expiresAt, DateTime.utc(2026, 12, 31, 10));
      expect(sdk.offers.where((offer) => offer.isDeleted), hasLength(1));
    });

    test('leaves a phrase whose role card was not renewed', () async {
      await publish();

      await service.refresh();

      expect(sdk.requests, hasLength(1));
    });

    test('leaves a phrase when the member is no admin any more', () async {
      await publish();
      vtc.roleCard = null;

      await service.refresh();

      expect(sdk.requests, hasLength(1));
      expect((await service.published(_communityDid))?.mnemonic, _phrase);
    });
  });
}
