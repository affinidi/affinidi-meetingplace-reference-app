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

    Message callItem(String messageId, CallStatus status) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: false,
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
    test('badges the caller-side declined call once keyed by the call item '
        'message id, ignores missed and answered calls', () async {
      await chatService.startChatSession();

      // calling -> declined (caller cancelled/declined): bumps once, and the
      // dedup key is the call item message id.
      chatService.upsertChatItem(callItem('call-1', CallStatus.calling));
      expect(badgeBumps(), isEmpty);
      chatService.upsertChatItem(callItem('call-1', CallStatus.declined));
      expect(badgeBumps(), [channelDid]);
      expect(badgeCallIds(), ['call-1']);

      // Repeated terminal upsert of the same call: still counted once.
      chatService.upsertChatItem(callItem('call-1', CallStatus.declined));
      expect(badgeCallIds(), ['call-1']);

      // A distinct declined call: counts again, keyed by its own message id.
      chatService.upsertChatItem(callItem('call-2', CallStatus.calling));
      chatService.upsertChatItem(callItem('call-2', CallStatus.declined));
      expect(badgeCallIds(), ['call-1', 'call-2']);

      // A recipient-side missed transition is not badged here (owned by
      // IncomingCallService).
      chatService.upsertChatItem(callItem('call-3', CallStatus.ringing));
      chatService.upsertChatItem(callItem('call-3', CallStatus.missed));
      expect(badgeCallIds(), ['call-1', 'call-2']);

      // An answered call that ended: does not badge.
      chatService.upsertChatItem(callItem('call-4', CallStatus.calling));
      chatService.upsertChatItem(callItem('call-4', CallStatus.inProgress));
      chatService.upsertChatItem(callItem('call-4', CallStatus.ended));
      expect(badgeCallIds(), ['call-1', 'call-2']);
    });

    test('syncs call activity as read only while the chat is open', () async {
      await chatService.startChatSession();

      chatService.upsertChatItem(callItem('call-closed', CallStatus.ringing));
      expect(fakeContactsService.syncOpenChannelReadSeqNoCalls, isEmpty);

      container
          .read(openChatRegistryProvider.notifier)
          .markOpened(testContact.id);

      chatService.upsertChatItem(callItem('call-open', CallStatus.ringing));
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
