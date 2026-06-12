import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_errors.dart';
import 'package:mpx_flutter_reference_app/application/services/zkp_service/zkp_service.dart';
import 'package:mpx_flutter_reference_app/application/services/zkp_service/zkp_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/zkp/zkp_challenge_nonce.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:vc_zkp/vc_zkp.dart';

import 'zkp_service_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/zkp_service_test.log'),
  );

  group('ZkpService.challengeDigestFromNonce', () {
    late ProviderContainer container;
    late ZkpService service;
    late String expectedDigest;

    setUpAll(() async {
      final challengeNonceHex = zkpChallengeNonceToHex(testZkpChallengeNonce);
      final challengeNonceBi = BigInt.parse(challengeNonceHex, radix: 16);
      expectedDigest = await RustEddsaHelperFfi().poseidonHashFieldElements(
        <String>['1', challengeNonceBi.toString()],
      );
    });

    setUp(() {
      container = ProviderContainer();
      service = container.read(zkpServiceProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('returns domain-tagged Poseidon digest for a 32-byte nonce', () async {
      final digest = await service.challengeDigestFromNonce(
        testZkpChallengeNonce,
      );

      expect(digest, expectedDigest);
    });

    test('is deterministic for the same nonce', () async {
      final first = await service.challengeDigestFromNonce(
        testZkpChallengeNonce,
      );
      final second = await service.challengeDigestFromNonce(
        testZkpChallengeNonce,
      );

      expect(first, second);
    });

    test('throws when nonce length is not 32', () async {
      await expectLater(
        () => service.challengeDigestFromNonce([1, 2, 3]),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('32'),
          ),
        ),
      );
    });
  });

  group('ZkpService.generateProof', () {
    late ProviderContainer container;
    late ZkpService service;

    tearDown(() {
      container.dispose();
    });

    test(
      'returns session-missing failure when credential material is absent',
      () async {
        container = ProviderContainer(
          overrides: [
            credentialServiceProvider.overrideWith(
              (ref) => FakeCredentialService(ref: ref, missingSession: true),
            ),
          ],
        );
        service = container.read(zkpServiceProvider);

        final result = await service.generateProof(
          identityId: 'identity-1',
          challengeNonce: testZkpChallengeNonce,
        );

        expect(
          result,
          isA<ZkpProofGenerationFailure>().having(
            (r) => r.error,
            'error',
            LivenessCredentialSessionMissingException.message,
          ),
        );
      },
    );

    test('returns failure when challenge nonce length is invalid', () async {
      final credentialResult = await buildTestCredentialCreationResult();
      container = ProviderContainer(
        overrides: [
          credentialServiceProvider.overrideWith(
            (ref) => FakeCredentialService(
              ref: ref,
              credentialResult: credentialResult,
            ),
          ),
        ],
      );
      service = container.read(zkpServiceProvider);

      final result = await service.generateProof(
        identityId: 'identity-1',
        challengeNonce: [0, 1, 2],
      );

      expect(result, isA<ZkpProofGenerationFailure>());
      expect(
        (result as ZkpProofGenerationFailure).error,
        contains('challenge nonce must be 32 bytes'),
      );
    });

    test(
      'binds verifier challenge into holder circuit inputs before witness',
      () async {
        final credentialResult = await buildTestCredentialCreationResult();
        container = ProviderContainer(
          overrides: [
            credentialServiceProvider.overrideWith(
              (ref) => FakeCredentialService(
                ref: ref,
                credentialResult: credentialResult,
              ),
            ),
          ],
        );
        service = container.read(zkpServiceProvider);

        final prepared = await container
            .read(credentialServiceProvider.notifier)
            .prepareCredentialForProof(identityId: 'identity-1');

        final crypto = RustEddsaHelperFfi();
        final holder = VcHolder(crypto: crypto);
        final holderInputs = await holder.prepareForCircuit(prepared.document);
        final challengeDigest = await service.challengeDigestFromNonce(
          testZkpChallengeNonce,
        );
        final challengeSig = await holder.signPreparedDigest(
          digest: challengeDigest,
          privateKeyHex: prepared.holderPrivateKeyHex,
        );

        final sig = prepared.document.signature;
        final circuitInputs = <String, Object?>{
          'header_commitments': holderInputs.headerCommitments,
          'payload_commitments': holderInputs.payloadCommitments,
          'issuerAx': prepared.issuerPub.ax,
          'issuerAy': prepared.issuerPub.ay,
          'documentR8x': sig.r8[0],
          'documentR8y': sig.r8[1],
          'documentS': sig.s,
          'holderAx': holderInputs.holderAx,
          'holderAy': holderInputs.holderAy,
          'challengeDigest': challengeDigest,
          'challengeR8x': challengeSig.r8[0],
          'challengeR8y': challengeSig.r8[1],
          'challengeS': challengeSig.s,
          'blinder_factor': '1',
        };

        expect(circuitInputs['challengeDigest'], isNotEmpty);
        expect(circuitInputs['challengeS'], isNotEmpty);
        expect(circuitInputs['issuerAx'], prepared.issuerPub.ax);
      },
    );
  });
}
