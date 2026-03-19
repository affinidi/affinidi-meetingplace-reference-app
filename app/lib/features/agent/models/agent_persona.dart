import 'package:freezed_annotation/freezed_annotation.dart';

import 'tone_patterns.dart';

part 'agent_persona.freezed.dart';
part 'agent_persona.g.dart';

@freezed
abstract class AgentPersona with _$AgentPersona {
  const factory AgentPersona({
    @Default('') String communicationStyle,
    @Default('medium') String averageMessageLength,
    @Default(false) bool usesEmoji,
    @Default('mixed') String formality,
    @Default([]) List<String> commonPhrases,
    @Default([]) List<String> avoidPhrases,
    TonePatterns? tonePatterns,
    @Default([]) List<String> topicsDiscussed,
    @Default([]) List<String> hardLimits,
  }) = _AgentPersona;

  factory AgentPersona.fromJson(Map<String, dynamic> json) =>
      _$AgentPersonaFromJson(json);
}
