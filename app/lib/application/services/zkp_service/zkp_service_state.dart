import 'package:freezed_annotation/freezed_annotation.dart';

part 'zkp_service_state.freezed.dart';

/// Cryptographic output of a successful ZKP generation run.
@Freezed(fromJson: false, toJson: false)
abstract class ZkpProofResult with _$ZkpProofResult {
  const factory ZkpProofResult({
    required String proof,
    required String publicSignals,
    required int generationTimeMs,
  }) = _ZkpProofResult;
}

/// Result of ZKP proof generation.
sealed class ZkpProofGenerationResult {
  const ZkpProofGenerationResult();

  const factory ZkpProofGenerationResult.success(ZkpProofResult result) =
      ZkpProofGenerationSuccess;

  const factory ZkpProofGenerationResult.failure(String error) =
      ZkpProofGenerationFailure;
}

final class ZkpProofGenerationSuccess extends ZkpProofGenerationResult {
  const ZkpProofGenerationSuccess(this.result);

  final ZkpProofResult result;
}

final class ZkpProofGenerationFailure extends ZkpProofGenerationResult {
  const ZkpProofGenerationFailure(this.error);

  final String error;
}

/// Result of ZKP proof verification
@Freezed(fromJson: false, toJson: false)
sealed class ZkpVerificationResult with _$ZkpVerificationResult {
  const ZkpVerificationResult._();

  const factory ZkpVerificationResult.success() = ZkpVerificationSuccess;
  const factory ZkpVerificationResult.failure(String error) =
      ZkpVerificationFailure;

  bool get isValid => switch (this) {
    ZkpVerificationSuccess() => true,
    ZkpVerificationFailure() => false,
  };

  String? get error => switch (this) {
    ZkpVerificationSuccess() => null,
    ZkpVerificationFailure(:final error) => error,
  };
}
