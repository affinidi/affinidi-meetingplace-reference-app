import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

enum PersonalAiSetupStatus { notConfigured, settingUp, ready, failed }

class PersonalAiServiceState {
  const PersonalAiServiceState({
    required this.status,
    required this.showSetupPrompt,
    required this.promptDismissed,
    required this.contextProvisioned,
    required this.contextUploading,
    this.errorMessage,
    this.contextUploadError,
    this.setupResult,
  });

  const PersonalAiServiceState.initial()
    : status = PersonalAiSetupStatus.notConfigured,
      showSetupPrompt = false,
      promptDismissed = false,
      contextProvisioned = false,
      contextUploading = false,
      errorMessage = null,
      contextUploadError = null,
      setupResult = null;

  final PersonalAiSetupStatus status;
  final bool showSetupPrompt;
  final bool promptDismissed;

  /// Whether the user has uploaded their context file to the agent's memory.
  final bool contextProvisioned;

  /// Whether a context upload is currently in progress.
  final bool contextUploading;

  final String? errorMessage;

  /// Error from the most recent context upload attempt.
  final String? contextUploadError;

  final PersonalAgentSetupResult? setupResult;

  bool get isReady => status == PersonalAiSetupStatus.ready;
  bool get isSettingUp => status == PersonalAiSetupStatus.settingUp;

  PersonalAiServiceState copyWith({
    PersonalAiSetupStatus? status,
    bool? showSetupPrompt,
    bool? promptDismissed,
    bool? contextProvisioned,
    bool? contextUploading,
    String? errorMessage,
    String? contextUploadError,
    PersonalAgentSetupResult? setupResult,
    bool clearErrorMessage = false,
    bool clearContextUploadError = false,
    bool clearSetupResult = false,
  }) {
    return PersonalAiServiceState(
      status: status ?? this.status,
      showSetupPrompt: showSetupPrompt ?? this.showSetupPrompt,
      promptDismissed: promptDismissed ?? this.promptDismissed,
      contextProvisioned: contextProvisioned ?? this.contextProvisioned,
      contextUploading: contextUploading ?? this.contextUploading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      contextUploadError: clearContextUploadError
          ? null
          : (contextUploadError ?? this.contextUploadError),
      setupResult: clearSetupResult ? null : (setupResult ?? this.setupResult),
    );
  }
}
