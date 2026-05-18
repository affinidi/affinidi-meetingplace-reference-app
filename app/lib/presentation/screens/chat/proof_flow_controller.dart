import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/zkp_service/zkp_service.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'chat_screen_controller.dart';
import 'proof_flow_state.dart';

final proofFlowControllerProvider = StateNotifierProvider.autoDispose
    .family<ProofFlowController, ProofFlowState, String>((ref, contactId) {
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

    final attachments = LivenessZkpAttachmentBuilder.buildLivenessCheckRequest(
      attachmentId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await chatController.sendMessageDirect(
      '',
      attachments: List<chat.Attachment>.from(attachments),
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

  /// Clears transient UI state when entering or leaving this chat.
  void resetSession() {
    state = const ProofFlowState();
  }

  /// Clear verification failure state after dismissing result banner.
  void clearVerificationFailure() {
    state = state.copyWith(
      verificationFailed: false,
      isVerifyingProof: false,
      clearErrorMessage: true,
    );
  }

  /// Generate ZKP from Liveness VC and send to contact
  Future<void> generateAndSendProof() async {
    final identity = await ref
        .read(contactsServiceProvider.notifier)
        .resolveIdentityForContact(contactId);
    if (identity == null || identity.did.isEmpty) {
      throw Exception(
        'No identity is linked to this connection. '
        'Open this chat with the identity you used to connect.',
      );
    }

    _logger.info(
      'Starting proof generation for contact: $contactId',
      name: _logKey,
    );
    state = state.copyWith(isGeneratingProof: true);

    try {
      final zkpService = ref.read(zkpServiceProvider);
      final proofResult = await zkpService.generateProof(
        identityId: identity.id,
        holderDid: identity.did,
      );

      if (proofResult == null) {
        throw Exception('Failed to generate proof');
      }

      _logger.info(
        'Proof generated in ${proofResult.generationTimeMs}ms',
        name: _logKey,
      );

      final chatController = ref.read(
        chatScreenControllerProvider(contactId).notifier,
      );

      final attachments = LivenessZkpAttachmentBuilder.buildLivenessProof(
        payload: LivenessProofPayload(
          proof: proofResult.proof,
          publicSignals: proofResult.publicSignals,
        ),
        attachmentId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await chatController.sendMessageDirect(
        '',
        attachments: List<chat.Attachment>.from(attachments),
      );

      _logger.info('Proof sent to contact successfully', name: _logKey);

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
      final payload = state.receivedProofPayload;
      if (payload == null) {
        _logger.warning('No proof data found in state', name: _logKey);
        throw Exception('No proof data received');
      }

      _logger.info(
        'Verifying proof (${payload.proof.length} chars)',
        name: _logKey,
      );

      final zkpService = ref.read(zkpServiceProvider);
      final verificationResult = await zkpService.verifyProof(
        proof: payload.proof,
        publicSignals: payload.publicSignals,
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
  void onProofReceived(LivenessProofPayload payload) {
    _logger.info('Proof received from contact: $contactId', name: _logKey);

    state = state.copyWith(receivedProofPayload: payload);

    _logger.info('  Triggering automatic verification', name: _logKey);
    verifyProof();
  }
}
