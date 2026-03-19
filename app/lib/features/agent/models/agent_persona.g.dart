// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_persona.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgentPersona _$AgentPersonaFromJson(Map<String, dynamic> json) =>
    _AgentPersona(
      communicationStyle: json['communicationStyle'] as String? ?? '',
      averageMessageLength: json['averageMessageLength'] as String? ?? 'medium',
      usesEmoji: json['usesEmoji'] as bool? ?? false,
      formality: json['formality'] as String? ?? 'mixed',
      commonPhrases:
          (json['commonPhrases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      avoidPhrases:
          (json['avoidPhrases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tonePatterns: json['tonePatterns'] == null
          ? null
          : TonePatterns.fromJson(json['tonePatterns'] as Map<String, dynamic>),
      topicsDiscussed:
          (json['topicsDiscussed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hardLimits:
          (json['hardLimits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AgentPersonaToJson(_AgentPersona instance) =>
    <String, dynamic>{
      'communicationStyle': instance.communicationStyle,
      'averageMessageLength': instance.averageMessageLength,
      'usesEmoji': instance.usesEmoji,
      'formality': instance.formality,
      'commonPhrases': instance.commonPhrases,
      'avoidPhrases': instance.avoidPhrases,
      'tonePatterns': instance.tonePatterns,
      'topicsDiscussed': instance.topicsDiscussed,
      'hardLimits': instance.hardLimits,
    };
