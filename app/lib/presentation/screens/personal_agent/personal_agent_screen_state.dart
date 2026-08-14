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
    required this.workAuthorizationSnapshot,
    required this.showWorkAuthorization,
    required this.workContextUploaded,
    required this.workContextFileName,
    required this.workContextKilled,
    this.contextUploadError,
    this.autoResponseEnabled = false,
    this.autoResponseLoading = false,
    this.autoResponseAvailable = false,
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
      workAuthorizationSnapshot = null,
      showWorkAuthorization = false,
      workContextUploaded = false,
      workContextFileName = null,
      workContextKilled = false,
      autoResponseEnabled = false,
      autoResponseLoading = false,
      autoResponseAvailable = false;

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
  final PersonalAiAuthorizationSnapshot? workAuthorizationSnapshot;
  final bool showWorkAuthorization;
  final bool workContextUploaded;
  final String? workContextFileName;
  final bool workContextKilled;
  final bool autoResponseEnabled;
  final bool autoResponseLoading;
  final bool autoResponseAvailable;

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
    PersonalAiAuthorizationSnapshot? workAuthorizationSnapshot,
    bool? showWorkAuthorization,
    bool? workContextUploaded,
    String? workContextFileName,
    bool? workContextKilled,
    bool? autoResponseEnabled,
    bool? autoResponseLoading,
    bool? autoResponseAvailable,
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
      workAuthorizationSnapshot:
          workAuthorizationSnapshot ?? this.workAuthorizationSnapshot,
      showWorkAuthorization:
          showWorkAuthorization ?? this.showWorkAuthorization,
      workContextUploaded: workContextUploaded ?? this.workContextUploaded,
      workContextFileName: workContextFileName ?? this.workContextFileName,
      workContextKilled: workContextKilled ?? this.workContextKilled,
      autoResponseEnabled: autoResponseEnabled ?? this.autoResponseEnabled,
      autoResponseLoading: autoResponseLoading ?? this.autoResponseLoading,
      autoResponseAvailable:
          autoResponseAvailable ?? this.autoResponseAvailable,
    );
  }
}
