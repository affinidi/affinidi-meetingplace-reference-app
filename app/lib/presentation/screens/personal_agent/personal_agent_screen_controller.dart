import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_service.dart';
import '../../../infrastructure/media/file_picker/file_picker_platform_provider.dart';
import 'personal_agent_screen_state.dart';

class RoutingContextUploadOutcome {
  const RoutingContextUploadOutcome._({
    required this.uploaded,
    this.fileName,
    this.target,
  });

  const RoutingContextUploadOutcome.skipped()
    : this._(uploaded: false, fileName: null, target: null);

  const RoutingContextUploadOutcome.uploaded({
    required String fileName,
    required AgentContext target,
  }) : this._(uploaded: true, fileName: fileName, target: target);

  final bool uploaded;
  final String? fileName;
  final AgentContext? target;
}

class PickedTextFile {
  const PickedTextFile({required this.fileName, required this.content});

  final String fileName;
  final String content;
}

final personalAgentScreenControllerProvider =
    StateNotifierProvider<
      PersonalAgentScreenController,
      PersonalAgentScreenState
    >((ref) {
      final controller = PersonalAgentScreenController(ref);

      ref.listen(
        identitiesServiceProvider.currentIdentityOrPrimary,
        (_, _) => controller.syncFromDependencies(),
        fireImmediately: true,
      );

      ref.listen(
        personalAiServiceProvider,
        (_, _) => controller.syncFromDependencies(),
        fireImmediately: true,
      );

      return controller;
    });

class PersonalAgentScreenController
    extends StateNotifier<PersonalAgentScreenState> {
  PersonalAgentScreenController(this._ref)
    : super(const PersonalAgentScreenState.initial());

  final Ref _ref;

  void syncFromDependencies() {
    _ref
        .read(personalAiServiceProvider.notifier)
        .refreshPersonalAiContactSync();

    final identity = _ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    final personalAiState = _ref.read(personalAiServiceProvider);

    state = state.copyWith(
      holderDid: identity?.did,
      isReady: personalAiState.isReady,
      isSettingUp: personalAiState.isSettingUp,
      contextProvisioned: personalAiState.contextProvisioned,
      contextUploading: personalAiState.contextUploading,
      errorMessage: personalAiState.errorMessage,
      contextUploadError: personalAiState.contextUploadError,
      setupResult: personalAiState.setupResult,
      clearErrorMessage: personalAiState.errorMessage == null,
      clearContextUploadError: personalAiState.contextUploadError == null,
      clearSetupResult: personalAiState.setupResult == null,
    );
  }

  Future<void> uploadContext(String content) {
    final setupId = state.setupResult?.setupId ?? '';
    return _ref
        .read(personalAiServiceProvider.notifier)
        .uploadContext(setupId: setupId, content: content);
  }

  Future<PickedTextFile?> pickContextSetupFile() => _pickTextFile();

  Future<RoutingContextUploadOutcome> uploadRoutingContext(
    AgentContext target,
  ) async {
    final pickedFile = await _pickTextFile();
    if (pickedFile == null) {
      return const RoutingContextUploadOutcome.skipped();
    }

    final identity = _ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    final holderDid = (identity?.did ?? state.holderDid ?? '').trim();
    if (holderDid.isEmpty) {
      return const RoutingContextUploadOutcome.skipped();
    }

    final contextName = _setupContextNameForTarget(target);
    final displayName = _agentDisplayNameForTarget(target);

    // Get the setup result for this specific context (not just the global one)
    final personalAiState = _ref.read(personalAiServiceProvider);
    final contextSpecificSetup = personalAiState.getSetupResultForContext(
      contextName,
    );

    final existingSetup = contextSpecificSetup ?? state.setupResult;
    final canReuseExistingSetup =
        existingSetup != null &&
        state.isReady &&
        _matchesTargetContext(existingSetup, contextName) &&
        (existingSetup.setupId?.trim().isNotEmpty ?? false);

    state = state.copyWith(
      isConnecting: true,
      connectingLabel: displayName,
      clearContextUploadError: true,
    );

    try {
      if (!canReuseExistingSetup) {
        await _ref
            .read(personalAiServiceProvider.notifier)
            .setupPersonalAi(
              holderDid: holderDid,
              contextName: contextName,
              agentDisplayName: displayName,
            );
        syncFromDependencies();

        // After setup, get the context-specific result
        final updatedPersonalAiState = _ref.read(personalAiServiceProvider);
        var setupResult =
            updatedPersonalAiState.getSetupResultForContext(contextName) ??
            updatedPersonalAiState.setupResult;
        final connectionKnownReady =
            state.isReady &&
            setupResult != null &&
            _matchesTargetContext(setupResult, contextName);

        if (!connectionKnownReady &&
            (setupResult == null || !_isConnectionReady(setupResult))) {
          setupResult = await _ref
              .read(personalAiServiceProvider.notifier)
              .waitUntilConnected(
                holderDid: holderDid,
                contextName: contextName,
                agentDisplayName: displayName,
              );
          syncFromDependencies();
        }
      }

      // Get the context-specific setup result for upload
      final updatedPersonalAiState = _ref.read(personalAiServiceProvider);
      final setupResult =
          updatedPersonalAiState.getSetupResultForContext(contextName) ??
          updatedPersonalAiState.setupResult;
      final connected =
          setupResult != null &&
          _matchesTargetContext(setupResult, contextName) &&
          (_isConnectionReady(setupResult) || state.isReady);
      if (!connected) {
        state = state.copyWith(
          contextUploadError:
              '$displayName is still connecting. Upload is available once the connection is active.',
          isConnecting: false,
          connectingLabel: null,
        );
        return const RoutingContextUploadOutcome.skipped();
      }

      final setupId = setupResult.setupId?.trim() ?? '';
      if (setupId.isEmpty) {
        state = state.copyWith(isConnecting: false, connectingLabel: null);
        return const RoutingContextUploadOutcome.skipped();
      }

      await _ref
          .read(personalAiServiceProvider.notifier)
          .uploadContext(
            setupId: setupId,
            content: pickedFile.content,
            setupContextName: contextName,
            agentDisplayName: displayName,
          );
      syncFromDependencies();

      if (state.contextUploadError != null) {
        state = state.copyWith(isConnecting: false, connectingLabel: null);
        return const RoutingContextUploadOutcome.skipped();
      }

      await _ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .markContextUploaded(context: target, fileName: pickedFile.fileName);

      await _ref
          .read(personalAiServiceProvider.notifier)
          .refreshPersonalAiContactSync();
      await _ref.read(contactsServiceProvider.notifier).fetchContacts();

      state = state.copyWith(isConnecting: false, connectingLabel: null);
      return RoutingContextUploadOutcome.uploaded(
        fileName: pickedFile.fileName,
        target: target,
      );
    } catch (_) {
      state = state.copyWith(isConnecting: false, connectingLabel: null);
      rethrow;
    }
  }

  bool _isConnectionReady(PersonalAgentSetupResult setupResult) {
    final setupStatus = (setupResult.setupStatus ?? '').trim().toLowerCase();
    if (setupStatus == 'inaugurated' || setupStatus == 'ready') {
      return true;
    }
    if (setupResult.mpxConnectionCreated == true) {
      return true;
    }
    return setupResult.availableInContacts == true;
  }

  Future<PickedTextFile?> _pickTextFile() async {
    final picker = _ref.read(filePickerPlatformProvider);
    final picked = await picker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt'],
    );
    if (picked == null || picked.files.isEmpty) {
      return null;
    }

    final file = picked.files.first;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      return null;
    }

    return PickedTextFile(
      fileName: file.name,
      content: String.fromCharCodes(bytes),
    );
  }

  String _setupContextNameForTarget(AgentContext target) {
    return target == AgentContext.work ? 'work-ai' : 'personal-ai';
  }

  String _agentDisplayNameForTarget(AgentContext target) {
    return target == AgentContext.work ? 'Work AI' : 'Personal AI';
  }

  bool _matchesTargetContext(
    PersonalAgentSetupResult result,
    String contextName,
  ) {
    final normalizedContextId = result.contextId.trim().toLowerCase();
    final normalizedTarget = contextName.trim().toLowerCase();
    return normalizedContextId.startsWith(normalizedTarget);
  }
}
