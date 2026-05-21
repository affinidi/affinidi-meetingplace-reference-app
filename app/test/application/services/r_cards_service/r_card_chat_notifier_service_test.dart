import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show Channel, ChannelStatus, ChannelType;
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_card_chat_notifier_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/relationship_sdk_provider.dart';

import '../../../fakes/fake_chat_repository.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_r_card_repository.dart';
import '../../../fakes/fake_relationship_sdk.dart';

Channel _makeChannel({
  required String permanentChannelDid,
  required String otherPartyPermanentChannelDid,
}) {
  return Channel(
    offerLink: '',
    publishOfferDid: '',
    mediatorDid: '',
    status: ChannelStatus.inaugurated,
    contactCard: null,
    type: ChannelType.individual,
    isConnectionInitiator: false,
    permanentChannelDid: permanentChannelDid,
    otherPartyPermanentChannelDid: otherPartyPermanentChannelDid,
  );
}

RCard _makeRCard() => RCard(
  subjectDid: 'did:key:subject',
  vcBlob: '{}',
  issuerDid: 'did:key:issuer',
  version: 1,
  issuanceDate: DateTime(2024),
  receivedAt: DateTime(2024),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  late FakeRelationshipSdk fakeRelationshipSdk;
  late FakeInMemoryChatRepository fakeChatRepo;
  late ProviderContainer container;

  setUp(() async {
    fakeRelationshipSdk = FakeRelationshipSdk();
    fakeChatRepo = FakeInMemoryChatRepository();

    container = ProviderContainer(
      overrides: [
        relationshipSdkProvider.overrideWith(
          (ref) async => fakeRelationshipSdk,
        ),
        chatRepositoryProvider.overrideWith((ref) async => fakeChatRepo),
        rCardsRepositoryProvider.overrideWith(
          (ref) async => FakeNoOpRCardRepository(),
        ),
        contactsServiceProvider.overrideWith(FakeContactsService.new),
      ],
    );

    container.read(rCardChatNotifierServiceProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    container.dispose();
    await fakeRelationshipSdk.close();
  });

  group('RCardChatNotifierService — group channel guard', () {
    test(
      'does NOT create a chat message when R-Card arrives on a GROUP channel',
      () async {
        final channel = _makeChannel(
          permanentChannelDid: 'did:key:local',
          // otherPartyPermanentChannelDid matches groupContact.channelDid
          otherPartyPermanentChannelDid: FakeContacts.groupContact.channelDid!,
        );

        fakeRelationshipSdk.emitOnChannel(channel, _makeRCard());
        await Future<void>.delayed(Duration.zero);

        expect(fakeChatRepo.createdMessages, isEmpty);
      },
    );
  });

  group('RCardChatNotifierService — individual channel', () {
    test(
      'DOES create a chat message when R-Card arrives on an individual channel',
      () async {
        final channel = _makeChannel(
          permanentChannelDid: 'did:key:local',
          // otherPartyPermanentChannelDid matches individualContact.channelDid
          otherPartyPermanentChannelDid:
              FakeContacts.individualContact.channelDid!,
        );

        fakeRelationshipSdk.emitOnChannel(channel, _makeRCard());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(fakeChatRepo.createdMessages, hasLength(1));
      },
    );
  });
}
