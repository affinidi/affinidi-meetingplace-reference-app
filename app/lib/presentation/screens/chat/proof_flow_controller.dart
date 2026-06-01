import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_relationship/meeting_place_relationship.dart'
    show LivenessProofPayload, LivenessZkpDIDCommAttachmentBuilder;

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/zkp_service/zkp_service.dart';
import '../../../application/services/zkp_service/zkp_service_state.dart';
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

  Future<bool> requestLivenessCheck() async {
    if (!readIsZkpChannelReady(ref, contactId)) {
      _logger.warning(
        'ZKP request blocked: connection not established for contact $contactId',
        name: _logKey,
      );
      return false;
    }

    final chatController = ref.read(
      chatScreenControllerProvider(contactId).notifier,
    );

    final attachments =
        LivenessZkpDIDCommAttachmentBuilder.buildLivenessCheckRequest();

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

    final generation = await ref
        .read(zkpServiceProvider)
        .generateProof(identityId: identity.id);

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

  Future<bool> onProofReceived(LivenessProofPayload payload) async {
    _logger.info('Proof received from contact: $contactId', name: _logKey);
    return _verifyProof(payload);
  }

  Future<bool> _verifyProof(LivenessProofPayload payload) async {
    _logger.info(
      'Starting proof verification for contact: $contactId',
      name: _logKey,
    );
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

    state = state.copyWith(
      isVerifyingProof: false,
      verificationError: verification.isValid ? null : verification.error,
    );
    return verification.isValid;
  }
}
