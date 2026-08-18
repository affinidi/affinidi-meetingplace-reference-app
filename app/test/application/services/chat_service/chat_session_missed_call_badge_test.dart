import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/open_chat_registry.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/vrc_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../fakes/fake_app_badge_service.dart';
import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_sdk.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../fakes/fake_r_card_repository.dart';
import '../../../fakes/fake_secure_storage.dart';
import '../../../fakes/fake_vrc_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('ChatSessionService missed-call badge on call-item transition', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeContactsService fakeContactsService;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    Message callItem(
      String messageId,
      CallStatus status, {
      required bool isFromMe,
    }) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: isFromMe,
      senderDid: channelDid,
      attachments: [
        CallMetadata.buildAttachment(
          id: const Uuid().v4(),
          mediaType: CallMediaType.video,
          status: status,
          callId: '',
        ),
      ],
    );

    setUp(() {
      fakeContactsService = FakeContactsService();
      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceSDK(
              channels: {channelDid: FakeChannels.individualChannel},
            ),
          ),
          chatSdkProvider.overrideWith((ref, channel) async => FakeChatSdk()),
          contactsServiceProvider.overrideWith(() => fakeContactsService),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          secureStorageProvider.overrideWith(
            (ref) async => FakeSecureStorage(),
          ),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );
      container.listen(
        chatSessionServiceProvider(channelDid),
        (_, _) {},
        fireImmediately: true,
      );
      chatService = container.read(
        chatSessionServiceProvider(channelDid).notifier,
      );
    });

    tearDown(() => container.dispose());

    List<String> badgeBumps() =>
        fakeContactsService.incrementMissedCallBadgeCalls;
    List<String> badgeCallIds() =>
        fakeContactsService.incrementMissedCallBadgeCallIds;

    // All scenarios run in one test to keep a single session lifecycle.
    test('badges the caller-side unanswered call (missed or declined) once '
        'keyed by the call item message id, ignores recipient-side and '
        'answered calls', () async {
      await chatService.startChatSession();

      // calling -> declined (callee actively declined): bumps once, and the
      // dedup key is the call item message id.
      chatService.upsertChatItem(
        callItem('call-1', CallStatus.calling, isFromMe: true),
      );
      expect(badgeBumps(), isEmpty);
      chatService.upsertChatItem(
        callItem('call-1', CallStatus.declined, isFromMe: true),
      );
      expect(badgeBumps(), [channelDid]);
      expect(badgeCallIds(), ['call-1']);

      // Repeated terminal upsert of the same call: still counted once.
      chatService.upsertChatItem(
        callItem('call-1', CallStatus.declined, isFromMe: true),
      );
      expect(badgeCallIds(), ['call-1']);

      // A distinct declined call: counts again, keyed by its own message id.
      chatService.upsertChatItem(
        callItem('call-2', CallStatus.calling, isFromMe: true),
      );
      chatService.upsertChatItem(
        callItem('call-2', CallStatus.declined, isFromMe: true),
      );
      expect(badgeCallIds(), ['call-1', 'call-2']);

      // A caller-side missed call (outgoing call cancelled or timed out with
      // no answer): also bumps, keyed by its own message id.
      chatService.upsertChatItem(
        callItem('call-2b', CallStatus.calling, isFromMe: true),
      );
      chatService.upsertChatItem(
        callItem('call-2b', CallStatus.missed, isFromMe: true),
      );
      expect(badgeCallIds(), ['call-1', 'call-2', 'call-2b']);

      // A recipient-side missed transition is not badged here (owned by
      // IncomingCallService).
      chatService.upsertChatItem(
        callItem('call-3', CallStatus.ringing, isFromMe: false),
      );
      chatService.upsertChatItem(
        callItem('call-3', CallStatus.missed, isFromMe: false),
      );
      expect(badgeCallIds(), ['call-1', 'call-2', 'call-2b']);

      // A recipient-side declined transition is not badged here either
      // (owned by IncomingCallService, which already bumps for its own
      // incoming item): guards against double-counting one declined call.
      chatService.upsertChatItem(
        callItem('call-3b', CallStatus.ringing, isFromMe: false),
      );
      chatService.upsertChatItem(
        callItem('call-3b', CallStatus.declined, isFromMe: false),
      );
      expect(badgeCallIds(), ['call-1', 'call-2', 'call-2b']);

      // An answered call that ended: does not badge.
      chatService.upsertChatItem(
        callItem('call-4', CallStatus.calling, isFromMe: true),
      );
      chatService.upsertChatItem(
        callItem('call-4', CallStatus.inProgress, isFromMe: true),
      );
      chatService.upsertChatItem(
        callItem('call-4', CallStatus.ended, isFromMe: true),
      );
      expect(badgeCallIds(), ['call-1', 'call-2', 'call-2b']);

      container
          .read(openChatRegistryProvider.notifier)
          .markOpened(testContact.id);
      chatService.upsertChatItem(
        callItem('call-5', CallStatus.calling, isFromMe: true),
      );
      chatService.upsertChatItem(
        callItem('call-5', CallStatus.declined, isFromMe: true),
      );
      expect(badgeCallIds(), ['call-1', 'call-2', 'call-2b']);
    });

    test('syncs call activity as read only while the chat is open', () async {
      await chatService.startChatSession();

      chatService.upsertChatItem(
        callItem('call-closed', CallStatus.ringing, isFromMe: false),
      );
      expect(fakeContactsService.syncOpenChannelReadSeqNoCalls, isEmpty);

      container
          .read(openChatRegistryProvider.notifier)
          .markOpened(testContact.id);

      chatService.upsertChatItem(
        callItem('call-open', CallStatus.ringing, isFromMe: false),
      );
      expect(fakeContactsService.syncOpenChannelReadSeqNoCalls, [channelDid]);
    });
  });
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}
