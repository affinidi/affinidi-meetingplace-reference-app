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
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_category.dart';
import '../../../domain/models/contacts/contact_status.dart';
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
    return _RoutingTargetSpec(
      target: AgentContext.work,
      contextName: AgentContext.work.setupContextName,
      displayName: 'Work AI',
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
      controller.setAutoResponseAvailability(
        ref.read(signingServiceProvider).status ==
            SigningServiceStatus.connected,
      );

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
        controller.setAutoResponseAvailability(
          next.status == SigningServiceStatus.connected,
        );
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

  void setAutoResponseAvailability(bool available) {
    state = state.copyWith(autoResponseAvailable: available);
  }

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
    final workAuthorizationSnapshot = PersonalAiAuthorizationSnapshot.tryDecode(
      workContact?.personalAgentAuthorizationSnapshot,
    );
    final workContextReady =
        contextRoutingState.workContextUploaded || workContact != null;

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
      workAuthorizationSnapshot: workAuthorizationSnapshot,
      showWorkAuthorization: workContact != null && workContextReady,
      workContextUploaded: workContextReady,
      workContextFileName:
          contextRoutingState.workContextFileName ??
          (workContact != null ? 'Work AI connected' : null),
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

    await _ref.read(contactsServiceProvider.notifier).ensureInitialized();

    final existingSetup = _setupForContext(spec.contextName);
    final canReuseExistingSetup =
        existingSetup != null &&
        _matchesTargetContext(existingSetup, spec.contextName) &&
        _isConnectionReady(existingSetup) &&
        (existingSetup.setupId?.trim().isNotEmpty ?? false) &&
        _hasContactForContext(spec.target);

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
        'Cannot connect Microsoft 365 because current holder DID is missing.',
        name: _logKey,
      );
      return const WorkOneDriveConnectionOutcome(
        completed: false,
        message:
            'Unable to connect Microsoft 365 because the current identity is '
            'missing a DID.',
      );
    }

    _logger.info(
      'Starting Work AI Microsoft 365 connection '
      '(holderDid=${_redact(holderDid)})',
      name: _logKey,
    );

    await _ref.read(contactsServiceProvider.notifier).ensureInitialized();

    final existingSetup = _setupForContext(spec.contextName);
    final canReuseExistingSetup =
        existingSetup != null &&
        _matchesTargetContext(existingSetup, spec.contextName) &&
        _isConnectionReady(existingSetup) &&
        (existingSetup.setupId?.trim().isNotEmpty ?? false) &&
        _hasContactForContext(spec.target);

    _setConnecting(spec.displayName);

    try {
      final oneDriveAuthService = _ref.read(
        microsoftOneDriveAuthServiceProvider,
      );
      final oauthResult = await oneDriveAuthService.authorize();

      if (!canReuseExistingSetup) {
        _logger.info(
          'Microsoft 365 OAuth completed; starting Work AI setup.',
          name: _logKey,
        );
        await _ensureSetupAndConnection(spec: spec, holderDid: holderDid);
      } else {
        _logger.info(
          'Reusing existing Work AI setup for Microsoft 365 OAuth '
          '(setupId=${_redact(existingSetup.setupId ?? '')})',
          name: _logKey,
        );
      }

      final setupResult = _setupForContext(spec.contextName);
      final setupId = setupResult?.setupId?.trim() ?? '';
      final contactReady = await _waitForContactForContext(spec.target);
      final setupReady =
          setupResult != null &&
          _matchesTargetContext(setupResult, spec.contextName) &&
          !_isTerminalSetupFailure(setupResult) &&
          setupId.isNotEmpty;
      if (!setupReady) {
        _logger.error(
          'Cannot connect Microsoft 365 because Work AI setup is incomplete.',
          name: _logKey,
        );
        _clearConnecting();
        return const WorkOneDriveConnectionOutcome(
          completed: false,
          message:
              'Unable to connect Microsoft 365 because Work AI setup is '
              'incomplete.',
        );
      }

      _logger.info(
        'Work AI setup can store Microsoft 365 OAuth '
        '(setupId=${_redact(setupId)}, contactReady=$contactReady)',
        name: _logKey,
      );

      await oneDriveAuthService.storeConnection(
        setupId: setupId,
        holderDid: holderDid,
        oauthResult: oauthResult,
      );

      _logger.info(
        'Microsoft 365 OAuth storage completed; Agent Stream will use '
        'Microsoft Graph grounding at answer time.',
        name: _logKey,
      );

      await _ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .markContextUploaded(
            context: spec.target,
            fileName: 'Microsoft 365 Agent Stream connection',
          );

      await _ref
          .read(personalAiServiceProvider.notifier)
          .refreshPersonalAiContactSync();
      await _ref.read(contactsServiceProvider.notifier).fetchContacts();
      syncFromDependencies();

      _clearConnecting();
      return const WorkOneDriveConnectionOutcome(
        completed: true,
        message:
            'Microsoft 365 connected. Work AI will use Agent Stream at '
            'answer time.',
      );
    } on MicrosoftOneDriveAuthCancelledException {
      _logger.info(
        'Work AI Microsoft 365 connection cancelled before Agent Stream setup.',
        name: _logKey,
      );
      _clearConnecting();
      return const WorkOneDriveConnectionOutcome(
        completed: false,
        message: 'Microsoft 365 sign-in cancelled.',
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Work AI Microsoft 365 connection failed.',
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

  /// Whether a local Personal AI contact still exists for [target]. When it is
  /// missing (e.g. after a disconnect or a stuck/incomplete setup), the setup
  /// must be re-run so the contact is re-materialized from the same channel.
  bool _hasContactForContext(AgentContext target) {
    final contactsState = _ref.read(contactsServiceProvider);
    final routingState = _ref.read(contextRoutingServiceProvider);
    return findPersonalAiContactForContext(
          contacts: contactsState.contacts,
          contactContexts: routingState.contactContexts,
          targetContext: target,
        ) !=
        null;
  }

  Contact? _findUnassignedPersonalAiContactForContext(AgentContext target) {
    final contactsState = _ref.read(contactsServiceProvider);
    final routingState = _ref.read(contextRoutingServiceProvider);
    final candidates = contactsState.contacts
        .where((contact) {
          if (contact.category != ContactCategory.robot ||
              contact.status != ContactStatus.active) {
            return false;
          }
          if (isAiContactBoundToOtherContext(
            contact: contact,
            targetContext: target,
            contactContexts: routingState.contactContexts,
          )) {
            return false;
          }
          final assignedContext = routingState.contactContexts[contact.id];
          if (assignedContext == target) {
            return true;
          }
          final cardType = contact.card.type.trim().toLowerCase();
          final otherPartyType = contact.otherPartyCard?.type
              .trim()
              .toLowerCase();
          return assignedContext == null &&
              (cardType == 'ai-agent' || otherPartyType == 'ai-agent');
        })
        .toList(growable: false);

    if (candidates.length == 1) {
      return candidates.first;
    }
    return null;
  }

  Future<bool> _ensureLocalContactForContext(AgentContext target) async {
    if (_hasContactForContext(target)) {
      return true;
    }

    final fallbackContact = _findUnassignedPersonalAiContactForContext(target);
    if (fallbackContact == null) {
      return false;
    }

    await _ref
        .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
        .assignContactContext(fallbackContact.id, target);
    syncFromDependencies();
    return true;
  }

  Future<bool> _waitForContactForContext(
    AgentContext target, {
    int maxAttempts = 5,
    Duration pollEvery = const Duration(seconds: 1),
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await _ref.read(contactsServiceProvider.notifier).fetchContacts();
      syncFromDependencies();
      if (await _ensureLocalContactForContext(target)) {
        return true;
      }
      if (attempt < maxAttempts) {
        await Future<void>.delayed(pollEvery);
      }
    }
    return false;
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

  bool _isTerminalSetupFailure(PersonalAgentSetupResult setupResult) {
    final setupStatus = (setupResult.setupStatus ?? '').trim().toLowerCase();
    return setupStatus == 'cancelled' ||
        setupStatus == 'failed' ||
        setupStatus == 'error';
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
    if (!state.autoResponseAvailable) {
      state = state.copyWith(
        errorMessage: 'Auto response is unavailable until VTA is connected',
      );
      return;
    }

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
        'Auto response toggled successfully: '
        '$previousValue -> $newAutoResponse',
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
