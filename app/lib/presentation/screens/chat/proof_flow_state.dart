class ProofFlowState {
  const ProofFlowState({this.isVerifyingProof = false, this.verificationError});

  final bool isVerifyingProof;
  final String? verificationError;

  ProofFlowState copyWith({
    bool? isVerifyingProof,
    String? verificationError,
    bool clearVerificationError = false,
  }) {
    return ProofFlowState(
      isVerifyingProof: isVerifyingProof ?? this.isVerifyingProof,
      verificationError: clearVerificationError
          ? null
          : (verificationError ?? this.verificationError),
    );
  }
}
