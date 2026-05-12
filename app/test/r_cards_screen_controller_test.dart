import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/application/services/r_cards_service/r_cards_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/r_cards/r_cards_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/r_cards/r_cards_screen_filter.dart';
import 'package:ssi/ssi.dart';

import 'fakes/fake_r_cards_service.dart';

ReceivedRCard _card({required String subjectDid, required String vcBlob}) {
  return ReceivedRCard(
    subjectDid: subjectDid,
    vcBlob: vcBlob,
    issuerDid: 'did:key:issuer',
    version: 1,
    issuanceDate: DateTime(2024),
    receivedAt: DateTime(2024),
  );
}

Future<String> _buildSignedRCardBlob({
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
  late String aliceSmithVcBlob;
  late String bobJonesVcBlob;
  late String anonymousVcBlob;

  setUpAll(() async {
    final wallet = PersistentWallet(InMemoryKeyStore());
    issuerManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());
    final keyPair = await wallet.generateKey();
    await issuerManager.addVerificationMethod(keyPair.id);
    final didDoc = await issuerManager.getDidDocument();
    issuerDid = didDoc.id;

    aliceSmithVcBlob = await _buildSignedRCardBlob(
      issuerManager: issuerManager,
      issuerDid: issuerDid,
      subjectDid: 'did:key:alice',
      subject: const RCardSubject(firstName: 'Alice', lastName: 'Smith'),
    );
    bobJonesVcBlob = await _buildSignedRCardBlob(
      issuerManager: issuerManager,
      issuerDid: issuerDid,
      subjectDid: 'did:key:bob',
      subject: const RCardSubject(firstName: 'Bob', lastName: 'Jones'),
    );
    anonymousVcBlob = await _buildSignedRCardBlob(
      issuerManager: issuerManager,
      issuerDid: issuerDid,
      subjectDid: 'did:key:anon',
      subject: const RCardSubject(firstName: 'Anonymous'),
    );
  });

  group('RCardsScreenController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer containerWithCards(List<ReceivedRCard> cards) {
      return ProviderContainer(
        overrides: [
          rCardsServiceProvider.overrideWith(() => FakeRCardsService(cards)),
        ],
      )..read(rCardsServiceProvider);
    }

    test('initial state returns all cards unfiltered', () {
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final bob = _card(subjectDid: 'did:2', vcBlob: bobJonesVcBlob);
      final c = containerWithCards([alice, bob]);

      final state = c.read(rCardsScreenControllerProvider);

      expect(state.cards, hasLength(2));
      expect(state.filter, RCardsScreenFilter.all);
    });

    test('search filters by first name', () {
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final bob = _card(subjectDid: 'did:2', vcBlob: bobJonesVcBlob);
      final c = containerWithCards([alice, bob]);

      c.read(rCardsScreenControllerProvider.notifier).search('alice');

      expect(c.read(rCardsScreenControllerProvider).cards, hasLength(1));
      expect(
        c.read(rCardsScreenControllerProvider).cards.first.subjectDid,
        'did:1',
      );
    });

    test('search is case-insensitive', () {
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final c = containerWithCards([alice]);

      c.read(rCardsScreenControllerProvider.notifier).search('ALICE');

      expect(c.read(rCardsScreenControllerProvider).cards, hasLength(1));
    });

    test('search returns empty list when no match', () {
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final c = containerWithCards([alice]);

      c.read(rCardsScreenControllerProvider.notifier).search('xyz');

      expect(c.read(rCardsScreenControllerProvider).cards, isEmpty);
    });

    test('applyFilter nonAnonymous excludes anonymous cards', () {
      const anonymousLabel = 'Anonymous';
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final anon = _card(subjectDid: 'did:2', vcBlob: anonymousVcBlob);
      final c = containerWithCards([alice, anon]);

      c
          .read(rCardsScreenControllerProvider.notifier)
          .setAnonymousLabel(anonymousLabel);
      c
          .read(rCardsScreenControllerProvider.notifier)
          .applyFilter(RCardsScreenFilter.nonAnonymous);

      final cards = c.read(rCardsScreenControllerProvider).cards;
      expect(cards, hasLength(1));
      expect(cards.first.subjectDid, 'did:1');
    });

    test('applyFilter all restores full list after nonAnonymous filter', () {
      const anonymousLabel = 'Anonymous';
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final anon = _card(subjectDid: 'did:2', vcBlob: anonymousVcBlob);
      final c = containerWithCards([alice, anon]);

      c
          .read(rCardsScreenControllerProvider.notifier)
          .setAnonymousLabel(anonymousLabel);
      c
          .read(rCardsScreenControllerProvider.notifier)
          .applyFilter(RCardsScreenFilter.nonAnonymous);
      c
          .read(rCardsScreenControllerProvider.notifier)
          .applyFilter(RCardsScreenFilter.all);

      expect(c.read(rCardsScreenControllerProvider).cards, hasLength(2));
    });

    test('applyFilter resets active search query', () {
      final alice = _card(subjectDid: 'did:1', vcBlob: aliceSmithVcBlob);
      final bob = _card(subjectDid: 'did:2', vcBlob: bobJonesVcBlob);
      final c = containerWithCards([alice, bob]);

      c.read(rCardsScreenControllerProvider.notifier).search('alice');
      expect(c.read(rCardsScreenControllerProvider).cards, hasLength(1));

      c
          .read(rCardsScreenControllerProvider.notifier)
          .applyFilter(RCardsScreenFilter.all);

      expect(c.read(rCardsScreenControllerProvider).cards, hasLength(2));
    });
  });
}
