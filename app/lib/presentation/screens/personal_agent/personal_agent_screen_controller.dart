import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/context_routing_service/context_routing_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/one_drive_service/microsoft_one_drive_auth_service.dart';
import '../../../application/services/personal_ai_service/disconnect_agent_context_service.dart';
import '../../../application/services/personal_ai_service/personal_ai_authorization_snapshot.dart';
import '../../../application/services/personal_ai_service/personal_ai_contact_resolution.dart';
import '../../../application/services/personal_ai_service/personal_ai_service.dart';
import '../../../application/services/signing_service/signing_service.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
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

class WorkOneDriveConnectionOutcome {
  const WorkOneDriveConnectionOutcome({
    required this.completed,
    required this.message,
  });

  final bool completed;
  final String message;
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

      ref.listen(
        contactsServiceProvider,
        (_, _) => controller.syncFromDependencies(),
        fireImmediately: true,
      );

      ref.listen(
        contextRoutingServiceProvider,
        (_, _) => controller.syncFromDependencies(),
        fireImmediately: true,
      );

      ref.listen(signingServiceProvider, (prev, next) {
        if (prev?.status != SigningServiceStatus.connected &&
            next.status == SigningServiceStatus.connected) {
          controller.loadAutoResponseState();
        }
      }, fireImmediately: true);

      return controller;
    });

class PersonalAgentScreenController
    extends StateNotifier<PersonalAgentScreenState> {
  PersonalAgentScreenController(this._ref)
    : super(const PersonalAgentScreenState.initial());

  static const _logKey = 'PAICTL';

  final Ref _ref;
  late final _logger = _ref.read(appLoggerProvider);

  void syncFromDependencies() {
    final identity = _ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    final personalAiState = _ref.read(personalAiServiceProvider);
    final contactsState = _ref.read(contactsServiceProvider);
    final contextRoutingState = _ref.read(contextRoutingServiceProvider);

    final workContact = findPersonalAiContactForContext(
      contacts: contactsState.contacts,
      contactContexts: contextRoutingState.contactContexts,
      targetContext: AgentContext.work,
    );
    final personalContact = findPersonalAiContactForContext(
      contacts: contactsState.contacts,
      contactContexts: contextRoutingState.contactContexts,
      targetContext: AgentContext.personal,
    );

    final workAuthorizationSnapshot = PersonalAiAuthorizationSnapshot.tryDecode(
      workContact?.personalAgentAuthorizationSnapshot,
    );
    final personalAuthorizationSnapshot =
        PersonalAiAuthorizationSnapshot.tryDecode(
          personalContact?.personalAgentAuthorizationSnapshot,
        );

    state = state.copyWith(
      holderDid: identity?.did,
      isReady: personalAiState.isReady,
      isSettingUp: personalAiState.isSettingUp,
      contextProvisioned: personalAiState.contextProvisioned,
      contextUploading: personalAiState.contextUploading,
      errorMessage: personalAiState.errorMessage,
      contextUploadError: personalAiState.contextUploadError,
      setupResult: personalAiState.setupResult,
      workContact: workContact,
      personalContact: personalContact,
      workAuthorizationSnapshot: workAuthorizationSnapshot,
      personalAuthorizationSnapshot: personalAuthorizationSnapshot,
      showWorkAuthorization:
          workContact != null && contextRoutingState.workContextUploaded,
      showPersonalAuthorization:
          personalContact != null &&
          contextRoutingState.personalContextUploaded,
      workContextUploaded: contextRoutingState.workContextUploaded,
      personalContextUploaded: contextRoutingState.personalContextUploaded,
      workContextFileName: contextRoutingState.workContextFileName,
      personalContextFileName: contextRoutingState.personalContextFileName,
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
        _matchesTargetContext(existingSetup, spec.contextName) &&
        _isConnectionReady(existingSetup) &&
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
          _isConnectionReady(setupResult);
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

  Future<WorkOneDriveConnectionOutcome> connectWorkOneDrive() async {
    final spec = _RoutingTargetSpec.from(AgentContext.work);
    final holderDid = _currentHolderDid();
    if (holderDid.isEmpty) {
      _logger.error(
        'Cannot connect OneDrive because current holder DID is missing.',
        name: _logKey,
      );
      return const WorkOneDriveConnectionOutcome(
        completed: false,
        message:
            'Unable to connect OneDrive because the current identity is '
            'missing a DID.',
      );
    }

    _logger.info(
      'Starting Work AI OneDrive connection (holderDid=${_redact(holderDid)})',
      name: _logKey,
    );

    final existingSetup = _setupForContext(spec.contextName);
    final canReuseExistingSetup =
        existingSetup != null &&
        _matchesTargetContext(existingSetup, spec.contextName) &&
        _isConnectionReady(existingSetup) &&
        (existingSetup.setupId?.trim().isNotEmpty ?? false);

    _setConnecting(spec.displayName);

    try {
      Object? setupError;
      StackTrace? setupStackTrace;
      Future<void>? setupFuture;
      if (!canReuseExistingSetup) {
        _logger.info(
          'Starting Work AI setup while OneDrive OAuth opens.',
          name: _logKey,
        );
        setupFuture =
            _ensureSetupAndConnection(
              spec: spec,
              holderDid: holderDid,
            ).catchError((Object error, StackTrace stackTrace) {
              setupError = error;
              setupStackTrace = stackTrace;
            });
      } else {
        _logger.info(
          'Reusing existing Work AI setup for OneDrive OAuth '
          '(setupId=${_redact(existingSetup.setupId ?? '')})',
          name: _logKey,
        );
      }

      final oneDriveAuthService = _ref.read(
        microsoftOneDriveAuthServiceProvider,
      );
      final oauthResult = await oneDriveAuthService.authorize();

      if (setupFuture != null) {
        await setupFuture;
        if (setupError != null) {
          Error.throwWithStackTrace(
            setupError!,
            setupStackTrace ?? StackTrace.current,
          );
        }
      }

      final setupId = _setupForContext(spec.contextName)?.setupId?.trim() ?? '';
      if (setupId.isEmpty) {
        _logger.error(
          'Cannot connect OneDrive because Work AI setup id is missing.',
          name: _logKey,
        );
        _clearConnecting();
        return const WorkOneDriveConnectionOutcome(
          completed: false,
          message:
              'Unable to connect OneDrive because Work AI setup is incomplete.',
        );
      }

      _logger.info(
        'Work AI setup is ready; starting OneDrive OAuth '
        '(setupId=${_redact(setupId)})',
        name: _logKey,
      );

      final importResult = await oneDriveAuthService.storeAndImport(
        setupId: setupId,
        holderDid: holderDid,
        oauthResult: oauthResult,
      );

      _logger.info(
        'OneDrive OAuth storage and import completed '
        '(imported=${importResult.importedFileCount}, '
        'skipped=${importResult.skippedFileCount}).',
        name: _logKey,
      );

      if (!importResult.hasContent) {
        const noFilesMessage =
            'OneDrive connected, but no supported text files were found to '
            'import into Work AI context.';
        state = state.copyWith(contextUploadError: noFilesMessage);
        _clearConnecting();
        return const WorkOneDriveConnectionOutcome(
          completed: false,
          message: noFilesMessage,
        );
      }

      await _ref
          .read(personalAiServiceProvider.notifier)
          .uploadContext(
            setupId: setupId,
            content: importResult.content,
            setupContextName: spec.contextName,
            agentDisplayName: spec.displayName,
          );
      syncFromDependencies();

      if (state.contextUploadError != null) {
        _clearConnecting();
        return WorkOneDriveConnectionOutcome(
          completed: false,
          message: state.contextUploadError!,
        );
      }

      final importedFileName =
          'OneDrive import (${importResult.importedFileCount} files)';
      await _ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .markContextUploaded(
            context: spec.target,
            fileName: importedFileName,
          );

      await _ref
          .read(personalAiServiceProvider.notifier)
          .refreshPersonalAiContactSync();
      await _ref.read(contactsServiceProvider.notifier).fetchContacts();
      syncFromDependencies();

      _clearConnecting();
      return WorkOneDriveConnectionOutcome(
        completed: true,
        message:
            'OneDrive imported ${importResult.importedFileCount} file(s) '
            'into Work AI context.',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Work AI OneDrive connection failed.',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      _clearConnecting();
      rethrow;
    }
  }

  Future<void> _ensureSetupAndConnection({
    required _RoutingTargetSpec spec,
    required String holderDid,
  }) async {
    _logger.info(
      'Ensuring ${spec.displayName} setup '
      '(context=${spec.contextName}, holderDid=${_redact(holderDid)})',
      name: _logKey,
    );
    await _ref
        .read(personalAiServiceProvider.notifier)
        .setupPersonalAi(
          holderDid: holderDid,
          contextName: spec.contextName,
          agentDisplayName: spec.displayName,
        );
    syncFromDependencies();

    var setupResult = _setupForContext(spec.contextName);
    _logger.info(
      '${spec.displayName} setup response '
      '(setupId=${_redact(setupResult?.setupId ?? '')}, '
      'contextId=${setupResult?.contextId ?? 'missing'}, '
      'status=${setupResult?.setupStatus ?? 'missing'}, '
      'mpxConnectionCreated=${setupResult?.mpxConnectionCreated})',
      name: _logKey,
    );
    final connectionKnownReady =
        setupResult != null &&
        _matchesTargetContext(setupResult, spec.contextName) &&
        _isConnectionReady(setupResult);

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
      _logger.info(
        '${spec.displayName} setup poll completed '
        '(setupId=${_redact(setupResult?.setupId ?? '')}, '
        'status=${setupResult?.setupStatus ?? 'missing'}, '
        'mpxConnectionCreated=${setupResult?.mpxConnectionCreated})',
        name: _logKey,
      );
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

  String _redact(String value) {
    if (value.isEmpty) return '(empty)';
    if (value.length <= 12) return '${value.substring(0, 3)}...';
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }

  Future<void> disconnectRoutingContext(AgentContext target) async {
    _setConnecting(target == AgentContext.work ? 'Work AI' : 'Personal AI');

    try {
      await _ref.read(disconnectAgentContextServiceProvider).disconnect(target);
      syncFromDependencies();
      _clearConnecting();
    } catch (_) {
      _clearConnecting();
      rethrow;
    }
  }

  Future<void> loadAutoResponseState() async {
    try {
      final signingService = _ref.read(signingServiceProvider.notifier);
      final stepUpEnabled = await signingService.getStepUpEnabled();
      final autoResponse = !stepUpEnabled;
      _logger.info(
        'Loaded auto response state: stepUpEnabled=$stepUpEnabled, '
        'autoResponse=$autoResponse',
        name: _logKey,
      );
      state = state.copyWith(autoResponseEnabled: autoResponse);
    } catch (e) {
      _logger.info(
        'Could not load auto response state (VTA not connected): $e',
        name: _logKey,
      );
    }
  }

  Future<void> toggleAutoResponse() async {
    final previousValue = state.autoResponseEnabled;
    _logger.info(
      'Toggle auto response: current=$previousValue, target=${!previousValue}',
      name: _logKey,
    );
    state = state.copyWith(autoResponseLoading: true);
    try {
      final signingService = _ref.read(signingServiceProvider.notifier);
      final newAutoResponse = !previousValue;
      final newStepUp = !newAutoResponse;
      _logger.info(
        'Setting step-up enabled=$newStepUp (autoResponse=$newAutoResponse)',
        name: _logKey,
      );
      await signingService.setStepUpEnabled(newStepUp);
      _logger.info(
        '''Auto response toggled successfully: $previousValue -> $newAutoResponse''',
        name: _logKey,
      );
      state = state.copyWith(
        autoResponseEnabled: newAutoResponse,
        autoResponseLoading: false,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Auto response toggle failed: $e',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(
        autoResponseLoading: false,
        errorMessage: 'Auto response toggle failed: $e',
      );
    }
  }
}
