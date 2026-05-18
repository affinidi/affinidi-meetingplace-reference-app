import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachments_plugin.dart';

import 'fakes/fake_cache_manager.dart';
import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_r_card_attachments_plugin.dart';
import 'utils/app.dart';

void _mockSharePlus() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/share'),
        (MethodCall methodCall) async => {'status': 'success', 'raw': ''},
      );
}

List<AttachmentPlugin> _pluginsWithRCard(BaseCacheManager cacheManager) => [
  RCardAttachmentsPlugin(cacheManager: cacheManager),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final contactId = FakeContacts.individualContact.id;
  final meetingPlaceChatSDK = FakeChatSdk();

  setUpAll(_mockSharePlus);

  group('R-Card attachment bottom sheet', () {
    testWidgets('shows R-Card option with correct label in bottom sheet', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text('💳'), findsOneWidget);
      expect(find.text(l10n.genRCard), findsOneWidget);
    });

    testWidgets('R-Card option is enabled (onTap is non-null) '
        'when isPlatformSupported = true', (tester) async {
      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      final rCardTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text(l10n.genRCard),
          matching: find.byType(ListTile),
        ),
      );
      expect(rCardTile.enabled, isTrue);
    });

    testWidgets('R-Card option is disabled when isPlatformSupported = false', (
      tester,
    ) async {
      final disabledPlugin = FakeUnsupportedRCardPlugin();

      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: [disabledPlugin],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('R-Card (disabled)'), findsOneWidget);
      final rCardTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.textContaining('R-Card (disabled)'),
          matching: find.byType(ListTile),
        ),
      );
      expect(rCardTile.enabled, isFalse);
    });

    testWidgets(
      'R-Card option is absent when RCardPlugin is not in the plugins list',
      (tester) async {
        await navigateToLocation(
          tester,
          '/contacts/$contactId/chat',
          identities: [FakeIdentities.primaryIdentity],
          mediators: [],
          contacts: [FakeContacts.individualContact],
          meetingPlaceChatSDK: meetingPlaceChatSDK,
          attachmentPlugins: const [],
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
      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
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
      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
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
      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: identities,
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
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

      await navigateToLocation(
        tester,
        '/contacts/$groupContactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.groupContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chat_add_media_button')));
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      final rCardTile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text(l10n.genRCard),
          matching: find.byType(ListTile),
        ),
      );
      expect(rCardTile.enabled, isFalse);
    });

    testWidgets('tapping disabled R-Card in group chat does nothing', (
      tester,
    ) async {
      final groupContactId = FakeContacts.groupContact.id;

      await navigateToLocation(
        tester,
        '/contacts/$groupContactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.groupContact],
        meetingPlaceChatSDK: meetingPlaceChatSDK,
        attachmentPlugins: _pluginsWithRCard(FakeCacheManager()),
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

      await navigateToLocation(
        tester,
        '/contacts/$contactId/chat',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        meetingPlaceChatSDK: chatSdk,
      );
      await tester.pumpAndSettle();

      final recipientDid = FakeChannels.individualChannel.permanentChannelDid!;
      final rCardPayload = jsonEncode({'vcBlob': '{}', 'isAutoExchange': true});
      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: recipientDid,
        attachments: [
          chat.Attachment(
            id: 'att-1',
            mediaType: 'application/json',
            format: RCardAttachment.pluginFormat,
            lastModifiedTime: DateTime(2024),
            data: chat.AttachmentData(json: rCardPayload),
          ),
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final l10n = await getL10n();
      expect(find.text(l10n.rCardsExchanged), findsOneWidget);
    });
  });
}
