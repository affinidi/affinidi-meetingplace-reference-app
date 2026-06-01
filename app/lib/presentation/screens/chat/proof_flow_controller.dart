import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
  show
    LivenessProofPayload,
    LivenessZkpAttachmentParser,
    LivenessZkpDIDCommAttachmentBuilder;

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/zkp_service/zkp_service.dart';
import '../../../application/services/zkp_service/zkp_service_state.dart';
import '../../../domain/models/zkp/zkp_challenge_nonce.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'chat_screen_controller.dart';
import 'proof_flow_state.dart';

bool isZkpChannelReady(Ref ref, String contactId) {
  final contact = ref.watch(
    contactsServiceProvider.select((state) => state.getContactById(contactId)),
  );
  if (contact == null) return false;

  final isEstablishedContact =
      contact.status == ContactStatus.active ||
      contact.status == ContactStatus.approved;
  if (!isEstablishedContact) return false;

  return ref.watch(
    chatScreenControllerProvider(
      contactId,
    ).select((state) => state.isInitialized),
  );
}

bool readIsZkpChannelReady(Ref ref, String contactId) {
  final contact = ref.read(contactsServiceProvider).getContactById(contactId);
  if (contact == null) return false;

  final isEstablishedContact =
      contact.status == ContactStatus.active ||
      contact.status == ContactStatus.approved;
  if (!isEstablishedContact) return false;

  return ref.read(chatScreenControllerProvider(contactId)).isInitialized;
}

final zkpChannelReadyProvider = Provider.autoDispose.family<bool, String>(
  isZkpChannelReady,
);

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

  void setVerifierChallengeNonce(List<int> challengeNonce) {
    state = state.copyWith(verifierChallengeNonce: challengeNonce);
  }

  Future<bool> requestLivenessCheck() async {
    if (!readIsZkpChannelReady(ref, contactId)) {
      _logger.warning(
        'ZKP request blocked: connection not established '
        'for contact $contactId',
        name: _logKey,
      );
      return false;
    }

    final chatController = ref.read(
      chatScreenControllerProvider(contactId).notifier,
    );

    final challengeNonce = generateZkpChallengeNonce();
    final attachments =
        LivenessZkpDIDCommAttachmentBuilder.buildLivenessCheckRequest(
          challengeNonceHex: zkpChallengeNonceToHex(challengeNonce),
        );

    try {
      await chatController.sendMessageDirect(
        '',
        attachments: List<chat.Attachment>.from(attachments),
      );
      return true;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to send liveness check request',
        name: _logKey,
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void resetSession() {
    state = const ProofFlowState();
  }

  void clearVerificationError() {
    state = state.copyWith(
      isVerifyingProof: false,
      clearVerificationError: true,
    );
  }

  Future<String?> generateAndSendProof() async {
    final identity = await ref
        .read(contactsServiceProvider.notifier)
        .resolveIdentityForContact(contactId);
    if (identity == null || identity.did.isEmpty) {
      return 'No identity is linked to this connection.';
    }

    _logger.info(
      'Starting proof generation for contact: $contactId',
      name: _logKey,
    );

    var challengeNonce = state.verifierChallengeNonce;
    challengeNonce ??= _findVerifierChallengeNonceFromChatHistory();
    if (challengeNonce != null && mounted) {
      state = state.copyWith(verifierChallengeNonce: challengeNonce);
    }

    if (challengeNonce == null ||
        challengeNonce.length != zkpChallengeNonceByteLength) {
      return 'No liveness challenge from verifier. '
          'Ask them to send a new request.';
    }

    final generation = await ref.read(zkpServiceProvider).generateProof(
          identityId: identity.id,
          challengeNonce: challengeNonce,
        );

    switch (generation) {
      case ZkpProofGenerationFailure(:final error):
        _logger.error('Failed to generate proof: $error', name: _logKey);
        return error;
      case ZkpProofGenerationSuccess(:final result):
        _logger.info(
          'Proof generated in ${result.generationTimeMs}ms',
          name: _logKey,
        );

        final attachments =
            LivenessZkpDIDCommAttachmentBuilder.buildLivenessProof(
              payload: LivenessProofPayload(
                proof: result.proof,
                publicSignals: result.publicSignals,
              ),
            );

        await ref
            .read(chatScreenControllerProvider(contactId).notifier)
            .sendMessageDirect(
              '',
              attachments: List<chat.Attachment>.from(attachments),
            );

        _logger.info('Proof sent to contact successfully', name: _logKey);
        return null;
    }
  }

  List<int>? _findVerifierChallengeNonceFromChatHistory() {
    final messages = ref.read(chatScreenControllerProvider(contactId)).messages;

    for (final item in messages.reversed) {
      if (item is! chat.Message || item.isFromMe) continue;

      final payload = LivenessZkpAttachmentParser.tryParseRequestIn(
        item.attachments,
      );
      if (payload == null) continue;

      final challengeNonce = payload.challengeNonceBytes;
      if (challengeNonce.length != zkpChallengeNonceByteLength) continue;

      _logger.info(
        'Recovered verifier challenge nonce from chat history',
        name: _logKey,
      );
      return challengeNonce;
    }

    return null;
  }

  Future<bool> onProofReceived(LivenessProofPayload payload) async {
    _logger.info('Proof received from contact: $contactId', name: _logKey);
    return _verifyProof(payload);
  }

  Future<bool> _verifyProof(LivenessProofPayload payload) async {
    _logger.info(
      'Starting proof verification for contact: $contactId',
      name: _logKey,
    );
    if (!mounted) return false;
    state = state.copyWith(
      isVerifyingProof: true,
      clearVerificationError: true,
    );

    final verification = await ref
        .read(zkpServiceProvider)
        .verifyProof(
          proof: payload.proof,
          publicSignals: payload.publicSignals,
        );

    _logger.info('Verification result: ${verification.isValid}', name: _logKey);

    if (mounted) {
      state = state.copyWith(
        isVerifyingProof: false,
        verificationError: verification.isValid ? null : verification.error,
      );
    }
    return verification.isValid;
  }
}
