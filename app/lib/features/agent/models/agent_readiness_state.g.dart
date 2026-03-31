// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_readiness_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgentReadinessState _$AgentReadinessStateFromJson(Map<String, dynamic> json) =>
    _AgentReadinessState(
      scorePercent: (json['scorePercent'] as num).toInt(),
      statusLabel: json['statusLabel'] as String,
      isReady: json['isReady'] as bool,
      messagesObserved: (json['messagesObserved'] as num).toInt(),
      isDeployed: json['isDeployed'] as bool? ?? false,
      conversationsObserved:
          (json['conversationsObserved'] as num?)?.toInt() ?? 0,
      whatsMissing:
          (json['whatsMissing'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      feedbackUpCount: (json['feedbackUpCount'] as num?)?.toInt() ?? 0,
      feedbackDownCount: (json['feedbackDownCount'] as num?)?.toInt() ?? 0,
      needsRedeploy: json['needsRedeploy'] as bool? ?? false,
      suggestRedeploy: json['suggestRedeploy'] as bool? ?? false,
      lastAnalysedAt: json['lastAnalysedAt'] == null
          ? null
          : DateTime.parse(json['lastAnalysedAt'] as String),
      persona: json['persona'] == null
          ? null
          : AgentPersona.fromJson(json['persona'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgentReadinessStateToJson(
  _AgentReadinessState instance,
) => <String, dynamic>{
  'scorePercent': instance.scorePercent,
  'statusLabel': instance.statusLabel,
  'isReady': instance.isReady,
  'messagesObserved': instance.messagesObserved,
  'isDeployed': instance.isDeployed,
  'conversationsObserved': instance.conversationsObserved,
  'whatsMissing': instance.whatsMissing,
  'feedbackUpCount': instance.feedbackUpCount,
  'feedbackDownCount': instance.feedbackDownCount,
  'needsRedeploy': instance.needsRedeploy,
  'suggestRedeploy': instance.suggestRedeploy,
  'lastAnalysedAt': instance.lastAnalysedAt?.toIso8601String(),
  'persona': instance.persona,
};
