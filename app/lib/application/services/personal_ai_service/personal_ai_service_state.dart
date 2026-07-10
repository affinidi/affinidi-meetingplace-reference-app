import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

enum PersonalAiSetupStatus { notConfigured, settingUp, ready, failed }

class PersonalAiServiceState {
  const PersonalAiServiceState({
    required this.status,
    required this.showSetupPrompt,
    required this.promptDismissed,
    this.errorMessage,
    this.setupResult,
  });

  const PersonalAiServiceState.initial()
    : status = PersonalAiSetupStatus.notConfigured,
      showSetupPrompt = false,
      promptDismissed = false,
      errorMessage = null,
      setupResult = null;

  final PersonalAiSetupStatus status;
  final bool showSetupPrompt;
  final bool promptDismissed;
  final String? errorMessage;
  final PersonalAgentSetupResult? setupResult;

  bool get isReady => status == PersonalAiSetupStatus.ready;
  bool get isSettingUp => status == PersonalAiSetupStatus.settingUp;

  PersonalAiServiceState copyWith({
    PersonalAiSetupStatus? status,
    bool? showSetupPrompt,
    bool? promptDismissed,
    String? errorMessage,
    PersonalAgentSetupResult? setupResult,
    bool clearErrorMessage = false,
    bool clearSetupResult = false,
  }) {
    return PersonalAiServiceState(
      status: status ?? this.status,
      showSetupPrompt: showSetupPrompt ?? this.showSetupPrompt,
      promptDismissed: promptDismissed ?? this.promptDismissed,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      setupResult: clearSetupResult ? null : (setupResult ?? this.setupResult),
    );
  }
}
