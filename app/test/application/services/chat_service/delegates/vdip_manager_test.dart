import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/vdip_manager.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/credentials_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/vrc_repository_provider.dart';
import 'package:ssi/ssi.dart';

import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../fakes/fake_credentials_sdk.dart';
import '../../../../fakes/fake_meeting_place_matrix_sdk.dart';
import '../../../../fakes/fake_r_card_repository.dart';
import '../../../../fakes/fake_vrc_repository.dart';

final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('VdipManager', () {
    late ProviderContainer container;
    late FakeMeetingPlaceMatrixSDK fakeCoreSdk;
    late StubVdipCredentialsSdk stub;
    late FakeChatSdk fakeChatSdk;
    late VdipManager manager;
    late List<String> onVrcRequestReceivedDids;
    late List<bool> onVrcRequestReceivedShouldPrompt;
    late List<EventMessageType> persistedEvents;
    late List<ChatItem> messages;
    late Completer<void>? onVrcRequestReceivedCompleter;
    late Completer<void>? persistedEventCompleter;

    const otherPartyPermanentDid = 'did:key:other-party';
    const localPermanentDid = 'did:key:local-party';

    // Real signed VC blob + issuance for VRC-received tests.
    late String vcBlob;
    late VrcIssuance vrcIssuance;

    setUpAll(() async {
      final wallet = PersistentWallet(InMemoryKeyStore());
      final didManager = DidKeyManager(
        wallet: wallet,
        store: InMemoryDidStore(),
      );
      await wallet.generateKey().then(
        (kp) => didManager.addVerificationMethod(kp.id),
      );
      final peerDid = (await didManager.getDidDocument()).id;

      final vc = await CredentialBuilder.buildVrc(
        issuerDid: peerDid,
        subject: VrcCredentialSubject(
          from: VrcParty(did: peerDid, name: 'Peer'),
          to: const VrcParty(did: 'did:key:local', name: 'Local'),
        ),
        issuerDidManager: didManager,
      );
      vcBlob = jsonEncode(vc.toJson());
      vrcIssuance = VrcIssuance(
        senderDid: otherPartyPermanentDid,
        vcBlob: vcBlob,
        parsedCredential: UniversalParser.parse(vcBlob),
      );
    });

    setUp(() {
      messages = [];
      onVrcRequestReceivedDids = [];
      onVrcRequestReceivedShouldPrompt = [];
      persistedEvents = [];
      onVrcRequestReceivedCompleter = null;
      persistedEventCompleter = null;
      fakeChatSdk = FakeChatSdk();

      fakeCoreSdk = FakeMeetingPlaceMatrixSDK(
        channels: {
          otherPartyPermanentDid: Channel(
            permanentChannelDid: localPermanentDid,
            otherPartyPermanentChannelDid: otherPartyPermanentDid,
            offerLink: 'test-offer-link',
            publishOfferDid: 'did:key:offer',
            mediatorDid: 'did:key:mediator',
            contactCard: null,
            status: ChannelStatus.inaugurated,
            isConnectionInitiator: false,
            type: ChannelType.individual,
          ),
        },
      );

      stub = StubVdipCredentialsSdk(
        coreSDK: fakeCoreSdk,
        rCardRepository: FakeNoOpRCardRepository(),
        vrcRepository: FakeNoOpVrcRepository(),
      );

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          credentialsSdkProvider.overrideWith((ref) async => stub),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
        ],
      );

      manager = VdipManager(
        ref: container.read(_refProvider),
        otherPartyPermanentDid: otherPartyPermanentDid,
        logger: AppLogger.instance,
        getChatSdk: () => fakeChatSdk,
        getMessages: () => messages,
        persistLocalEventMessage: (type) async {
          persistedEvents.add(type);
          if (persistedEventCompleter case final completer?) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
        onVrcRequestReceived:
            (
              did,
              identityDid,
              identityName, {
              shouldPromptForAction = true,
            }) async {
              onVrcRequestReceivedDids.add(did);
              onVrcRequestReceivedShouldPrompt.add(shouldPromptForAction);
              if (onVrcRequestReceivedCompleter case final completer?) {
                if (!completer.isCompleted) {
                  completer.complete();
                }
              }
            },
      );
    });

    tearDown(() async {
      await stub.dispose();
      container.dispose();
    });

    test('subscribe — prompt outcome calls onVrcRequestReceived '
        'with shouldPromptForAction true', () async {
      stub.nextRequestResult = const VrcRequestProcessingResultPromptRequired();
      await manager.subscribe();
      onVrcRequestReceivedCompleter = Completer<void>();

      await stub.emitRequestAndWaitHandled(
        VrcRequest(senderDid: otherPartyPermanentDid),
      );
      await onVrcRequestReceivedCompleter!.future;

      expect(onVrcRequestReceivedDids, [otherPartyPermanentDid]);
      expect(onVrcRequestReceivedShouldPrompt, [true]);
    });

    test('subscribe — issued outcome calls onVrcRequestReceived '
        'with shouldPromptForAction false', () async {
      stub.nextRequestResult = const VrcRequestProcessingResultIssued(
        'stub-vc-blob',
      );
      await manager.subscribe();
      onVrcRequestReceivedCompleter = Completer<void>();

      await stub.emitRequestAndWaitHandled(
        VrcRequest(senderDid: otherPartyPermanentDid),
      );
      await onVrcRequestReceivedCompleter!.future;

      expect(onVrcRequestReceivedDids, [otherPartyPermanentDid]);
      expect(onVrcRequestReceivedShouldPrompt, [false]);
    });

    test(
      'subscribe — issued outcome creates outgoing attachment card',
      () async {
        stub.nextRequestResult = const VrcRequestProcessingResultIssued(
          'stub-sent-vc-blob',
        );
        await manager.subscribe();
        final attachmentCreated = fakeChatSdk.waitForAttachmentMessageCount(1);

        await stub.emitRequestAndWaitHandled(
          VrcRequest(senderDid: otherPartyPermanentDid),
        );
        await attachmentCreated;

        expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
        expect(
          fakeChatSdk.createAttachmentMessageCalls.first.senderDid,
          localPermanentDid,
        );
      },
    );

    test('subscribe — waiting outcome calls onVrcRequestReceived '
        'with shouldPromptForAction false', () async {
      stub.nextRequestResult = const VrcRequestProcessingResultWaiting();
      await manager.subscribe();
      onVrcRequestReceivedCompleter = Completer<void>();

      await stub.emitRequestAndWaitHandled(
        VrcRequest(senderDid: otherPartyPermanentDid),
      );
      await onVrcRequestReceivedCompleter!.future;

      expect(onVrcRequestReceivedDids, [otherPartyPermanentDid]);
      expect(onVrcRequestReceivedShouldPrompt, [false]);
    });

    test('subscribe — filters out VRC requests from other senders', () async {
      await manager.subscribe();

      stub.emitRequest(VrcRequest(senderDid: 'did:key:someone-else'));

      expect(onVrcRequestReceivedDids, isEmpty);
    });

    test(
      'subscribe — does not show card or persist event on ignored outcome',
      () async {
        stub.nextVrcResult = const VrcProcessingResultIgnored();
        await manager.subscribe();

        await stub.emitVrcAndWaitHandled(vrcIssuance);

        expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
        expect(persistedEvents, isEmpty);
      },
    );

    test('subscribe — completed outcome shows incoming card and persists'
        ' exchange event', () async {
      stub.nextVrcResult = const VrcProcessingResultCompleted();
      await manager.subscribe();
      persistedEventCompleter = Completer<void>();

      await stub.emitVrcAndWaitHandled(vrcIssuance);
      await persistedEventCompleter!.future;

      expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
      expect(
        fakeChatSdk.createAttachmentMessageCalls.first.senderDid,
        otherPartyPermanentDid,
      );
      expect(persistedEvents, hasLength(1));
    });

    test('subscribe — reciprocated outcome shows incoming then outgoing card'
        ' in order', () async {
      stub.nextVrcResult = const VrcProcessingResultReciprocated(
        'stub-sent-vc-blob',
      );
      await manager.subscribe();
      persistedEventCompleter = Completer<void>();

      await stub.emitVrcAndWaitHandled(vrcIssuance);
      await persistedEventCompleter!.future;

      expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(2));
      expect(
        fakeChatSdk.createAttachmentMessageCalls[0].senderDid,
        otherPartyPermanentDid,
        reason: 'incoming card must appear first',
      );
      expect(
        fakeChatSdk.createAttachmentMessageCalls[1].senderDid,
        localPermanentDid,
        reason: 'outgoing card must appear second',
      );
      expect(persistedEvents, hasLength(1));
    });

    test('subscribe — filters out VRCs from other senders', () async {
      await manager.subscribe();

      stub.emitVrc(
        VrcIssuance(
          senderDid: 'did:key:someone-else',
          vcBlob: vcBlob,
          parsedCredential: UniversalParser.parse(vcBlob),
        ),
      );

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('subscribe — should not start a second VRC handler before the first '
        'finishes', () async {
      final firstVrcHandlerStarted = Completer<void>();
      final allowFirstVrcHandlerToContinue = Completer<void>();
      addTearDown(() {
        if (!allowFirstVrcHandlerToContinue.isCompleted) {
          allowFirstVrcHandlerToContinue.complete();
        }
      });

      stub
        ..nextVrcResult = const VrcProcessingResultCompleted()
        ..firstVrcHandlerStarted = firstVrcHandlerStarted
        ..allowFirstVrcHandlerToContinue = allowFirstVrcHandlerToContinue;

      final managerWithPersistedMessages = VdipManager(
        ref: container.read(_refProvider),
        otherPartyPermanentDid: otherPartyPermanentDid,
        logger: AppLogger.instance,
        getChatSdk: () => fakeChatSdk,
        getMessages: () => messages,
        persistLocalEventMessage: (type) async {
          persistedEvents.add(type);
          messages = [
            ...messages,
            EventMessage(
              chatId: 'test-chat',
              messageId: 'event-${persistedEvents.length}',
              senderDid: otherPartyPermanentDid,
              isFromMe: false,
              dateCreated: DateTime.now(),
              status: ChatItemStatus.received,
              eventType: type,
              data: const {},
            ),
          ];
          if (persistedEventCompleter case final completer?) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        },
        onVrcRequestReceived:
            (
              did,
              identityDid,
              identityName, {
              shouldPromptForAction = true,
            }) async {
              onVrcRequestReceivedDids.add(did);
            },
      );

      await managerWithPersistedMessages.subscribe();

      final firstHandled = stub.emitVrcAndWaitHandled(vrcIssuance);
      await firstVrcHandlerStarted.future;

      final secondHandled = stub.emitVrcAndWaitHandled(vrcIssuance);

      expect(
        stub.handledVrcExchangeStates,
        hasLength(1),
        reason:
            'the second VRC should not start until the first one finishes '
            'persisting exchange completion state',
      );

      allowFirstVrcHandlerToContinue.complete();
      await Future.wait([firstHandled, secondHandled]);

      expect(stub.handledVrcExchangeStates, hasLength(2));
      expect(
        stub.handledVrcExchangeStates[1].hasVrcExchangeCompleted,
        isTrue,
        reason:
            'the second VRC should observe the completed exchange state '
            'written by the first handler',
      );
    });

    test('replayPending — replays pending VRC request '
        'and calls onVrcRequestReceived', () async {
      stub.pendingRequest = VrcRequest(senderDid: otherPartyPermanentDid);
      await manager.subscribe();
      await manager.replayPending();

      expect(onVrcRequestReceivedDids, [otherPartyPermanentDid]);
    });

    test(
      'replayPending — replays pending VRC and shows incoming card',
      () async {
        stub.nextVrcResult = const VrcProcessingResultCompleted();
        stub.pendingVrc = vrcIssuance;
        await manager.subscribe();
        await manager.replayPending();

        expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
      },
    );

    test('replayPending — no-op when no pending events are queued', () async {
      await manager.subscribe();
      await manager.replayPending();

      expect(onVrcRequestReceivedDids, isEmpty);
      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('cancelSubscriptions — completes without error '
        'when called before subscribe', () async {
      await expectLater(manager.cancelSubscriptions(), completes);
    });

    test('cancelSubscriptions — safe to call twice after subscribe', () async {
      await manager.subscribe();
      await manager.cancelSubscriptions();
      await expectLater(manager.cancelSubscriptions(), completes);
    });

    test('cancelSubscriptions — stops delivery after cancel', () async {
      await manager.subscribe();
      await manager.cancelSubscriptions();

      stub.emitRequest(VrcRequest(senderDid: otherPartyPermanentDid));

      expect(onVrcRequestReceivedDids, isEmpty);
    });

    test(
      'subscribe — concurrent calls should not install duplicate listeners',
      () async {
        final delayedCredentials = Completer<MeetingPlaceCredentialsSDK>();
        final overlappingContainer = ProviderContainer(
          overrides: [
            meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
            credentialsSdkProvider.overrideWith(
              (ref) => delayedCredentials.future,
            ),
            vrcRepositoryProvider.overrideWith(
              (ref) async => FakeNoOpVrcRepository(),
            ),
            rCardsRepositoryProvider.overrideWith(
              (ref) async => FakeNoOpRCardRepository(),
            ),
          ],
        );
        addTearDown(overlappingContainer.dispose);

        final overlappingManager = VdipManager(
          ref: overlappingContainer.read(_refProvider),
          otherPartyPermanentDid: otherPartyPermanentDid,
          logger: AppLogger.instance,
          getChatSdk: () => fakeChatSdk,
          getMessages: () => messages,
          persistLocalEventMessage: (type) async => persistedEvents.add(type),
          onVrcRequestReceived:
              (
                did,
                identityDid,
                identityName, {
                shouldPromptForAction = true,
              }) async {
                onVrcRequestReceivedDids.add(did);
                onVrcRequestReceivedShouldPrompt.add(shouldPromptForAction);
                if (onVrcRequestReceivedCompleter case final completer?) {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                }
              },
        );

        final firstSubscribe = overlappingManager.subscribe();
        final secondSubscribe = overlappingManager.subscribe();

        delayedCredentials.complete(stub);
        await Future.wait([firstSubscribe, secondSubscribe]);

        expect(stub.activeRequestListenerCount, 1);
        expect(stub.activeVrcListenerCount, 1);

        onVrcRequestReceivedCompleter = Completer<void>();

        await stub.emitRequestAndWaitHandled(
          VrcRequest(senderDid: otherPartyPermanentDid),
        );
        await onVrcRequestReceivedCompleter!.future;

        expect(
          onVrcRequestReceivedDids,
          [otherPartyPermanentDid],
          reason: 'a single request should not be delivered twice',
        );
      },
    );

    test(
      'subscribe — completes without error when channel is not found',
      () async {
        final emptyCoreSdk = FakeMeetingPlaceMatrixSDK(channels: {});
        final emptyContainer = ProviderContainer(
          overrides: [
            meetingPlaceSdkProvider.overrideWith((ref) async => emptyCoreSdk),
            credentialsSdkProvider.overrideWith((ref) async => stub),
            vrcRepositoryProvider.overrideWith(
              (ref) async => FakeNoOpVrcRepository(),
            ),
            rCardsRepositoryProvider.overrideWith(
              (ref) async => FakeNoOpRCardRepository(),
            ),
          ],
        );
        addTearDown(emptyContainer.dispose);

        final noChannelManager = VdipManager(
          ref: emptyContainer.read(_refProvider),
          otherPartyPermanentDid: 'did:key:unknown',
          logger: AppLogger.instance,
          getChatSdk: () => fakeChatSdk,
          getMessages: () => messages,
          persistLocalEventMessage: (type) async {},
          onVrcRequestReceived:
              (
                did,
                identityDid,
                identityName, {
                shouldPromptForAction = true,
              }) async {},
        );

        await expectLater(noChannelManager.subscribe(), completes);
      },
    );

    test(
      'replayPending — completes without error when channel is not found',
      () async {
        final emptyCoreSdk = FakeMeetingPlaceMatrixSDK(channels: {});
        final emptyContainer = ProviderContainer(
          overrides: [
            meetingPlaceSdkProvider.overrideWith((ref) async => emptyCoreSdk),
            credentialsSdkProvider.overrideWith((ref) async => stub),
            vrcRepositoryProvider.overrideWith(
              (ref) async => FakeNoOpVrcRepository(),
            ),
            rCardsRepositoryProvider.overrideWith(
              (ref) async => FakeNoOpRCardRepository(),
            ),
          ],
        );
        addTearDown(emptyContainer.dispose);

        final noChannelManager = VdipManager(
          ref: emptyContainer.read(_refProvider),
          otherPartyPermanentDid: 'did:key:unknown',
          logger: AppLogger.instance,
          getChatSdk: () => fakeChatSdk,
          getMessages: () => messages,
          persistLocalEventMessage: (type) async {},
          onVrcRequestReceived:
              (
                did,
                identityDid,
                identityName, {
                shouldPromptForAction = true,
              }) async {},
        );

        await expectLater(noChannelManager.replayPending(), completes);
      },
    );
  });
}
