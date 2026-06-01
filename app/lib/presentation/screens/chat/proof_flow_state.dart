class ProofFlowState {
  const ProofFlowState({
    this.isVerifyingProof = false,
    this.verificationError,
    this.verifierChallengeNonce,
  });

  final bool isVerifyingProof;
  final String? verificationError;

  /// 32-byte challenge from the peer's liveness check request
  final List<int>? verifierChallengeNonce;

  ProofFlowState copyWith({
    bool? isVerifyingProof,
    String? verificationError,
    List<int>? verifierChallengeNonce,
    bool clearVerificationError = false,
    bool clearVerifierChallengeNonce = false,
  }) {
    return ProofFlowState(
      isVerifyingProof: isVerifyingProof ?? this.isVerifyingProof,
      verificationError: clearVerificationError
          ? null
          : (verificationError ?? this.verificationError),
      verifierChallengeNonce: clearVerifierChallengeNonce
          ? null
          : (verifierChallengeNonce ?? this.verifierChallengeNonce),
    );
  }
}
