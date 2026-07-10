import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

class PersonalAgentScreenState {
  const PersonalAgentScreenState({
    required this.holderDid,
    required this.isReady,
    required this.isSettingUp,
    required this.errorMessage,
    required this.setupResult,
  });

  const PersonalAgentScreenState.initial()
    : holderDid = null,
      isReady = false,
      isSettingUp = false,
      errorMessage = null,
      setupResult = null;

  final String? holderDid;
  final bool isReady;
  final bool isSettingUp;
  final String? errorMessage;
  final PersonalAgentSetupResult? setupResult;

  PersonalAgentScreenState copyWith({
    String? holderDid,
    bool? isReady,
    bool? isSettingUp,
    String? errorMessage,
    PersonalAgentSetupResult? setupResult,
    bool clearErrorMessage = false,
    bool clearSetupResult = false,
  }) {
    return PersonalAgentScreenState(
      holderDid: holderDid ?? this.holderDid,
      isReady: isReady ?? this.isReady,
      isSettingUp: isSettingUp ?? this.isSettingUp,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      setupResult: clearSetupResult ? null : (setupResult ?? this.setupResult),
    );
  }
}
