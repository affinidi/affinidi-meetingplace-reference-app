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
      conversationsObserved: (json['conversationsObserved'] as num).toInt(),
      whatsMissing:
          (json['whatsMissing'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
  'conversationsObserved': instance.conversationsObserved,
  'whatsMissing': instance.whatsMissing,
  'lastAnalysedAt': instance.lastAnalysedAt?.toIso8601String(),
  'persona': instance.persona,
};
