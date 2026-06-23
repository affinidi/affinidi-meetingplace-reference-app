import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_card_chat_notifier_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/credentials_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';

import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_repository.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_credentials_sdk.dart';
import '../../../fakes/fake_r_card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('RCardChatNotifierService — group channel guard', () {
    late FakeCredentialsSdk fakeCredentialsSdk;
    late FakeInMemoryChatRepository fakeChatRepo;
    late ProviderContainer container;

    setUp(() async {
      fakeCredentialsSdk = FakeCredentialsSdk();
      fakeChatRepo = FakeInMemoryChatRepository();

      container = ProviderContainer(
        overrides: [
          credentialsSdkProvider.overrideWith(
            (ref) async => fakeCredentialsSdk,
          ),
          chatRepositoryProvider.overrideWith((ref) async => fakeChatRepo),
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
        ],
      );

      container.read(rCardChatNotifierServiceProvider);
      await fakeCredentialsSdk.waitForChannelRCardListener();
    });

    tearDown(() async {
      container.dispose();
      await fakeCredentialsSdk.close();
    });

    test(
      'does NOT create a chat message when R-Card arrives on a group channel',
      () async {
        final rCard = RCard(
          subjectDid: 'did:key:subject',
          vcBlob: '{}',
          issuerDid: 'did:key:issuer',
          version: 1,
          issuanceDate: DateTime(2024),
          receivedAt: DateTime(2024),
        );

        await fakeCredentialsSdk.emitOnChannelAndWait(
          ChannelRCardEvent(channel: FakeChannels.groupChannel, rCard: rCard),
        );

        expect(fakeChatRepo.createdMessages, isEmpty);
      },
    );

    test(
      'DOES create a chat message when R-Card arrives on an individual channel',
      () async {
        final rCard = RCard(
          subjectDid: 'did:key:subject',
          vcBlob: '{}',
          issuerDid: 'did:key:issuer',
          version: 1,
          issuanceDate: DateTime(2024),
          receivedAt: DateTime(2024),
        );

        await fakeCredentialsSdk.emitOnChannelAndWait(
          ChannelRCardEvent(
            channel: FakeChannels.individualChannel,
            rCard: rCard,
          ),
        );

        expect(fakeChatRepo.createdMessages, hasLength(1));
      },
    );
  });
}
