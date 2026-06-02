import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_errors.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/liveness_credentials_repository_provider.dart';
import 'package:ssi/ssi.dart' hide VcVerifier;
import 'package:vc_zkp/vc_zkp.dart';

import 'credential_service_test_support.dart';

void main() {
  initializeCredentialServiceTests();

  group('CredentialService.createLivenessCredential', () {
    late DidManager issuerManager;
    late ProviderContainer container;

    setUpAll(() async {
      issuerManager = await createTestIssuerDidManager();
    });

    setUp(() {
      container = ProviderContainer(
        overrides: credentialServiceTestOverrides(
          issuerManager: issuerManager,
        ).cast(),
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<CredentialService> service() async {
      final notifier = container.read(credentialServiceProvider.notifier);
      await notifier.ensureInitialized();
      return notifier;
    }

    test(
      'issues W3C credential, signed ZKP document, persistence, and session',
      () async {
        const identityId = 'identity-1';
        const holderDid = 'did:example:holder';
        final evidence = passingLivenessEvidence();

        final notifier = await service();
        final result = await notifier.createLivenessCredential(
          identityId: identityId,
          holderDid: holderDid,
          evidence: evidence,
        );

        expect(result.document.disclosures.single.field, 'did');
        expect(result.document.disclosures.single.value, holderDid);
        expect(result.holderPrivateKeyHex, hasLength(64));

        final verification = await VcVerifier().verifyDocument(
          result.document,
          issuerPublicKeyAx: result.issuerPub.ax,
          issuerPublicKeyAy: result.issuerPub.ay,
          isIssuerPubKeyMatchAlreadyVerified: true,
        );
        expect(verification.valid, isTrue);

        final state = container.read(credentialServiceProvider);
        expect(state.hasSessionMaterialFor(identityId), isTrue);
        expect(state.hasCredentialFor(identityId), isTrue);
        expect(state.latestCredential?.identityId, identityId);
        expect(state.latestCredential?.holderDid, holderDid);

        final record = state.credentialFor(identityId)!;
        expect(record.issuedToDid, holderDid);
        expect(record.livenessProvider, evidence.providerId);
        expect(record.zkpSignedDocumentJson, isNotEmpty);
        expect(record.w3cCredentialJson, isNotEmpty);

        final w3cJson =
            jsonDecode(record.w3cCredentialJson) as Map<String, dynamic>;
        expect(w3cJson['type'], contains('LivenessCredential'));

        final repository = await container.read(
          livenessCredentialsRepositoryProvider.future,
        );
        final persisted = await repository.list();
        expect(persisted, hasLength(1));
        expect(persisted.single.identityId, identityId);

        final prepared = await notifier.prepareCredentialForProof(
          identityId: identityId,
        );
        expect(prepared.holderPrivateKeyHex, record.zkpHolderPrivateKeyHex);
        expect(prepared.document.header['issuer'], record.issuerDid);
      },
    );

    test('throws when liveness evidence does not meet threshold', () async {
      final notifier = await service();

      await expectLater(
        notifier.createLivenessCredential(
          identityId: 'identity-1',
          holderDid: 'did:example:holder',
          evidence: failingLivenessEvidence(),
        ),
        throwsA(isA<LivenessEvidenceThresholdNotMetException>()),
      );

      expect(
        container
            .read(credentialServiceProvider)
            .hasCredentialFor('identity-1'),
        isFalse,
      );
    });
  });
}
