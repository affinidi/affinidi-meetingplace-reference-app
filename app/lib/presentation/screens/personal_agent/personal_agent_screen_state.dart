import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

import '../../../application/services/personal_ai_service/personal_ai_authorization_snapshot.dart';
import '../../../domain/models/contacts/contact.dart';

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
    required this.workContact,
    required this.personalContact,
    required this.workAuthorizationSnapshot,
    required this.personalAuthorizationSnapshot,
    required this.showWorkAuthorization,
    required this.showPersonalAuthorization,
    required this.workContextUploaded,
    required this.personalContextUploaded,
    required this.workContextFileName,
    required this.personalContextFileName,
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
      setupResult = null,
      workContact = null,
      personalContact = null,
      workAuthorizationSnapshot = null,
      personalAuthorizationSnapshot = null,
      showWorkAuthorization = false,
      showPersonalAuthorization = false,
      workContextUploaded = false,
      personalContextUploaded = false,
      workContextFileName = null,
      personalContextFileName = null;

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
  final Contact? workContact;
  final Contact? personalContact;
  final PersonalAiAuthorizationSnapshot? workAuthorizationSnapshot;
  final PersonalAiAuthorizationSnapshot? personalAuthorizationSnapshot;
  final bool showWorkAuthorization;
  final bool showPersonalAuthorization;
  final bool workContextUploaded;
  final bool personalContextUploaded;
  final String? workContextFileName;
  final String? personalContextFileName;

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
    Contact? workContact,
    Contact? personalContact,
    PersonalAiAuthorizationSnapshot? workAuthorizationSnapshot,
    PersonalAiAuthorizationSnapshot? personalAuthorizationSnapshot,
    bool? showWorkAuthorization,
    bool? showPersonalAuthorization,
    bool? workContextUploaded,
    bool? personalContextUploaded,
    String? workContextFileName,
    String? personalContextFileName,
    bool clearErrorMessage = false,
    bool clearContextUploadError = false,
    bool clearSetupResult = false,
    bool clearConnectingLabel = false,
  }) {
    return PersonalAgentScreenState(
      holderDid: holderDid ?? this.holderDid,
      isReady: isReady ?? this.isReady,
      isSettingUp: isSettingUp ?? this.isSettingUp,
      isConnecting: isConnecting ?? this.isConnecting,
      connectingLabel: clearConnectingLabel
          ? null
          : (connectingLabel ?? this.connectingLabel),
      contextProvisioned: contextProvisioned ?? this.contextProvisioned,
      contextUploading: contextUploading ?? this.contextUploading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      contextUploadError: clearContextUploadError
          ? null
          : (contextUploadError ?? this.contextUploadError),
      setupResult: clearSetupResult ? null : (setupResult ?? this.setupResult),
        workContact: workContact ?? this.workContact,
        personalContact: personalContact ?? this.personalContact,
        workAuthorizationSnapshot:
          workAuthorizationSnapshot ?? this.workAuthorizationSnapshot,
        personalAuthorizationSnapshot:
          personalAuthorizationSnapshot ?? this.personalAuthorizationSnapshot,
        showWorkAuthorization:
          showWorkAuthorization ?? this.showWorkAuthorization,
        showPersonalAuthorization:
          showPersonalAuthorization ?? this.showPersonalAuthorization,
      workContextUploaded: workContextUploaded ?? this.workContextUploaded,
      personalContextUploaded:
          personalContextUploaded ?? this.personalContextUploaded,
      workContextFileName: workContextFileName ?? this.workContextFileName,
      personalContextFileName:
          personalContextFileName ?? this.personalContextFileName,
    );
  }
}
