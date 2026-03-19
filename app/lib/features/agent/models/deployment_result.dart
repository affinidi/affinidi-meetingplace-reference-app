import 'package:freezed_annotation/freezed_annotation.dart';

part 'deployment_result.freezed.dart';
part 'deployment_result.g.dart';

@freezed
abstract class DeploymentResult with _$DeploymentResult {
  const factory DeploymentResult({
    required String vcId,
    required String agentDid,
    required String systemPromptHash,
    required int trainedOnMessages,
  }) = _DeploymentResult;

  factory DeploymentResult.fromJson(Map<String, dynamic> json) =>
      _$DeploymentResultFromJson(json);
}
