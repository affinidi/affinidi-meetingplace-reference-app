import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show LivenessProofPayload;

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/zkp_flow_service/zkp_flow_service.dart';
import '../../../domain/models/contacts/contact_status.dart';
import 'chat_screen_controller.dart';
import 'proof_flow_state.dart';

final proofFlowControllerProvider = StateNotifierProvider.autoDispose
    .family<ProofFlowController, ProofFlowState, String>((ref, contactId) {
      return ProofFlowController(ref: ref, contactId: contactId);
    });

class ProofFlowController extends StateNotifier<ProofFlowState> {
  ProofFlowController({required this.ref, required this.contactId})
    : _zkpFlowService = ZkpFlowService(ref: ref, contactId: contactId),
      super(const ProofFlowState());

  final Ref ref;
  final String contactId;
  final ZkpFlowService _zkpFlowService;

  static bool watchIsZkpChannelReady(WidgetRef ref, String contactId) {
    final contact = ref.watch(
      contactsServiceProvider.select(
        (state) => state.getContactById(contactId),
      ),
    );
    if (contact == null) return false;

    // ZKP is only for individual chats
    if (contact.isGroup) return false;

    if (!contact.status.isEstablished) return false;

    return ref.watch(
      chatScreenControllerProvider(contactId).select(
        (state) =>
            state.isInitialized &&
            !(state.capabilities?.supports(chat.ChatFeature.messageEdit) ??
                false),
      ),
    );
  }

  bool readIsZkpChannelReady() {
    return _zkpFlowService.readIsZkpChannelReady();
  }

  void setVerifierChallengeNonce(List<int> challengeNonce) {
    state = state.copyWith(verifierChallengeNonce: challengeNonce);
  }

  Future<bool> requestLivenessCheck() async {
    return _zkpFlowService.requestLivenessCheck();
  }

  void resetSession() {
    state = const ProofFlowState();
  }

  void clearVerificationError() {
    state = state.copyWith(isVerifyingProof: false, verificationError: null);
  }

  Future<String?> generateAndSendProof() async {
    final result = await _zkpFlowService.generateAndSendProof(
      challengeNonce: state.verifierChallengeNonce,
    );

    if (mounted && result.resolvedChallengeNonce != null) {
      state = state.copyWith(
        verifierChallengeNonce: result.resolvedChallengeNonce,
      );
    }

    return result.error;
  }

  Future<bool> onProofReceived(LivenessProofPayload payload) async {
    return _verifyProof(payload);
  }

  Future<bool> _verifyProof(LivenessProofPayload payload) async {
    if (!mounted) return false;
    state = state.copyWith(isVerifyingProof: true, verificationError: null);

    final verification = await _zkpFlowService.verifyProof(payload);

    if (mounted) {
      state = state.copyWith(
        isVerifyingProof: false,
        verificationError: verification.isValid ? null : verification.error,
      );
    }
    return verification.isValid;
  }
}
