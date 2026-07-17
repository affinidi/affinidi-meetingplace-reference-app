import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_service.dart';
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

class _RoutingTargetSpec {
  const _RoutingTargetSpec({
    required this.target,
    required this.contextName,
    required this.displayName,
  });

  factory _RoutingTargetSpec.from(AgentContext target) {
    if (target == AgentContext.work) {
      return const _RoutingTargetSpec(
        target: AgentContext.work,
        contextName: 'work-ai',
        displayName: 'Work AI',
      );
    }

    return const _RoutingTargetSpec(
      target: AgentContext.personal,
      contextName: 'personal-ai',
      displayName: 'Personal AI',
    );
  }

  final AgentContext target;
  final String contextName;
  final String displayName;
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

  Future<RoutingContextUploadOutcome> uploadRoutingContext(
    AgentContext target, {
    required String fileName,
    required String content,
  }) async {
    final spec = _RoutingTargetSpec.from(target);
    if (fileName.trim().isEmpty || content.trim().isEmpty) {
      return const RoutingContextUploadOutcome.skipped();
    }

    final holderDid = _currentHolderDid();
    if (holderDid.isEmpty) {
      return const RoutingContextUploadOutcome.skipped();
    }

    final existingSetup = _setupForContext(spec.contextName);
    final canReuseExistingSetup =
        existingSetup != null &&
        state.isReady &&
        _matchesTargetContext(existingSetup, spec.contextName) &&
        (existingSetup.setupId?.trim().isNotEmpty ?? false);

    _setConnecting(spec.displayName);

    try {
      if (!canReuseExistingSetup) {
        await _ensureSetupAndConnection(spec: spec, holderDid: holderDid);
      }

      final setupResult = _setupForContext(spec.contextName);
      final connected =
          setupResult != null &&
          _matchesTargetContext(setupResult, spec.contextName) &&
          (_isConnectionReady(setupResult) || state.isReady);
      if (!connected) {
        state = state.copyWith(
          contextUploadError: '${spec.displayName} is still connecting.',
        );
        _clearConnecting();
        return const RoutingContextUploadOutcome.skipped();
      }

      final setupId = setupResult.setupId?.trim() ?? '';
      if (setupId.isEmpty) {
        _clearConnecting();
        return const RoutingContextUploadOutcome.skipped();
      }

      await _ref
          .read(personalAiServiceProvider.notifier)
          .uploadContext(
            setupId: setupId,
            content: content,
            setupContextName: spec.contextName,
            agentDisplayName: spec.displayName,
          );
      syncFromDependencies();

      if (state.contextUploadError != null) {
        _clearConnecting();
        return const RoutingContextUploadOutcome.skipped();
      }

      await _ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .markContextUploaded(context: spec.target, fileName: fileName);

      await _ref
          .read(personalAiServiceProvider.notifier)
          .refreshPersonalAiContactSync();
      await _ref.read(contactsServiceProvider.notifier).fetchContacts();

      _clearConnecting();
      return RoutingContextUploadOutcome.uploaded(
        fileName: fileName,
        target: spec.target,
      );
    } catch (_) {
      _clearConnecting();
      rethrow;
    }
  }

  Future<void> _ensureSetupAndConnection({
    required _RoutingTargetSpec spec,
    required String holderDid,
  }) async {
    await _ref
        .read(personalAiServiceProvider.notifier)
        .setupPersonalAi(
          holderDid: holderDid,
          contextName: spec.contextName,
          agentDisplayName: spec.displayName,
        );
    syncFromDependencies();

    var setupResult = _setupForContext(spec.contextName);
    final connectionKnownReady =
        state.isReady &&
        setupResult != null &&
        _matchesTargetContext(setupResult, spec.contextName);

    if (!connectionKnownReady &&
        (setupResult == null || !_isConnectionReady(setupResult))) {
      setupResult = await _ref
          .read(personalAiServiceProvider.notifier)
          .waitUntilConnected(
            holderDid: holderDid,
            contextName: spec.contextName,
            agentDisplayName: spec.displayName,
          );
      syncFromDependencies();
    }
  }

  PersonalAgentSetupResult? _setupForContext(String contextName) {
    final personalAiState = _ref.read(personalAiServiceProvider);
    return personalAiState.getSetupResultForContext(contextName) ??
        personalAiState.setupResult;
  }

  String _currentHolderDid() {
    final identity = _ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    return (identity?.did ?? state.holderDid ?? '').trim();
  }

  void _setConnecting(String label) {
    state = state.copyWith(
      isConnecting: true,
      connectingLabel: label,
      clearContextUploadError: true,
    );
  }

  void _clearConnecting() {
    state = state.copyWith(isConnecting: false, clearConnectingLabel: true);
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

  bool _matchesTargetContext(
    PersonalAgentSetupResult result,
    String contextName,
  ) {
    final normalizedContextId = result.contextId.trim().toLowerCase();
    final normalizedTarget = contextName.trim().toLowerCase();
    return normalizedContextId.startsWith(normalizedTarget);
  }
}
