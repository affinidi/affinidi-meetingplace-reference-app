// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deployment_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeploymentResult _$DeploymentResultFromJson(Map<String, dynamic> json) =>
    _DeploymentResult(
      vcId: json['vcId'] as String,
      agentDid: json['agentDid'] as String,
      systemPromptHash: json['systemPromptHash'] as String,
      trainedOnMessages: (json['trainedOnMessages'] as num).toInt(),
    );

Map<String, dynamic> _$DeploymentResultToJson(_DeploymentResult instance) =>
    <String, dynamic>{
      'vcId': instance.vcId,
      'agentDid': instance.agentDid,
      'systemPromptHash': instance.systemPromptHash,
      'trainedOnMessages': instance.trainedOnMessages,
    };
