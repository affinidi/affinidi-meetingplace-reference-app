import 'package:meeting_place_relationship/meeting_place_relationship.dart';

/// State for liveness check proof flow in chat.
///
/// VC search/issue UI lives in the liveness check screen and credential
/// service; this state covers request/proof messaging and verification only.
class ProofFlowState {
  const ProofFlowState({
    this.hasIncomingRequest = false,
    this.isGeneratingProof = false,
    this.proofSent = false,
    this.receivedProofPayload,
    this.isVerifyingProof = false,
    this.isVerified = false,
    this.verificationFailed = false,
    this.errorMessage,
  });

  final bool hasIncomingRequest;
  final bool isGeneratingProof;
  final bool proofSent;
  final LivenessProofPayload? receivedProofPayload;
  final bool isVerifyingProof;
  final bool isVerified;
  final bool verificationFailed;
  final String? errorMessage;

  ProofFlowState copyWith({
    bool? hasIncomingRequest,
    bool? isGeneratingProof,
    bool? proofSent,
    LivenessProofPayload? receivedProofPayload,
    bool? isVerifyingProof,
    bool? isVerified,
    bool? verificationFailed,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProofFlowState(
      hasIncomingRequest: hasIncomingRequest ?? this.hasIncomingRequest,
      isGeneratingProof: isGeneratingProof ?? this.isGeneratingProof,
      proofSent: proofSent ?? this.proofSent,
      receivedProofPayload: receivedProofPayload ?? this.receivedProofPayload,
      isVerifyingProof: isVerifyingProof ?? this.isVerifyingProof,
      isVerified: isVerified ?? this.isVerified,
      verificationFailed: verificationFailed ?? this.verificationFailed,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
