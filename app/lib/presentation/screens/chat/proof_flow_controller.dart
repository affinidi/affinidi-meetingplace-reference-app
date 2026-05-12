import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../../application/services/zkp_service/zkp_constants.dart';
import '../../../application/services/zkp_service/zkp_service.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../credentials/credentials_screen_controller.dart';
import 'chat_screen_controller.dart';
import 'proof_flow_state.dart';

final proofFlowControllerProvider =
    StateNotifierProvider.family<ProofFlowController, ProofFlowState, String>((
      ref,
      contactId,
    ) {
      return ProofFlowController(ref: ref, contactId: contactId);
    });

class ProofFlowController extends StateNotifier<ProofFlowState> {
  ProofFlowController({required this.ref, required this.contactId})
    : super(const ProofFlowState()) {
    _logger = ref.read(appLoggerProvider);
  }

  final Ref ref;
  final String contactId;
  late final AppLogger _logger;
  static const _logKey = 'ProofFlowController';

  /// Request liveness check from contact
  Future<void> requestLivenessCheck() async {
    final chatController = ref.read(
      chatScreenControllerProvider(contactId).notifier,
    );

    await chatController.sendMessageDirect(
      '', // Empty message - UI banners will show the request // TODO
      attachments: [
        chat.Attachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          mediaType: 'application/json',
          format: ZkpConstants.livenessCheckRequestType,
          lastModifiedTime: DateTime.now(),
          data: chat.AttachmentData(json: '{"type":"liveness_request"}'),
        ),
      ],
    );
  }

  /// Called when contact receives liveness check request
  void onLivenessRequestReceived() {
    state = state.copyWith(hasIncomingRequest: true);
  }

  /// Dismiss incoming request and insert a "paused" notice
  void dismissRequest() {
    state = state.copyWith(hasIncomingRequest: false);
  }

  /// Clear verification failure state after dismissing result banner.
  void clearVerificationFailure() {
    state = state.copyWith(
      verificationFailed: false,
      errorMessage: null,
      isVerifyingProof: false,
    );
  }

  /// Search for Liveness VC in wallet (always returns false
  /// for fresh generation)
  Future<bool> searchForVC() async {
    state = state.copyWith(isCheckingVC: true);

    // Simulate search delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // Always false - we generate fresh VCs each time
    state = state.copyWith(isCheckingVC: false, hasVC: false);

    return false;
  }

  /// Issue new Liveness VC via AWS Rekognition (mock liveness check)
  Future<void> issueVC() async {
    state = state.copyWith(isIssuingVC: true);

    // Simulate AWS Liveness check (face scanning)
    // In production, this would call AWS Rekognition SDK
    await Future<void>.delayed(const Duration(seconds: 3));

    // Mark VC as ready (will be generated in generateAndSendProof())
    state = state.copyWith(isIssuingVC: false, hasVC: true);
  }

  /// Generate ZKP from Liveness VC and send to contact
  Future<void> generateAndSendProof({String? holderDid}) async {
    _logger.info(
      'Starting proof generation for contact: $contactId',
      name: _logKey,
    );
    state = state.copyWith(isGeneratingProof: true);

    try {
      // Delegate proof generation to ZkpService
      final zkpService = ref.read(zkpServiceProvider);
      final proofResult = await zkpService.generateProof(holderDid: holderDid);

      if (proofResult == null) {
        throw Exception('Failed to generate proof');
      }

      _logger.info(
        'Proof generated in ${proofResult.generationTimeMs}ms',
        name: _logKey,
      );

      // Send proof to contact via DIDComm
      final chatController = ref.read(
        chatScreenControllerProvider(contactId).notifier,
      );

      await chatController.sendMessageDirect(
        '', // Empty message - only attachment needed for proof
        attachments: [
          chat.Attachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            mediaType: 'application/json',
            format: 'https://affinidi.com/liveness-proof',
            lastModifiedTime: DateTime.now(),
            data: chat.AttachmentData(
              json: jsonEncode({
                'type': 'liveness_proof',
                'proof': proofResult.proof,
                'publicSignals': proofResult.publicSignals,
              }),
            ),
          ),
        ],
      );

      _logger.info('Proof sent to contact successfully', name: _logKey);

      // Save credential to Credentials tab
      await ref
          .read(credentialsScreenControllerProvider.notifier)
          .saveCredential();

      state = state.copyWith(
        isGeneratingProof: false,
        proofSent: true,
        hasIncomingRequest: false,
      );
    } catch (e, st) {
      _logger.error(
        'Failed to generate proof: $e',
        name: _logKey,
        stackTrace: st,
      );
      state = state.copyWith(
        isGeneratingProof: false,
        verificationFailed: true,
        errorMessage: 'Failed to generate proof: $e',
      );
    }
  }

  /// Verify received ZKP proof
  Future<void> verifyProof() async {
    _logger.info(
      'Starting proof verification for contact: $contactId',
      name: _logKey,
    );
    state = state.copyWith(isVerifyingProof: true);

    try {
      // Check if we have received proof data
      if (state.receivedProofData == null) {
        _logger.warning('No proof data found in state', name: _logKey);
        throw Exception('No proof data received');
      }

      // Extract proof and public signals from received data
      final proofData = state.receivedProofData!;
      final proof = proofData['proof'] as String;
      final publicSignals = proofData['publicSignals'] as String;

      _logger.info('Verifying proof (${proof.length} chars)', name: _logKey);

      // Delegate verification to ZkpService
      final zkpService = ref.read(zkpServiceProvider);
      final verificationResult = await zkpService.verifyProof(
        proof: proof,
        publicSignals: publicSignals,
      );

      _logger.info(
        'Verification result: ${verificationResult.isValid}',
        name: _logKey,
      );

      state = state.copyWith(
        isVerifyingProof: false,
        isVerified: verificationResult.isValid,
        verificationFailed: !verificationResult.isValid,
        errorMessage: verificationResult.error,
      );
    } catch (e, st) {
      _logger.error(
        'Failed to verify proof: $e',
        name: _logKey,
        stackTrace: st,
      );
      state = state.copyWith(
        isVerifyingProof: false,
        verificationFailed: true,
        errorMessage: 'Failed to verify proof: $e',
      );
    }
  }

  /// Called when proof is received from contact
  void onProofReceived(Map<String, dynamic> proofData) {
    _logger.info('Proof received from contact: $contactId', name: _logKey);

    // Store the received proof data
    state = state.copyWith(receivedProofData: proofData);

    _logger.info('Proof received', name: _logKey);

    // Verify the proof
    _logger.info('  Triggering automatic verification', name: _logKey);
    verifyProof();
  }
}
