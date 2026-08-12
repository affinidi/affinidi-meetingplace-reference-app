import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/sign_document_plugin/sign_document_plugin.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_context_routing_store.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

const _addMediaButtonKey = Key('chat_add_media_button');

Future<void> _openMediaSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(_addMediaButtonKey));
  await tester.pumpAndSettle();
}

bool _isVrcOptionEnabled(WidgetTester tester, String label) {
  final option = tester.widget<InkWell>(
    find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
  );

  return option.onTap != null;
}

PersonalAiServiceState _personalAiState({required bool isReady}) {
  return isReady
      ? const PersonalAiServiceState(
          status: PersonalAiSetupStatus.ready,
          showSetupPrompt: false,
          promptDismissed: false,
          contextProvisioned: true,
          contextUploading: false,
          setupResult: PersonalAgentSetupResult(
            holderDid: 'did:key:primary-identity',
            contextId: 'work-ai',
            contextCreated: true,
            agentDid: 'did:key:agent',
            agentCreated: true,
            profile: PersonalAgentProfile(
              agentDid: 'did:key:agent',
              displayName: 'Work AI',
              mode: PersonalAgentMode.suggestions,
            ),
            setupId: 'setup-work-1',
            setupStatus: 'ready',
            mpxConnectionCreated: true,
          ),
        )
      : const PersonalAiServiceState.initial();
}

List<SignDocumentPlugin> _signDocumentPlugins() => [
  SignDocumentPlugin(filePickerPlatform: _UnusedFilePickerPlatform()),
];

void main() {
  group('Chat attachment VRC option', () {
    testWidgets('shows VRC option in media options sheet', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(tester);
      await _openMediaSheet(tester);

      expect(find.text(l10n.vrcAbbreviation), findsOneWidget);
    });

    testWidgets('VRC option is enabled in a fresh chat', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(tester);
      await _openMediaSheet(tester);

      final enabled = _isVrcOptionEnabled(tester, l10n.vrcAbbreviation);
      expect(enabled, isTrue);
    });

    testWidgets('VRC option is disabled after exchange is initiated', (
      tester,
    ) async {
      final l10n = await getL10n();
      final chatSdk = FakeChatSdk();

      await navigateToChat(tester, chatSdk: chatSdk);

      chatSdk.simulateVrcEvent(
        eventType: 'vrcExchangeInitiated',
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      await _openMediaSheet(tester);

      final enabled = _isVrcOptionEnabled(tester, l10n.vrcAbbreviation);
      expect(enabled, isFalse);
    });

    testWidgets('VRC option is re-enabled after Do later is tapped', (
      tester,
    ) async {
      final l10n = await getL10n();

      await navigateToChat(tester);

      // Tap Do later from the banner — this should keep the attachment enabled
      await tester.tap(find.text(l10n.doLater));
      await tester.pumpAndSettle();

      await _openMediaSheet(tester);

      final enabled = _isVrcOptionEnabled(tester, l10n.vrcAbbreviation);
      expect(enabled, isTrue);
    });
  });

  group('Chat sign document option', () {
    testWidgets('shows Sign Document in a non-agent chat', (tester) async {
      await navigateToChat(tester, attachmentPlugins: _signDocumentPlugins());
      await _openMediaSheet(tester);

      expect(find.text('Sign Document'), findsOneWidget);
    });

    testWidgets('hides Sign Document in an agent chat', (tester) async {
      final agentContact = FakeContacts.agentContact;

      await navigateToChat(
        tester,
        contactId: agentContact.id,
        contacts: [agentContact],
        attachmentPlugins: _signDocumentPlugins(),
      );
      await _openMediaSheet(tester);

      expect(find.text('Sign Document'), findsNothing);
    });

    testWidgets('disables Sign Document when personal agent is not connected', (
      tester,
    ) async {
      await navigateToChat(
        tester,
        attachmentPlugins: _signDocumentPlugins(),
        personalAiState: _personalAiState(isReady: false),
      );
      await _openMediaSheet(tester);

      final enabled = _isVrcOptionEnabled(tester, 'Sign Document');
      expect(enabled, isFalse);
    });

    testWidgets('shows guidance when disabled Sign Document is tapped', (
      tester,
    ) async {
      await navigateToChat(
        tester,
        attachmentPlugins: _signDocumentPlugins(),
        personalAiState: _personalAiState(isReady: false),
      );
      await _openMediaSheet(tester);

      await tester.tap(find.text('Sign Document'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'To use Sign Document, go to the Agent tab and complete setup.',
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('enables Sign Document when personal agent is connected', (
      tester,
    ) async {
      await navigateToChat(
        tester,
        attachmentPlugins: _signDocumentPlugins(),
        personalAiState: _personalAiState(isReady: true),
        contextRoutingStore: FakeContextRoutingStore(workContextUploaded: true),
      );
      await _openMediaSheet(tester);

      final enabled = _isVrcOptionEnabled(tester, 'Sign Document');
      expect(enabled, isTrue);
    });

    testWidgets(
      '''enables Sign Document after restart when work context is already connected''',
      (tester) async {
        await navigateToChat(
          tester,
          attachmentPlugins: _signDocumentPlugins(),
          personalAiState: _personalAiState(isReady: false),
          contextRoutingStore: FakeContextRoutingStore(
            workContextUploaded: true,
          ),
        );
        await _openMediaSheet(tester);

        final enabled = _isVrcOptionEnabled(tester, 'Sign Document');
        expect(enabled, isTrue);
      },
    );

    testWidgets('disables Sign Document in group chat', (tester) async {
      final groupContactId = FakeContacts.groupContact.id;

      await navigateToChat(
        tester,
        contactId: groupContactId,
        contacts: [FakeContacts.groupContact],
        attachmentPlugins: _signDocumentPlugins(),
        personalAiState: _personalAiState(isReady: true),
      );
      await _openMediaSheet(tester);

      final enabled = _isVrcOptionEnabled(tester, 'Sign Document');
      expect(enabled, isFalse);
    });
  });
}

class _UnusedFilePickerPlatform extends FilePickerPlatform {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic Function(FilePickerStatus)? onFileLoading,
    AndroidSAFOptions? androidSafOptions,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
  }) async => null;
}
