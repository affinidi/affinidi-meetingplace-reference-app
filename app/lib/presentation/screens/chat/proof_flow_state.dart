/// State for liveness check proof flow
class ProofFlowState {
  const ProofFlowState({
    this.hasIncomingRequest = false,
    this.isCheckingVC = false,
    this.hasVC = false,
    this.isIssuingVC = false,
    this.isGeneratingProof = false,
    this.proofSent = false,
    this.receivedProofData,
    this.isVerifyingProof = false,
    this.isVerified = false,
    this.verificationFailed = false,
    this.errorMessage,
  });

  final bool hasIncomingRequest;
  final bool isCheckingVC;
  final bool hasVC;
  final bool isIssuingVC;
  final bool isGeneratingProof;
  final bool proofSent;
  final Map<String, dynamic>? receivedProofData;
  final bool isVerifyingProof;
  final bool isVerified;
  final bool verificationFailed;
  final String? errorMessage;

  ProofFlowState copyWith({
    bool? hasIncomingRequest,
    bool? isCheckingVC,
    bool? hasVC,
    bool? isIssuingVC,
    bool? isGeneratingProof,
    bool? proofSent,
    Map<String, dynamic>? receivedProofData,
    bool? isVerifyingProof,
    bool? isVerified,
    bool? verificationFailed,
    String? errorMessage,
  }) {
    return ProofFlowState(
      hasIncomingRequest: hasIncomingRequest ?? this.hasIncomingRequest,
      isCheckingVC: isCheckingVC ?? this.isCheckingVC,
      hasVC: hasVC ?? this.hasVC,
      isIssuingVC: isIssuingVC ?? this.isIssuingVC,
      isGeneratingProof: isGeneratingProof ?? this.isGeneratingProof,
      proofSent: proofSent ?? this.proofSent,
      receivedProofData: receivedProofData ?? this.receivedProofData,
      isVerifyingProof: isVerifyingProof ?? this.isVerifyingProof,
      isVerified: isVerified ?? this.isVerified,
      verificationFailed: verificationFailed ?? this.verificationFailed,
      errorMessage: errorMessage,
    );
  }
}
