import 'package:freezed_annotation/freezed_annotation.dart';

part 'proof_flow_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ProofFlowState with _$ProofFlowState {
  const factory ProofFlowState({
    @Default(false) bool isVerifyingProof,
    String? verificationError,

    /// 32-byte challenge from the peer's liveness check request
    List<int>? verifierChallengeNonce,
  }) = _ProofFlowState;
}
