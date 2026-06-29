import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/voice_playback_service/voice_playback_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/local_voice_attachment_store.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/vrc_attachments_plugin/vrc_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/available_attachment_plugins_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/cache_manager_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/vrc_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_controller.dart';

import '../../../fakes/fake_app_badge_service.dart';
import '../../../fakes/fake_cache_manager.dart';
import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_sdk.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../fakes/fake_r_card_repository.dart';
import '../../../fakes/fake_secure_storage.dart';
import '../../../fakes/fake_vrc_repository.dart';
import '../../../utils/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/chat_voice_playback_test.log'),
  );

  test('stops voice playback when chat session ends', () async {
    final contactId = FakeContacts.individualContact.id;
    final channelDid = FakeContacts.individualContact.channelDid!;
    final voicePlayback = _VoicePlaybackRecorder();
    final cacheManager = FakeCacheManager();

    final container = ProviderContainer(
      overrides: [
        meetingPlaceSdkProvider.overrideWith(
          (ref) async => FakeMeetingPlaceSDK(
            channels: {channelDid: FakeChannels.individualChannel},
          ),
        ),
        chatSdkProvider.overrideWith((ref, channel) async => FakeChatSdk()),
        contactsServiceProvider.overrideWith(FakeContactsService.new),
        environmentProvider.overrideWithValue(FakeEnvironment()),
        appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
        rCardsRepositoryProvider.overrideWith(
          (ref) async => FakeNoOpRCardRepository(),
        ),
        vrcRepositoryProvider.overrideWith(
          (ref) async => FakeNoOpVrcRepository(),
        ),
        secureStorageProvider.overrideWith((ref) async => FakeSecureStorage()),
        networkConnectivityServiceProvider.overrideWith(
          _FakeNetworkConnectivityService.new,
        ),
        cacheManagerProvider.overrideWith((ref) => cacheManager),
        localVoiceAttachmentStoreProvider.overrideWith(
          (ref) => LocalVoiceAttachmentStore(),
        ),
        availableAttachmentPluginsProvider.overrideWith(
          (ref) => [
            AudioAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
              localVoiceStore: ref.read(localVoiceAttachmentStoreProvider),
            ),
            RCardAttachmentsPlugin(
              cacheManager: ref.read(cacheManagerProvider),
            ),
            VrcAttachmentsPlugin(),
          ],
        ),
        voicePlaybackServiceProvider(
          contactId,
        ).overrideWith(() => _RecordingVoicePlaybackService(voicePlayback)),
      ],
    );

    final subscription = container.listen(
      chatScreenControllerProvider(contactId),
      (_, _) {},
      fireImmediately: true,
    );
    container.read(chatScreenControllerProvider(contactId));
    await container.pump();

    expect(voicePlayback.disposeCalls, 0);

    subscription.close();
    container.dispose();

    expect(voicePlayback.stopCalls, 1);
  });

  testWidgets('stops voice playback when chat widget exits', (tester) async {
    final contactId = FakeContacts.individualContact.id;
    final voicePlayback = _VoicePlaybackRecorder();

    await navigateToChat(
      tester,
      contactId: contactId,
      chatSdk: FakeChatSdk(),
      providerOverrides: [
        voicePlaybackServiceProvider(
          contactId,
        ).overrideWith(() => _RecordingVoicePlaybackService(voicePlayback)),
      ],
    );

    expect(voicePlayback.stopCalls, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(voicePlayback.stopCalls, greaterThanOrEqualTo(1));
  });
}

class _VoicePlaybackRecorder {
  int stopCalls = 0;
  int disposeCalls = 0;
}

class _RecordingVoicePlaybackService extends VoicePlaybackService {
  _RecordingVoicePlaybackService(this._recorder);

  final _VoicePlaybackRecorder _recorder;

  @override
  VoicePlaybackState build(String contactId) {
    ref.onDispose(() {
      _recorder.disposeCalls += 1;
    });
    return const VoicePlaybackState();
  }

  @override
  Future<void> disposePlaybackResources() async {
    _recorder.stopCalls += 1;
  }
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() =>
      const NetworkConnectivityServiceState(isConnected: true);
}
