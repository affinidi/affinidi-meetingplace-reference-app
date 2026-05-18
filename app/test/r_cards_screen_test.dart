import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:ssi/ssi.dart';

import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_r_cards_service.dart';
import 'utils/app.dart';

Future<String> _buildSignedVcBlob({
  required DidKeyManager issuerManager,
  required String issuerDid,
  required String subjectDid,
  required RCardSubject subject,
}) async {
  final vc = await CredentialBuilder.buildRCard(
    issuerDid: issuerDid,
    subjectDid: subjectDid,
    subject: subject,
    issuerDidManager: issuerManager,
  );
  return jsonEncode(vc.toJson());
}

void main() {
  late DidKeyManager issuerManager;
  late String issuerDid;
  late String aliceVcBlob;
  late String bobVcBlob;
  const aliceSubjectDid = 'did:key:alice-rcard-screen';
  const bobSubjectDid = 'did:key:bob-rcard-screen';

  setUpAll(() async {
    final wallet = PersistentWallet(InMemoryKeyStore());
    issuerManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());
    final keyPair = await wallet.generateKey();
    await issuerManager.addVerificationMethod(keyPair.id);
    final didDoc = await issuerManager.getDidDocument();
    issuerDid = didDoc.id;

    aliceVcBlob = await _buildSignedVcBlob(
      issuerManager: issuerManager,
      issuerDid: issuerDid,
      subjectDid: aliceSubjectDid,
      subject: const RCardSubject(firstName: 'Alice', lastName: 'Smith'),
    );
    bobVcBlob = await _buildSignedVcBlob(
      issuerManager: issuerManager,
      issuerDid: issuerDid,
      subjectDid: bobSubjectDid,
      subject: const RCardSubject(firstName: 'Bob', lastName: 'Jones'),
    );
  });

  group('RCardsScreen', () {
    testWidgets('shows section banner with R-Cards title and subtitle', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
      );
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.tabsTitle('rCards')), findsWidgets);
      expect(find.text(l10n.rCardsPanelSubtitle), findsOneWidget);
    });

    testWidgets('shows empty state when no cards are in the wallet', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
      );
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.textContaining(l10n.rCardsEmpty), findsOneWidget);
    });

    testWidgets('shows filter tabs All and Non-anonymous', (tester) async {
      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
      );
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.rCardsFilterLabel('all')), findsWidgets);
      expect(find.text(l10n.rCardsFilterLabel('nonAnonymous')), findsWidgets);
    });

    testWidgets('shows search field when search icon is tapped', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows cards when wallet has R-Cards', (tester) async {
      final alice = RCard(
        subjectDid: aliceSubjectDid,
        vcBlob: aliceVcBlob,
        issuerDid: issuerDid,
        version: 1,
        issuanceDate: DateTime(2024),
        receivedAt: DateTime(2024),
      );
      final bob = RCard(
        subjectDid: bobSubjectDid,
        vcBlob: bobVcBlob,
        issuerDid: issuerDid,
        version: 1,
        issuanceDate: DateTime(2024),
        receivedAt: DateTime(2024),
      );

      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        rCards: [alice, bob],
      );
      await tester.pumpAndSettle();

      // With cards in wallet, the empty state text is gone
      final l10n = await getL10n();
      expect(find.textContaining(l10n.rCardsEmpty), findsNothing);
      // At least one card name should be visible
      expect(
        find.textContaining('Alice').evaluate().isNotEmpty ||
            find.textContaining('Bob').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('export button is disabled when no cards are present', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
      );
      await tester.pumpAndSettle();

      final exportButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.download_outlined),
      );
      expect(exportButton.onPressed, isNull);
    });

    testWidgets('export button is enabled when cards are present', (
      tester,
    ) async {
      final alice = RCard(
        subjectDid: aliceSubjectDid,
        vcBlob: aliceVcBlob,
        issuerDid: issuerDid,
        version: 1,
        issuanceDate: DateTime(2024),
        receivedAt: DateTime(2024),
      );

      await navigateToLocation(
        tester,
        '/r-cards',
        identities: [FakeIdentities.primaryIdentity],
        mediators: [],
        contacts: [FakeContacts.individualContact],
        rCards: [alice],
      );
      await tester.pumpAndSettle();

      final exportButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.download_outlined),
      );
      expect(exportButton.onPressed, isNotNull);
    });

    testWidgets(
      'tapping export button calls exportAllAsVcf on the service notifier',
      (tester) async {
        // Mock share_plus to avoid MissingPluginException
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('dev.fluttercommunity.plus/share'),
              (MethodCall methodCall) async => null,
            );

        final alice = RCard(
          subjectDid: aliceSubjectDid,
          vcBlob: aliceVcBlob,
          issuerDid: issuerDid,
          version: 1,
          issuanceDate: DateTime(2024),
          receivedAt: DateTime(2024),
        );

        late FakeRCardsService capturedService;
        await navigateToLocation(
          tester,
          '/r-cards',
          identities: [FakeIdentities.primaryIdentity],
          mediators: [],
          contacts: [FakeContacts.individualContact],
          rCardsServiceFactory: () {
            capturedService = FakeRCardsService([alice]);
            return capturedService;
          },
        );
        await tester.pumpAndSettle();

        // Export button should be enabled (card exists in service)
        final exportButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.download_outlined),
        );
        expect(exportButton.onPressed, isNotNull);

        await tester.tap(
          find.widgetWithIcon(IconButton, Icons.download_outlined),
        );
        await tester.pumpAndSettle();

        expect(capturedService.exportAllCalled, isTrue);
      },
    );
  });
}
