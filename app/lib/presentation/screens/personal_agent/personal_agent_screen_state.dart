import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

class PersonalAgentScreenState {
  const PersonalAgentScreenState({
    required this.holderDid,
    required this.isReady,
    required this.isSettingUp,
    required this.isConnecting,
    required this.connectingLabel,
    required this.contextProvisioned,
    required this.contextUploading,
    required this.errorMessage,
    required this.setupResult,
    this.contextUploadError,
  });

  const PersonalAgentScreenState.initial()
    : holderDid = null,
      isReady = false,
      isSettingUp = false,
      isConnecting = false,
      connectingLabel = null,
      contextProvisioned = false,
      contextUploading = false,
      errorMessage = null,
      contextUploadError = null,
      setupResult = null;

  final String? holderDid;
  final bool isReady;
  final bool isSettingUp;
  final bool isConnecting;
  final String? connectingLabel;

  /// Whether the user has uploaded their context file.
  final bool contextProvisioned;

  /// Whether a context upload is in progress.
  final bool contextUploading;

  final String? errorMessage;
  final String? contextUploadError;
  final PersonalAgentSetupResult? setupResult;

  PersonalAgentScreenState copyWith({
    String? holderDid,
    bool? isReady,
    bool? isSettingUp,
    bool? isConnecting,
    String? connectingLabel,
    bool? contextProvisioned,
    bool? contextUploading,
    String? errorMessage,
    String? contextUploadError,
    PersonalAgentSetupResult? setupResult,
    bool clearErrorMessage = false,
    bool clearContextUploadError = false,
    bool clearSetupResult = false,
  }) {
    return PersonalAgentScreenState(
      holderDid: holderDid ?? this.holderDid,
      isReady: isReady ?? this.isReady,
      isSettingUp: isSettingUp ?? this.isSettingUp,
      isConnecting: isConnecting ?? this.isConnecting,
      connectingLabel: connectingLabel ?? this.connectingLabel,
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
