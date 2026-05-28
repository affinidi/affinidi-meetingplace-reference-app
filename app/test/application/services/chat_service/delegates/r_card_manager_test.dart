import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/r_card_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/credentials_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';

import '../../../../fakes/fake_chat_repository.dart';
import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../fakes/fake_credentials_sdk.dart';
import '../../../../fakes/fake_identities.dart';
import '../../../../fakes/fake_meeting_place_sdk.dart';
import '../../../../fakes/fake_r_card_repository.dart';
import '../../../../fakes/fake_vrc_repository.dart';

final _refProvider = Provider<Ref>((ref) => ref);

class _FakeIdentitiesService extends IdentitiesService {
  _FakeIdentitiesService(this._seed);
  final IdentitiesServiceState _seed;

  @override
  IdentitiesServiceState build() => _seed;
}

final _fakeVcBlob = jsonEncode({
  'id': 'urn:stub-rcard',
  'type': ['VerifiableCredential'],
});

RCard _makeRCard({required String issuerDid}) => RCard(
  subjectDid: 'did:key:subject',
  vcBlob: _fakeVcBlob,
  issuerDid: issuerDid,
  version: RCardConstants.receivedRCardVersion,
  issuanceDate: DateTime.now(),
  receivedAt: DateTime.now(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('RCardManager', () {
    const otherPartyDid = 'did:key:other-party';
    const localChannelDid = 'did:key:local-channel';
    const externalRefId = 'primary-identity-id';

    late ProviderContainer container;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late StubRCardCredentialsSdk stub;
    late FakeChatSdk fakeChatSdk;
    late FakeInMemoryChatRepository fakeRepo;
    late RCardManager manager;
    late List<ChatItem> upsertedItems;

    setUp(() {
      upsertedItems = [];
      fakeChatSdk = FakeChatSdk();
      fakeRepo = FakeInMemoryChatRepository();

      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {
          otherPartyDid: Channel(
            permanentChannelDid: localChannelDid,
            otherPartyPermanentChannelDid: otherPartyDid,
            offerLink: 'offer',
            publishOfferDid: 'did:key:offer',
            mediatorDid: 'did:key:mediator',
            contactCard: null,
            status: ChannelStatus.inaugurated,
            isConnectionInitiator: false,
            type: ChannelType.individual,
            externalRef: externalRefId,
          ),
        },
      );

      stub = StubRCardCredentialsSdk(
        coreSDK: fakeCoreSdk,
        rCardRepository: FakeNoOpRCardRepository(),
        vrcRepository: FakeNoOpVrcRepository(),
      );

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          credentialsSdkProvider.overrideWith((ref) async => stub),
          chatRepositoryProvider.overrideWith((ref) async => fakeRepo),
          identitiesServiceProvider.overrideWith(
            () => _FakeIdentitiesService(
              IdentitiesServiceState(
                identities: [FakeIdentities.primaryIdentity],
              ),
            ),
          ),
        ],
      );

      manager = RCardManager(
        ref: container.read(_refProvider),
        otherPartyPermanentDid: otherPartyDid,
        logger: AppLogger.instance,
        getChatSdk: () => fakeChatSdk,
        upsertChatItem: upsertedItems.add,
      );
    });

    tearDown(() async {
      await stub.dispose();
      container.dispose();
    });

    test('cancelSubscription — safe to call before subscribe', () {
      expect(() => manager.cancelSubscription(), returnsNormally);
    });

    test('cancelSubscription — safe to call twice after subscribe', () async {
      await manager.subscribeToIncomingRCards();
      manager.cancelSubscription();
      expect(() => manager.cancelSubscription(), returnsNormally);
    });

    test('cancelSubscription — stops incoming R-Card delivery', () async {
      await manager.subscribeToIncomingRCards();
      manager.cancelSubscription();

      stub.emitRCard(_makeRCard(issuerDid: otherPartyDid));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('subscribeToIncomingRCards — incoming RCard from expected sender '
        'calls createAttachmentMessage', () async {
      await manager.subscribeToIncomingRCards();
      stub.emitRCard(_makeRCard(issuerDid: otherPartyDid));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
    });

    test('subscribeToIncomingRCards — filters RCards whose issuerDid '
        'does not match the channel', () async {
      await manager.subscribeToIncomingRCards();

      stub.emitRCard(_makeRCard(issuerDid: 'did:key:someone-else'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('subscribeToIncomingRCards — no-op when chatSdk is null', () async {
      final noSdkManager = RCardManager(
        ref: container.read(_refProvider),
        otherPartyPermanentDid: otherPartyDid,
        logger: AppLogger.instance,
        getChatSdk: () => null,
        upsertChatItem: (_) {},
      );

      await noSdkManager.subscribeToIncomingRCards();
      stub.emitRCard(_makeRCard(issuerDid: otherPartyDid));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('subscribeToIncomingRCards — completes without error '
        'when channel not found', () async {
      final emptyContainer = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceSDK(channels: {}),
          ),
          credentialsSdkProvider.overrideWith((ref) async => stub),
          chatRepositoryProvider.overrideWith((ref) async => fakeRepo),
          identitiesServiceProvider.overrideWith(
            () => _FakeIdentitiesService(IdentitiesServiceState()),
          ),
        ],
      );
      addTearDown(emptyContainer.dispose);

      final noChannelManager = RCardManager(
        ref: emptyContainer.read(_refProvider),
        otherPartyPermanentDid: 'did:key:unknown',
        logger: AppLogger.instance,
        getChatSdk: () => fakeChatSdk,
        upsertChatItem: (_) {},
      );

      await noChannelManager.subscribeToIncomingRCards();
      stub.emitRCard(_makeRCard(issuerDid: otherPartyDid));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('sendRCardFromPlugin — calls createAttachmentMessage '
        'on success', () async {
      await manager.sendRCardFromPlugin(FakeIdentities.primaryIdentity);

      expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
    });

    test('sendRCardFromPlugin — no-op when channel is not found', () async {
      final emptyContainer = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceSDK(channels: {}),
          ),
          credentialsSdkProvider.overrideWith((ref) async => stub),
          chatRepositoryProvider.overrideWith((ref) async => fakeRepo),
          identitiesServiceProvider.overrideWith(
            () => _FakeIdentitiesService(IdentitiesServiceState()),
          ),
        ],
      );
      addTearDown(emptyContainer.dispose);

      final noChannelManager = RCardManager(
        ref: emptyContainer.read(_refProvider),
        otherPartyPermanentDid: 'did:key:unknown',
        logger: AppLogger.instance,
        getChatSdk: () => fakeChatSdk,
        upsertChatItem: upsertedItems.add,
      );

      await noChannelManager.sendRCardFromPlugin(
        FakeIdentities.primaryIdentity,
      );

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test(
      'sendProfileUpdateWithRCard — updates repository, calls upsertChatItem, '
      'calls createAttachmentMessage',
      () async {
        final concierge = ConciergeMessage(
          chatId: 'chat-1',
          messageId: 'msg-1',
          senderDid: otherPartyDid,
          isFromMe: false,
          dateCreated: DateTime.now(),
          status: ChatItemStatus.userInput,
          conciergeType: ConciergeMessageType.fromJson('shareContactDetails'),
          data: const {},
        );

        await manager.sendProfileUpdateWithRCard(concierge);

        expect(upsertedItems, hasLength(1));
        expect(
          (upsertedItems.first as ConciergeMessage).status,
          ChatItemStatus.confirmed,
        );
        expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
      },
    );

    test(
      'sendProfileUpdateWithRCard — no-op when channel is not found',
      () async {
        final emptyContainer = ProviderContainer(
          overrides: [
            meetingPlaceSdkProvider.overrideWith(
              (ref) async => FakeMeetingPlaceSDK(channels: {}),
            ),
            credentialsSdkProvider.overrideWith((ref) async => stub),
            chatRepositoryProvider.overrideWith((ref) async => fakeRepo),
            identitiesServiceProvider.overrideWith(
              () => _FakeIdentitiesService(IdentitiesServiceState()),
            ),
          ],
        );
        addTearDown(emptyContainer.dispose);

        final noChannelManager = RCardManager(
          ref: emptyContainer.read(_refProvider),
          otherPartyPermanentDid: 'did:key:unknown',
          logger: AppLogger.instance,
          getChatSdk: () => fakeChatSdk,
          upsertChatItem: upsertedItems.add,
        );

        await noChannelManager.sendProfileUpdateWithRCard(
          ConciergeMessage(
            chatId: 'chat-1',
            messageId: 'msg-1',
            senderDid: 'did:key:sender',
            isFromMe: false,
            dateCreated: DateTime.now(),
            status: ChatItemStatus.userInput,
            conciergeType: ConciergeMessageType.fromJson('shareContactDetails'),
            data: const {},
          ),
        );

        expect(upsertedItems, isEmpty);
        expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
      },
    );

    test(
      'sendProfileUpdateWithRCard — no-op when identity is not found',
      () async {
        final noIdentityContainer = ProviderContainer(
          overrides: [
            meetingPlaceSdkProvider.overrideWith(
              (ref) async => FakeMeetingPlaceSDK(
                channels: {
                  otherPartyDid: Channel(
                    permanentChannelDid: localChannelDid,
                    otherPartyPermanentChannelDid: otherPartyDid,
                    offerLink: 'offer',
                    publishOfferDid: 'did:key:offer',
                    mediatorDid: 'did:key:mediator',
                    contactCard: null,
                    status: ChannelStatus.inaugurated,
                    isConnectionInitiator: false,
                    type: ChannelType.individual,
                    externalRef: 'no-such-id',
                  ),
                },
              ),
            ),
            credentialsSdkProvider.overrideWith((ref) async => stub),
            chatRepositoryProvider.overrideWith((ref) async => fakeRepo),
            identitiesServiceProvider.overrideWith(
              () => _FakeIdentitiesService(IdentitiesServiceState()),
            ),
          ],
        );
        addTearDown(noIdentityContainer.dispose);

        final noIdentityManager = RCardManager(
          ref: noIdentityContainer.read(_refProvider),
          otherPartyPermanentDid: otherPartyDid,
          logger: AppLogger.instance,
          getChatSdk: () => fakeChatSdk,
          upsertChatItem: upsertedItems.add,
        );

        await noIdentityManager.sendProfileUpdateWithRCard(
          ConciergeMessage(
            chatId: 'chat-1',
            messageId: 'msg-1',
            senderDid: otherPartyDid,
            isFromMe: false,
            dateCreated: DateTime.now(),
            status: ChatItemStatus.userInput,
            conciergeType: ConciergeMessageType.fromJson('shareContactDetails'),
            data: const {},
          ),
        );

        expect(upsertedItems, isEmpty);
        expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
      },
    );
  });
}
