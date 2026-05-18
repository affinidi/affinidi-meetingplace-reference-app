import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_card_chat_notifier_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/relationship_sdk_provider.dart';

import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_repository.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_r_card_repository.dart';
import '../../../fakes/fake_relationship_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('RCardChatNotifierService — group channel guard', () {
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

        fakeRelationshipSdk.emitOnChannel(
          ChannelRCardEvent(channel: FakeChannels.groupChannel, rCard: rCard),
        );
        await Future<void>.delayed(Duration.zero);

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

        fakeRelationshipSdk.emitOnChannel(
          ChannelRCardEvent(
            channel: FakeChannels.individualChannel,
            rCard: rCard,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(fakeChatRepo.createdMessages, hasLength(1));
      },
    );
  });
}
