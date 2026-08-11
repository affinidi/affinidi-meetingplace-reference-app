import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/open_chat_registry.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/vrc_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';

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

  group('ChatSessionService read-seqNo gate for incoming messages', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeChatSdk fakeChatSdk;
    late FakeContactsService fakeContactsService;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      fakeContactsService = FakeContactsService();
      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceSDK(
              channels: {channelDid: FakeChannels.individualChannel},
            ),
          ),
          chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
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

    test(
      'does not advance the read sequence number while the chat is closed',
      () async {
        await chatService.startChatSession();

        fakeChatSdk.simulateIncomingChatMessageEvent(
          text: 'hello while closed',
          senderDid: channelDid,
        );
        await pumpEventQueue();

        expect(fakeContactsService.updateContactCalls, isEmpty);
      },
    );

    test('advances the read sequence number while the chat is open', () async {
      await chatService.startChatSession();
      container
          .read(openChatRegistryProvider.notifier)
          .markOpened(testContact.id);

      fakeChatSdk.simulateIncomingChatMessageEvent(
        text: 'hello while open',
        senderDid: channelDid,
      );
      await pumpEventQueue();

      expect(fakeContactsService.updateContactCalls, hasLength(1));
      final call = fakeContactsService.updateContactCalls.single;
      expect((call['contact'] as Contact).channelDid, channelDid);
      expect(call['sequenceNumber'], FakeChannels.individualChannel.seqNo);
    });
  });
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}
