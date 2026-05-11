import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_cards_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/r_card_attachments_plugin/r_card_attachment.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_items/chat_r_card_received_notice.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_items/chat_r_card_sent_notice.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_items/chat_r_card_updated_by_me_notice.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_items/chat_r_cards_exchanged_notice.dart';
import 'package:ssi/ssi.dart';

import 'fakes/fake_r_cards_service.dart';
import 'utils/app.dart';

Widget _l10n(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

chat.Attachment _rCardAttachment({
  required String vcBlob,
  bool isUpdate = false,
  bool isAutoExchange = false,
}) {
  final payload = jsonEncode({
    'vcBlob': vcBlob,
    if (isUpdate) 'isUpdate': true,
    if (isAutoExchange) 'isAutoExchange': true,
  });
  return chat.Attachment(
    id: 'att-${DateTime.now().millisecondsSinceEpoch}',
    mediaType: 'application/json',
    format: RCardAttachment.pluginFormat,
    lastModifiedTime: DateTime(2024),
    data: chat.AttachmentData(json: payload),
  );
}

chat.Message _rCardMessage({
  required chat.Attachment attachment,
  bool isFromMe = false,
}) => chat.Message(
  chatId: 'test-chat',
  messageId: 'test-msg-${DateTime.now().millisecondsSinceEpoch}',
  value: '',
  dateCreated: DateTime(2024),
  status: chat.ChatItemStatus.confirmed,
  isFromMe: isFromMe,
  senderDid: 'did:key:sender',
  attachments: [attachment],
);

Future<String> _buildSignedRCardBlob({
  required DidKeyManager issuerManager,
  required String issuerDid,
  required String subjectDid,
}) async {
  final vc = await CredentialBuilder.buildRCard(
    issuerDid: issuerDid,
    subjectDid: subjectDid,
    subject: const RCardSubject(firstName: 'Alice', lastName: 'Test'),
    issuerDidManager: issuerManager,
  );
  return jsonEncode(vc.toJson());
}

void main() {
  group('ChatRCardSentNotice', () {
    testWidgets('renders rCardFooterSent text', (tester) async {
      final l10n = await getL10n();
      await tester.pumpWidget(
        _l10n(ChatRCardSentNotice(dateCreated: DateTime(2024))),
      );
      await tester.pump();
      expect(find.text(l10n.rCardFooterSent), findsOneWidget);
    });
  });

  group('ChatRCardReceivedNotice', () {
    testWidgets('renders rCardFooterSaved text', (tester) async {
      final l10n = await getL10n();
      await tester.pumpWidget(
        _l10n(ChatRCardReceivedNotice(dateCreated: DateTime(2024))),
      );
      await tester.pump();
      expect(find.text(l10n.rCardFooterSaved), findsOneWidget);
    });
  });

  group('ChatRCardUpdatedByMeNotice', () {
    testWidgets('renders rCardFooterUpdateShared text', (tester) async {
      final l10n = await getL10n();
      await tester.pumpWidget(
        _l10n(ChatRCardUpdatedByMeNotice(dateCreated: DateTime(2024))),
      );
      await tester.pump();
      expect(find.text(l10n.rCardFooterUpdateShared), findsOneWidget);
    });
  });

  group('ChatRCardsExchangedNotice', () {
    late DidKeyManager issuerManager;
    late String issuerDid;
    late String signedVcBlob;
    const subjectDid = 'did:key:alice-test-subject';

    setUpAll(() async {
      final wallet = PersistentWallet(InMemoryKeyStore());
      issuerManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());
      final keyPair = await wallet.generateKey();
      await issuerManager.addVerificationMethod(keyPair.id);
      final didDoc = await issuerManager.getDidDocument();
      issuerDid = didDoc.id;
      signedVcBlob = await _buildSignedRCardBlob(
        issuerManager: issuerManager,
        issuerDid: issuerDid,
        subjectDid: subjectDid,
      );
    });

    testWidgets('renders rCardsExchanged text', (tester) async {
      final l10n = await getL10n();
      final msg = _rCardMessage(
        attachment: _rCardAttachment(vcBlob: '{}', isAutoExchange: true),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rCardsServiceProvider.overrideWith(() => FakeRCardsService([])),
          ],
          child: _l10n(ChatRCardsExchangedNotice(chatItem: msg)),
        ),
      );
      await tester.pump();
      expect(find.text(l10n.rCardsExchanged), findsOneWidget);
    });

    testWidgets('hides Go to R-Card link when card is not in wallet', (
      tester,
    ) async {
      final l10n = await getL10n();
      final msg = _rCardMessage(
        attachment: _rCardAttachment(vcBlob: '{}', isAutoExchange: true),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rCardsServiceProvider.overrideWith(() => FakeRCardsService([])),
          ],
          child: _l10n(ChatRCardsExchangedNotice(chatItem: msg)),
        ),
      );
      await tester.pump();
      expect(find.text(l10n.goToRCard), findsNothing);
    });

    testWidgets('shows Go to R-Card link when card is in wallet', (
      tester,
    ) async {
      final l10n = await getL10n();
      final rCard = RCard(
        subjectDid: subjectDid,
        vcBlob: signedVcBlob,
        issuerDid: issuerDid,
        version: 1,
        issuanceDate: DateTime(2024),
        receivedAt: DateTime(2024),
      );

      final msg = _rCardMessage(
        attachment: _rCardAttachment(
          vcBlob: signedVcBlob,
          isAutoExchange: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rCardsServiceProvider.overrideWith(
              () => FakeRCardsService([rCard]),
            ),
          ],
          child: _l10n(ChatRCardsExchangedNotice(chatItem: msg)),
        ),
      );
      await tester.pump();

      expect(find.text(l10n.rCardsExchanged), findsOneWidget);
      expect(find.text(l10n.goToRCard), findsOneWidget);
    });
  });
}
