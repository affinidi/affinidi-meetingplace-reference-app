import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:circom_witnesscalc/circom_witnesscalc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rapidsnark/flutter_rapidsnark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vc_zkp/vc_zkp.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../credential_service/credential_service.dart';
import 'zkp_service_state.dart';

final zkpServiceProvider = Provider<ZkpService>(
  ZkpService.new,
  name: 'zkpServiceProvider',
);

/// BN254 field prime (for blinder factor generation)
final _bn254Prime = BigInt.parse(
  '''21888242871839275222246405745257275088548364400416034343698204186575808495617''',
);

/// Service responsible for Zero-Knowledge Proof generation and verification
class ZkpService {
  ZkpService(this._ref) {
    _logger = _ref.read(appLoggerProvider);
  }

  final Ref _ref;
  late final AppLogger _logger;

  static const _logKey = 'ZkpService';
  static const _wcdAsset = 'assets/zkp/SimpleVCProof.wcd';
  static const _zkeyAsset = 'assets/zkp/SimpleVCProof.groth16.zkey';
  static const _vkeyAsset = 'assets/zkp/SimpleVCProof.groth16.vkey.json';

  /// Generate random blinder factor (field element string)
  String _randomBlinderFactor() {
    final random = Random.secure();
    while (true) {
      final bytes = List<int>.generate(31, (_) => random.nextInt(256));
      var value = BigInt.zero;
      for (final b in bytes) {
        value = (value << 8) + BigInt.from(b);
      }
      value = value % _bn254Prime;
      if (value > BigInt.zero) {
        return value.toString();
      }
    }
  }

  /// Generate a Zero-Knowledge Proof from a Liveness VC in the current session
  Future<ZkpProofGenerationResult> generateProof({
    required String identityId,
    required String holderDid,
  }) async {
    _logger.info('Starting ZKP proof generation', name: _logKey);

    try {
      final stopwatch = Stopwatch()..start();

      _logger.info('  Step 1/5: Preparing liveness credential', name: _logKey);
      final credentialService = _ref.read(credentialServiceProvider.notifier);
      final credentialResult = await credentialService
          .prepareCredentialForProof(
            identityId: identityId,
            holderDid: holderDid,
          );

      final document = credentialResult.document;
      final issuerPub = credentialResult.issuerPub;
      final holderPrivateKeyHex = credentialResult.holderPrivateKeyHex;

      final crypto = RustEddsaHelperFfi();

      _logger.info('  Step 2/5: Preparing circuit inputs', name: _logKey);
      final holder = VcHolder(crypto: crypto);
      final holderInputs = await holder.prepareForCircuit(document);

      _logger.info('  Step 3/5: Generating challenge signature', name: _logKey);
      final challengeNonce = List<int>.generate(
        32,
        (_) => Random.secure().nextInt(256),
      );
      final challengeNonceHex = challengeNonce
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      final challengeNonceBi = BigInt.parse(challengeNonceHex, radix: 16);
      final challengeDigest = await crypto.poseidonHashFieldElements(<String>[
        '1',
        challengeNonceBi.toString(),
      ]);

      final challengeSig = await holder.signPreparedDigest(
        digest: challengeDigest,
        privateKeyHex: holderPrivateKeyHex,
      );

      final blinderFactor = _randomBlinderFactor();

      _logger.info(
        '  Step 4/5: Building circuit inputs and generating witness',
        name: _logKey,
      );
      final sig = document.signature;
      final circuitInputs = <String, Object?>{
        'header_commitments': holderInputs.headerCommitments,
        'payload_commitments': holderInputs.payloadCommitments,
        'issuerAx': issuerPub.ax,
        'issuerAy': issuerPub.ay,
        'documentR8x': sig.r8[0],
        'documentR8y': sig.r8[1],
        'documentS': sig.s,
        'holderAx': holderInputs.holderAx,
        'holderAy': holderInputs.holderAy,
        'challengeDigest': challengeDigest,
        'challengeR8x': challengeSig.r8[0],
        'challengeR8y': challengeSig.r8[1],
        'challengeS': challengeSig.s,
        'blinder_factor': blinderFactor,
      };

      final wcdBytes = await rootBundle.load(_wcdAsset);
      final witness = await CircomWitnesscalc().calculateWitness(
        inputs: jsonEncode(circuitInputs),
        graphData: wcdBytes.buffer.asUint8List(),
      );

      if (witness == null) {
        _logger.error('Failed to calculate witness', name: _logKey);
        return const ZkpProofGenerationResult.failure(
          'Failed to calculate witness',
        );
      }

      final zkeyBytes = await rootBundle.load(_zkeyAsset);
      final tempDir = await getTemporaryDirectory();
      final zkeyFile = File('${tempDir.path}/SimpleVCProof.groth16.zkey');
      if (!zkeyFile.existsSync()) {
        await zkeyFile.create(recursive: true);
      }
      await zkeyFile.writeAsBytes(zkeyBytes.buffer.asUint8List());

      _logger.info('  Step 5/5: Generating ZKP proof', name: _logKey);
      final proof = await Rapidsnark().groth16Prove(
        zkeyPath: zkeyFile.path,
        witness: witness,
      );

      stopwatch.stop();
      final timeMs = stopwatch.elapsedMilliseconds;

      _logger.info(
        'ZKP proof generated successfully in ${timeMs}ms',
        name: _logKey,
      );

      return ZkpProofGenerationResult.success(
        ZkpProofResult(
          proof: proof.proof,
          publicSignals: proof.publicSignals,
          generationTimeMs: timeMs,
        ),
      );
    } on LivenessCredentialSessionMissingException {
      return const ZkpProofGenerationResult.failure(
        LivenessCredentialSessionMissingException.message,
      );
    } catch (e, st) {
      _logger.error(
        'Failed to generate ZKP proof: $e',
        name: _logKey,
        stackTrace: st,
      );
      return ZkpProofGenerationResult.failure(
        'Failed to generate ZKP proof: $e',
      );
    }
  }

  /// Verify a Zero-Knowledge Proof
  ///
  /// Validates the cryptographic proof against the verification key
  Future<ZkpVerificationResult> verifyProof({
    required String proof,
    required String publicSignals,
  }) async {
    _logger.info('Starting ZKP proof verification', name: _logKey);

    try {
      // Load verification key
      final vkeyJson = await rootBundle.loadString(_vkeyAsset);

      // Verify the proof using Rapidsnark
      final isValid = await Rapidsnark().groth16Verify(
        proof: proof,
        inputs: publicSignals,
        verificationKey: vkeyJson,
      );

      _logger.info('Proof verification result: $isValid', name: _logKey);

      return isValid
          ? const ZkpVerificationResult.success()
          : const ZkpVerificationResult.failure('Proof verification failed');
    } catch (e, st) {
      _logger.error(
        'Failed to verify proof: $e',
        name: _logKey,
        stackTrace: st,
      );
      return ZkpVerificationResult.failure('Verification error: $e');
    }
  }
}
