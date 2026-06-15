import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/connections_service/connections_service.dart';
import 'package:mpx_flutter_reference_app/application/services/control_plane_service/control_plane_service.dart';
import 'package:mpx_flutter_reference_app/application/services/control_plane_service/control_plane_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vrc_service/vrc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../fakes/fake_secure_storage.dart';
import '../../../fakes/fake_vrc_service.dart';

ConnectionOffer _makeOffer({
  required String mnemonic,
  required ConnectionOfferStatus status,
  String externalRef = 'identity-1',
  int? score,
}) => ConnectionOffer(
  offerName: 'Offer $mnemonic',
  offerLink: 'https://mp.world/$mnemonic',
  mnemonic: mnemonic,
  publishOfferDid: 'did:peer:pub',
  mediatorDid: 'did:peer:med',
  oobInvitationMessage: '{}',
  type: ConnectionOfferType.meetingPlaceInvitation,
  status: status,
  contactCard: FakeIdentities.primaryIdentity.card.toSdkContactCard(),
  ownedByMe: status == ConnectionOfferStatus.published,
  createdAt: DateTime(2024, 1, 1),
  externalRef: externalRef,
  score: score,
  transport: ChannelTransport.didcomm,
);

final _testIdentity = FakeIdentities.primaryIdentity.copyWith(
  id: 'identity-1',
  did: 'did:key:identity-1',
);

class _FakeControlPlaneService extends ControlPlaneService {
  @override
  ControlPlaneServiceState build() => const ControlPlaneServiceState();
}

ProviderContainer _makeContainer({
  required FakeMeetingPlaceSDK fakeSdk,
  int vrcCount = 0,
}) {
  return ProviderContainer(
    overrides: [
      meetingPlaceSdkProvider.overrideWith((ref) async => fakeSdk),
      controlPlaneServiceProvider.overrideWith(_FakeControlPlaneService.new),
      vrcServiceProvider.overrideWith(() => FakeVrcService(vrcCount: vrcCount)),
      secureStorageProvider.overrideWith((ref) async => FakeSecureStorage()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('ConnectionsService.updatePublishedOffersScore', () {
    late FakeMeetingPlaceSDK fakeSdk;
    late ProviderContainer container;
    late ConnectionsService service;

    setUp(() {
      fakeSdk = FakeMeetingPlaceSDK();
    });

    tearDown(() => container.dispose());

    Future<void> setup({int vrcCount = 0}) async {
      container = _makeContainer(fakeSdk: fakeSdk, vrcCount: vrcCount);
      container.listen(
        connectionsServiceProvider,
        (_, _) {},
        fireImmediately: true,
      );
      service = container.read(connectionsServiceProvider.notifier);
      await service.fetchConnections();
    }

    test('does nothing when identity has no offers', () async {
      await setup(vrcCount: 1);

      await service.updatePublishedOffersScore(_testIdentity);

      expect(fakeSdk.updateScoreForOffersCalls, isEmpty);
      expect(fakeSdk.updateLocalConnectionOffersScoreCalls, isEmpty);
    });

    test('calls updateScoreForOffers for published offers', () async {
      fakeSdk.setConnectionOffersForExternalRef('identity-1', [
        _makeOffer(mnemonic: 'pub-1', status: ConnectionOfferStatus.published),
        _makeOffer(mnemonic: 'pub-2', status: ConnectionOfferStatus.published),
      ]);
      await setup(vrcCount: 3);

      await service.updatePublishedOffersScore(_testIdentity);

      expect(fakeSdk.updateScoreForOffersCalls, hasLength(1));
      final call = fakeSdk.updateScoreForOffersCalls.first;
      expect(call['score'], 3);
      final offers = call['offers'] as List<ConnectionOffer>;
      expect(offers.map((o) => o.mnemonic), containsAll(['pub-1', 'pub-2']));
    });

    test(
      'does not call updateScoreForOffers when there are no published offers',
      () async {
        fakeSdk.setAllConnectionOffers([
          _makeOffer(
            mnemonic: 'acc-1',
            status: ConnectionOfferStatus.finalised,
          ),
        ]);
        await setup(vrcCount: 2);

        await service.updatePublishedOffersScore(_testIdentity);

        expect(fakeSdk.updateScoreForOffersCalls, isEmpty);
      },
    );

    test(
      'calls updateLocalConnectionOffersScore for accepted offers',
      () async {
        fakeSdk.setAllConnectionOffers([
          _makeOffer(
            mnemonic: 'acc-1',
            status: ConnectionOfferStatus.finalised,
          ),
          _makeOffer(
            mnemonic: 'acc-2',
            status: ConnectionOfferStatus.finalised,
          ),
        ]);
        await setup(vrcCount: 2);

        await service.updatePublishedOffersScore(_testIdentity);

        expect(fakeSdk.updateLocalConnectionOffersScoreCalls, hasLength(1));
        final call = fakeSdk.updateLocalConnectionOffersScoreCalls.first;
        expect(call['score'], 2);
        final offers = call['offers'] as List<ConnectionOffer>;
        expect(offers.map((o) => o.mnemonic), containsAll(['acc-1', 'acc-2']));
      },
    );

    test('does not call updateLocalConnectionOffersScore when there are no'
        ' accepted offers', () async {
      fakeSdk.setConnectionOffersForExternalRef('identity-1', [
        _makeOffer(mnemonic: 'pub-1', status: ConnectionOfferStatus.published),
      ]);
      await setup(vrcCount: 1);

      await service.updatePublishedOffersScore(_testIdentity);

      expect(fakeSdk.updateLocalConnectionOffersScoreCalls, isEmpty);
    });

    test('handles both published and accepted offers in one call', () async {
      fakeSdk.setConnectionOffersForExternalRef('identity-1', [
        _makeOffer(mnemonic: 'pub-1', status: ConnectionOfferStatus.published),
      ]);
      fakeSdk.setAllConnectionOffers([
        _makeOffer(mnemonic: 'acc-1', status: ConnectionOfferStatus.finalised),
      ]);
      await setup(vrcCount: 5);

      await service.updatePublishedOffersScore(_testIdentity);

      expect(fakeSdk.updateScoreForOffersCalls, hasLength(1));
      expect(fakeSdk.updateScoreForOffersCalls.first['score'], 5);
      expect(fakeSdk.updateLocalConnectionOffersScoreCalls, hasLength(1));
      expect(fakeSdk.updateLocalConnectionOffersScoreCalls.first['score'], 5);
    });

    test('uses the VRC count as score for both update paths', () async {
      fakeSdk.setConnectionOffersForExternalRef('identity-1', [
        _makeOffer(mnemonic: 'pub-1', status: ConnectionOfferStatus.published),
      ]);
      fakeSdk.setAllConnectionOffers([
        _makeOffer(mnemonic: 'acc-1', status: ConnectionOfferStatus.finalised),
      ]);
      const expectedScore = 7;
      await setup(vrcCount: expectedScore);

      await service.updatePublishedOffersScore(_testIdentity);

      expect(fakeSdk.updateScoreForOffersCalls.first['score'], expectedScore);
      expect(
        fakeSdk.updateLocalConnectionOffersScoreCalls.first['score'],
        expectedScore,
      );
    });

    test('refreshes connections after updating scores', () async {
      fakeSdk.setConnectionOffersForExternalRef('identity-1', [
        _makeOffer(mnemonic: 'pub-1', status: ConnectionOfferStatus.published),
      ]);
      await setup(vrcCount: 1);

      await service.updatePublishedOffersScore(_testIdentity);

      expect(container.read(connectionsServiceProvider).connections, isEmpty);
    });

    test('does not throw when SDK error occurs', () async {
      fakeSdk.setConnectionOffersForExternalRef('identity-1', [
        _makeOffer(mnemonic: 'pub-1', status: ConnectionOfferStatus.published),
      ]);
      await setup(vrcCount: 1);

      await expectLater(
        service.updatePublishedOffersScore(_testIdentity),
        completes,
      );
    });
  });
}
