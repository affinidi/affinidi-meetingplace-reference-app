import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/community_offer_service/community_offer_service.dart';

import '../../../fakes/fake_community_offers.dart';

const _communityDid = 'did:webvh:community.example';
const _phrase = 'my-club';

void main() {
  late FakeOfferSdk sdk;
  late CommunityOfferService service;

  setUp(() {
    sdk = FakeOfferSdk();
    service = CommunityOfferService(sdk: () async => sdk);
  });

  Future<ConnectionOffer> publish({String phrase = _phrase}) =>
      service.publish(_communityDid, phrase: phrase, communityName: 'Club');

  group('CommunityOfferService.publish', () {
    test('publishes only the community\'s DID, until withdrawn', () async {
      final offer = await publish(phrase: ' $_phrase ');

      final request = sdk.requests.single;
      expect(request.customMnemonic, _phrase);
      expect(request.offerName, 'Club');
      expect(request.validUntil, isNull);
      expect(request.maximumUsage, isNull);
      expect(request.contactCard.type, CommunityOfferService.contactCardType);
      expect(request.contactCard.contactInfo, {
        CommunityOfferService.contactInfoKey: _communityDid,
      });
      expect(
        CommunityOfferService.communityDidOf(offer.contactCard),
        _communityDid,
      );
      expect((await service.published(_communityDid))?.mnemonic, _phrase);
    });

    test('refuses a phrase already registered', () async {
      sdk.taken.add(_phrase);

      await expectLater(
        publish(),
        throwsA(isA<CommunityPhraseTakenException>()),
      );
      expect(sdk.requests, isEmpty);
    });

    test('replaces the phrase published before', () async {
      final first = await publish();

      await publish(phrase: 'my-club-2');

      expect(sdk.offers.first.isDeleted, isTrue);
      expect(sdk.offers.first.offerLink, first.offerLink);
      expect((await service.published(_communityDid))?.mnemonic, 'my-club-2');
    });

    test(
      'keeps the phrase published before when the new one is taken',
      () async {
        await publish();
        sdk.taken.add('my-club-2');

        await expectLater(
          publish(phrase: 'my-club-2'),
          throwsA(isA<CommunityPhraseTakenException>()),
        );
        expect((await service.published(_communityDid))?.mnemonic, _phrase);
      },
    );
  });

  test('CommunityOfferService.withdraw deregisters the phrase', () async {
    await publish();

    await service.withdraw(_communityDid);

    expect(sdk.offers.single.isDeleted, isTrue);
    expect(await service.published(_communityDid), isNull);
  });

  group('CommunityOfferService.findCommunity', () {
    Matcher throwsProblem(CommunityPhraseProblem problem) => throwsA(
      isA<CommunityPhraseException>().having(
        (e) => e.problem,
        'problem',
        problem,
      ),
    );

    test('finds the community DID the phrase points to', () async {
      sdk.found[_phrase] = fakeFoundOffer(
        _phrase,
        contactInfo: {CommunityOfferService.contactInfoKey: _communityDid},
      );

      expect(await service.findCommunity(' $_phrase '), _communityDid);
    });

    test('finds no community under an unknown phrase', () async {
      await expectLater(
        service.findCommunity(_phrase),
        throwsProblem(CommunityPhraseProblem.notFound),
      );
    });

    test('finds no community under an expired phrase', () async {
      sdk.findFailure = MeetingPlaceCoreSDKErrorCode.connectionOfferExpired;

      await expectLater(
        service.findCommunity(_phrase),
        throwsProblem(CommunityPhraseProblem.expired),
      );
    });

    test('finds no community behind an ordinary offer', () async {
      sdk.found[_phrase] = fakeFoundOffer(_phrase);

      await expectLater(
        service.findCommunity(_phrase),
        throwsProblem(CommunityPhraseProblem.notFound),
      );
    });
  });
}
