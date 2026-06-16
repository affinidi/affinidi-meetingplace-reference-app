import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/identity_picker/identity_picker.dart';

import 'fakes/fake_cache_manager.dart';
import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_r_card_attachments_plugin.dart';
import 'fakes/fake_r_cards_service.dart';
import 'utils/app.dart';

void _mockSharePlus() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/share'),
        (MethodCall methodCall) async => {'status': 'success', 'raw': ''},
      );
}

InkWell _findOptionTapTarget(WidgetTester tester, Finder optionLabel) {
  return tester.widget<InkWell>(
    find.ancestor(of: optionLabel, matching: find.byType(InkWell)).first,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final contactId = FakeContacts.individualContact.id;
  final chatSdk = FakeChatSdk();
  final attachmentPlugins = [
    RCardAttachmentsPlugin(cacheManager: FakeCacheManager()),
  ];

  setUpAll(_mockSharePlus);

  group('R-Card attachment bottom sheet', () {
    testWidgets('shows R-Card option with correct label in bottom sheet', (
      tester,
    ) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.genRCard), findsOneWidget);
      expect(find.byIcon(Icons.attachment), findsWidgets);
    });

    testWidgets('R-Card option is enabled (onTap is non-null) '
        'when isPlatformSupported = true', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      final rCardOption = _findOptionTapTarget(
        tester,
        find.text(l10n.genRCard),
      );
      expect(rCardOption.onTap, isNotNull);
    });

    testWidgets('R-Card option is disabled when isPlatformSupported = false', (
      tester,
    ) async {
      final disabledPlugin = FakeUnsupportedRCardPlugin();

      await navigateToChat(
        tester,
        contactId: contactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        attachmentPlugins: [disabledPlugin],
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final disabledLabel = find.textContaining('R-Card (disabled)');
      expect(disabledLabel, findsOneWidget);
      final rCardOption = _findOptionTapTarget(tester, disabledLabel);
      expect(rCardOption.onTap, isNull);
    });

    testWidgets(
      'R-Card option is absent when RCardPlugin is not in the plugins list',
      (tester) async {
        await navigateToChat(
          tester,
          contactId: contactId,
          identities: [FakeIdentities.primaryIdentity],
          contacts: [FakeContacts.individualContact],
          chatSdk: chatSdk,
          attachmentPlugins: const [],
          rCardsServiceFactory: () => FakeRCardsService(const []),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('chat_add_media_button')));
        await tester.pumpAndSettle();

        final l10n = await getL10n();
        expect(find.text(l10n.genRCard), findsNothing);
      },
    );

    testWidgets('tapping R-Card option opens SelectIdentityScreen', (
      tester,
    ) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      await tester.tap(find.text(l10n.genRCard));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectIdentityTitle), findsOneWidget);
      expect(find.text(l10n.sendRCard), findsOneWidget);
      expect(find.text(l10n.generalCancel), findsOneWidget);
    });

    testWidgets('tapping Cancel on SelectIdentityScreen dismisses it', (
      tester,
    ) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      await tester.tap(find.text(l10n.genRCard));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectIdentityTitle), findsOneWidget);

      await tester.tap(find.text(l10n.generalCancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectIdentityTitle), findsNothing);
    });
  });

  group('_SelectRCardIdentityScreen widget details', () {
    Future<void> openSelectIdentityScreen(
      WidgetTester tester, {
      List<Identity> identities = const [],
    }) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        identities: identities,
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();
      final l10n = await getL10n();
      await tester.tap(find.text(l10n.genRCard));
      await tester.pumpAndSettle();
    }

    testWidgets('shows IdentityPicker and instruction text', (tester) async {
      await openSelectIdentityScreen(
        tester,
        identities: [FakeIdentities.primaryIdentity],
      );

      final l10n = await getL10n();
      expect(find.text(l10n.selectIdentityTitle), findsOneWidget);
      expect(find.text(l10n.selectIdentityInstruction), findsOneWidget);
      expect(
        find.byKey(const ValueKey('rcard_identity_picker')),
        findsOneWidget,
      );
    });

    testWidgets('Send button is enabled when an identity is pre-selected', (
      tester,
    ) async {
      await openSelectIdentityScreen(
        tester,
        identities: [FakeIdentities.primaryIdentity],
      );

      final l10n = await getL10n();
      final sendButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(l10n.sendRCard),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(sendButton.onPressed, isNotNull);
    });
  });

  group('R-Card disabled in group chat', () {
    testWidgets('R-Card option is disabled in the group chat bottom sheet', (
      tester,
    ) async {
      final groupContactId = FakeContacts.groupContact.id;

      await navigateToChat(
        tester,
        contactId: groupContactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.groupContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      final rCardOption = _findOptionTapTarget(
        tester,
        find.text(l10n.genRCard),
      );
      expect(rCardOption.onTap, isNull);
    });

    testWidgets('tapping disabled R-Card in group chat does nothing', (
      tester,
    ) async {
      final groupContactId = FakeContacts.groupContact.id;

      await navigateToChat(
        tester,
        contactId: groupContactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.groupContact],
        chatSdk: chatSdk,
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      await tester.tap(find.text(l10n.genRCard), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectIdentityTitle), findsNothing);
    });
  });

  group('R-Card auto exchange notice in chat', () {
    testWidgets('incoming R-Card autoExchange message '
        'shows "R-Cards have been exchanged."', (tester) async {
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: contactId,
        identities: [FakeIdentities.primaryIdentity],
        contacts: [FakeContacts.individualContact],
        chatSdk: chatSdk,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();

      final recipientDid = FakeChannels.individualChannel.permanentChannelDid!;
      final rCardPayload = jsonEncode({'vcBlob': '{}', 'isAutoExchange': true});
      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: recipientDid,
        attachments: [
          ChatAttachment(
            id: 'att-1',
            mediaType: 'application/json',
            format: RCardAttachment.pluginFormat,
            lastModifiedTime: DateTime(2024),
            data: ChatAttachmentData(json: rCardPayload),
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final l10n = await getL10n();
      expect(find.text(l10n.rCardsExchanged), findsOneWidget);
    });
  });
  group('_SelectRCardIdentityScreen — identity picker defaults', () {
    Future<void> openSelectIdentityScreen(
      WidgetTester tester, {
      required List<Identity> identities,
    }) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        identities: identities,
        contacts: [FakeContacts.individualContact],
        chatSdk: FakeChatSdk(),
        attachmentPlugins: attachmentPlugins,
        rCardsServiceFactory: () => FakeRCardsService(const []),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();
      final l10n = await getL10n();
      await tester.tap(find.text(l10n.genRCard));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'pre-selects primary identity by default when no current identity is set',
      (tester) async {
        await openSelectIdentityScreen(
          tester,
          identities: [
            FakeIdentities.primaryIdentity,
            FakeIdentities.secondaryIdentity,
          ],
        );

        final picker = tester.widget<IdentityPicker>(
          find.byKey(const ValueKey('rcard_identity_picker')),
        );
        expect(picker.initialCardIndex, 0);
      },
    );

    testWidgets(
      'pre-selects current identity when it differs from the primary',
      (tester) async {
        await navigateToChat(
          tester,
          contactId: contactId,
          identities: [
            FakeIdentities.primaryIdentity,
            FakeIdentities.secondaryIdentity,
          ],
          contacts: [FakeContacts.individualContact],
          chatSdk: FakeChatSdk(),
          attachmentPlugins: attachmentPlugins,
          rCardsServiceFactory: () => FakeRCardsService(const []),
        );
        await tester.pumpAndSettle();

        // Switch current identity to secondary before opening the R-Card screen
        final container = ProviderScope.containerOf(
          tester.element(find.byType(Scaffold).first),
        );
        container
            .read(identitiesServiceProvider.notifier)
            .setCurrentIdentityById(FakeIdentities.secondaryIdentity.id);
        await tester.pump();

        await tester.tap(find.byKey(const Key('chat_add_media_button')));
        await tester.pumpAndSettle();
        final l10n = await getL10n();
        await tester.tap(find.text(l10n.genRCard));
        await tester.pumpAndSettle();

        final picker = tester.widget<IdentityPicker>(
          find.byKey(const ValueKey('rcard_identity_picker')),
        );
        // Secondary identity is at index 1; the picker must open on it
        expect(picker.initialCardIndex, 1);
      },
    );
  });
}
