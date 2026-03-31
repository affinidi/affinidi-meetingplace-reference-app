import 'package:freezed_annotation/freezed_annotation.dart';

import 'agent_persona.dart';

part 'agent_readiness_state.freezed.dart';
part 'agent_readiness_state.g.dart';

@freezed
abstract class AgentReadinessState with _$AgentReadinessState {
  const factory AgentReadinessState({
    required int scorePercent,
    required String statusLabel,
    required bool isReady,
    required int messagesObserved,
    @Default(false) bool isDeployed,
    @Default(0) int conversationsObserved,
    @Default([]) List<String> whatsMissing,
    @Default(0) int feedbackUpCount,
    @Default(0) int feedbackDownCount,
    @Default(false) bool needsRedeploy,
    @Default(false) bool suggestRedeploy,
    DateTime? lastAnalysedAt,
    AgentPersona? persona,
  }) = _AgentReadinessState;

  factory AgentReadinessState.initial() => const AgentReadinessState(
    scorePercent: 0,
    statusLabel: 'Not started',
    isReady: false,
    messagesObserved: 0,
    conversationsObserved: 0,
  );

  factory AgentReadinessState.fromJson(Map<String, dynamic> json) =>
      _$AgentReadinessStateFromJson(json);
}
