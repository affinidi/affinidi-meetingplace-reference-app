import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

import '../../../application/services/contacts_identities_service/contacts_identities_service.dart';
import '../../../application/services/credential_service/credential_service.dart';
import '../../../application/services/credential_service/credential_service_state.dart';
import '../../../application/services/credential_service/liveness_errors.dart';
import '../../../infrastructure/providers/liveness_check_provider.dart';
import 'chat_screen_controller.dart';
import 'liveness_credential_view_data.dart';
import 'proof_flow_controller.dart';

enum LivenessCheckFlowStep {
  searchingVC,
  vcNotFound,
  generatingVC,
  vcGenerated,
  foundVC,
}

class LivenessCheckScreenState {
  const LivenessCheckScreenState({
    this.currentStep = LivenessCheckFlowStep.searchingVC,
    this.isGenerating = false,
    this.proofIdentityId,
    this.proofIdentityDid,
    this.credential,
  });

  final LivenessCheckFlowStep currentStep;
  final bool isGenerating;
  final String? proofIdentityId;
  final String? proofIdentityDid;
  final LivenessCredentialViewData? credential;

  LivenessCheckScreenState copyWith({
    LivenessCheckFlowStep? currentStep,
    bool? isGenerating,
    String? proofIdentityId,
    String? proofIdentityDid,
    bool clearProofIdentity = false,
    LivenessCredentialViewData? credential,
    bool clearCredential = false,
  }) {
    return LivenessCheckScreenState(
      currentStep: currentStep ?? this.currentStep,
      isGenerating: isGenerating ?? this.isGenerating,
      proofIdentityId: clearProofIdentity
          ? null
          : (proofIdentityId ?? this.proofIdentityId),
      proofIdentityDid: clearProofIdentity
          ? null
          : (proofIdentityDid ?? this.proofIdentityDid),
      credential: clearCredential ? null : (credential ?? this.credential),
    );
  }
}

final livenessCheckScreenControllerProvider = StateNotifierProvider.autoDispose
    .family<LivenessCheckScreenController, LivenessCheckScreenState, String>(
      (ref, contactId) =>
          LivenessCheckScreenController(ref: ref, contactId: contactId),
    );

class LivenessCheckScreenController
    extends StateNotifier<LivenessCheckScreenState> {
  LivenessCheckScreenController({required this._ref, required this._contactId})
    : super(const LivenessCheckScreenState());

  final Ref _ref;
  final String _contactId;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _initProofContext();
  }

  Future<void> _initProofContext() async {
    final identity = await _ref
        .read(contactsIdentitiesServiceProvider)
        .resolveIdentityForContact(_contactId);
    if (!_ref.mounted) return;

    state = state.copyWith(
      proofIdentityId: identity?.id,
      proofIdentityDid: identity?.did,
    );
    await refreshSearchState();
  }

  Future<void> refreshSearchState() async {
    final identityId = state.proofIdentityId;
    if (identityId == null) {
      state = state.copyWith(
        currentStep: LivenessCheckFlowStep.vcNotFound,
        clearCredential: true,
      );
      return;
    }

    await _ref.read(credentialServiceProvider.notifier).ensureInitialized();
    if (!_ref.mounted) return;

    final credentialState = _ref.read(credentialServiceProvider);
    final credential = credentialState.credentialFor(identityId);
    final hasSessionMaterial = credentialState.hasSessionMaterialFor(
      identityId,
    );

    state = state.copyWith(
      credential: credential == null
          ? null
          : LivenessCredentialViewData(
              identityId: credential.identityId,
              issuedToDid: credential.issuedToDid,
              displayIssuer: credential.displayIssuer,
              issuedAt: credential.issuedAt,
            ),
      currentStep: hasSessionMaterial
          ? LivenessCheckFlowStep.foundVC
          : LivenessCheckFlowStep.vcNotFound,
    );
  }

  Future<String?> generateCredential(BuildContext context) async {
    final identityId = state.proofIdentityId;
    final identityDid = state.proofIdentityDid;
    if (identityId == null || identityDid == null || identityDid.isEmpty) {
      return null;
    }

    final interactiveProvider = _ref.read(livenessCheckProvider);
    LivenessEvidence? evidence;
    if (interactiveProvider != null) {
      evidence = await interactiveProvider.collectEvidence(
        context: context,
        holderDid: identityDid,
      );
      if (!_ref.mounted || evidence == null) return null;
    }

    state = state.copyWith(currentStep: LivenessCheckFlowStep.generatingVC);

    try {
      await _ref
          .read(credentialServiceProvider.notifier)
          .issueLivenessCredential(
            identityId: identityId,
            holderDid: identityDid,
            evidence: evidence,
          );
      if (!_ref.mounted) return null;

      final credential = _ref
          .read(credentialServiceProvider)
          .credentialFor(identityId);
      state = state.copyWith(
        currentStep: LivenessCheckFlowStep.vcGenerated,
        credential: credential == null
            ? null
            : LivenessCredentialViewData(
                identityId: credential.identityId,
                issuedToDid: credential.issuedToDid,
                displayIssuer: credential.displayIssuer,
                issuedAt: credential.issuedAt,
              ),
      );
      return null;
    } on LivenessEvidenceThresholdNotMetException catch (error) {
      if (_ref.mounted) {
        state = state.copyWith(currentStep: LivenessCheckFlowStep.vcNotFound);
      }
      return error.toString();
    } catch (error) {
      if (_ref.mounted) {
        state = state.copyWith(currentStep: LivenessCheckFlowStep.vcNotFound);
      }
      return error.toString();
    }
  }

  Future<String?> generateAndSendProof() async {
    state = state.copyWith(isGenerating: true);

    final error = await _ref
        .read(proofFlowControllerProvider(_contactId).notifier)
        .generateAndSendProof();

    if (!_ref.mounted) return error;

    if (error == null) {
      state = state.copyWith(isGenerating: false);
      return null;
    }

    if (error == LivenessCredentialSessionMissingException.message) {
      state = state.copyWith(
        isGenerating: false,
        currentStep: LivenessCheckFlowStep.vcNotFound,
      );
      return error;
    }

    state = state.copyWith(isGenerating: false);
    return error;
  }

  Future<void> pauseHumanZkpRequestFlow() {
    return _ref
        .read(chatScreenControllerProvider(_contactId).notifier)
        .pauseHumanZkpRequestFlow();
  }
}
