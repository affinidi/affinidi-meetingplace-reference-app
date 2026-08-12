import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';
import 'package:meeting_place_vta_client/meeting_place_vta_client.dart';

import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_category.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/providers/mnemonic_hash_provider.dart';
import '../../../infrastructure/secure_storage/secure_storage.dart';
import '../connections_service/connections_service.dart';
import '../contacts_service/contacts_service.dart';
import '../context_routing_service/context_routing_service.dart';
import '../identities_service/identities_service.dart';
import 'personal_ai_authorization_snapshot.dart';
import 'personal_ai_contact_resolution.dart';
import 'personal_ai_service_state.dart';

final personalAiServiceProvider =
    StateNotifierProvider<PersonalAiService, PersonalAiServiceState>(
      PersonalAiService.new,
    );

class PersonalAiService extends StateNotifier<PersonalAiServiceState> {
  PersonalAiService(this._ref) : super(const PersonalAiServiceState.initial()) {
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    unawaited(_restoreSessionAfterRestart());
  }

  final Ref _ref;
  late final _lifecycleObserver = _PersonalAiLifecycleObserver(
    onResumed: _handleAppResumed,
  );

  static const _logKey = 'PERSONAL_AI';
  late final AppLogger _logger = _ref.read(appLoggerProvider);

  Environment get _environment => _ref.read(environmentProvider);
  MeetingPlacePersonalAgentSDK? _sdk;
  Future<MeetingPlacePersonalAgentSDK>? _sdkFuture;

  Future<String> _resolvePersonalAiBaseUrl() async {
    final mnemonicHash = (await _ref.read(mnemonicHashProvider.future))?.hash;
    if (mnemonicHash == null || mnemonicHash.isEmpty) {
      throw StateError(
        'Personal AI base URL is unavailable because mnemonic hash is missing.',
      );
    }

    final baseUrl = _environment.personalAiBaseUrl(mnemonicHash);
    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError(
        'Personal AI base URL is not configured for the current wallet.',
      );
    }
    return baseUrl;
  }

  Future<MeetingPlacePersonalAgentSDK> _loadSdk() {
    final cachedSdk = _sdk;
    if (cachedSdk != null) {
      return Future<MeetingPlacePersonalAgentSDK>.value(cachedSdk);
    }

    final pendingSdk = _sdkFuture;
    if (pendingSdk != null) return pendingSdk;

    final future = _createSdk();
    _sdkFuture = future;
    return future;
  }

  Future<MeetingPlacePersonalAgentSDK> _createSdk() async {
    try {
      final baseUrl = await _resolvePersonalAiBaseUrl();
      final sdk = MeetingPlacePersonalAgentSDK.hosted(
        baseUrl: baseUrl,
        endpoint: _environment.personalAiSetupEndpoint,
      );
      _sdk = sdk;
      return sdk;
    } catch (_) {
      _sdkFuture = null;
      rethrow;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  void _handleAppResumed() {
    unawaited(refreshPersonalAiContactSync());
    unawaited(refreshContextStatus());
  }

  Future<void> refreshPersonalAiContactSync() async {
    if (!_environment.personalAiEnabled) {
      return;
    }

    final setups = state.setupResultsByContext.isNotEmpty
        ? state.setupResultsByContext.values.toList()
        : (state.setupResult != null
              ? [state.setupResult!]
              : const <PersonalAgentSetupResult>[]);

    for (final setupResult in setups) {
      await _syncPersonalAiContactForSetup(setupResult, isInitialSetup: false);
      await _refreshAuthorizationSnapshotForSetup(setupResult);
    }
  }

  Future<void> _syncPersonalAiContactForSetup(
    PersonalAgentSetupResult setupResult, {
    required bool isInitialSetup,
  }) async {
    final sdk = await _loadSdk();
    String? channelDid;
    String? offerLink;
    final setupId = setupResult.setupId?.trim() ?? '';
    if (setupId.isNotEmpty) {
      try {
        final offer = await sdk.fetchPersonalAgentOffer(setupId: setupId);
        final cd = offer.channelDid?.trim() ?? '';
        if (cd.isNotEmpty) {
          channelDid = cd;
        }
        offerLink = await _resolveOfferLinkForChannelDid(channelDid);
      } catch (_) {
        // Offer may be unavailable (server restarted) — proceed without it.
      }
    }

    await _ensurePersonalAiContactFromChannel(channelDid, offerLink: offerLink);

    await _waitForPersonalAiContact(
      channelDid: channelDid,
      offerLink: offerLink,
      maxAttempts: 3,
      pollEvery: const Duration(milliseconds: 300),
    );
    await _ensurePersonalAiContact(
      setupResult,
      preferredChannelDid: channelDid,
      offerLink: offerLink,
      isInitialSetup: isInitialSetup,
    );
  }

  void onIdentityCreated() {
    if (!_environment.personalAiEnabled) {
      return;
    }

    if (state.isReady || state.promptDismissed) {
      return;
    }

    state = state.copyWith(showSetupPrompt: true, clearErrorMessage: true);
  }

  void openSetupPrompt() {
    state = state.copyWith(showSetupPrompt: true, promptDismissed: false);
  }

  void dismissSetupPrompt() {
    state = state.copyWith(showSetupPrompt: false, promptDismissed: true);
  }

  /// Helper method to update setupResult while maintaining the
  /// context-aware map.
  /// Both backward-compat setupResult and setupResultsByContext are updated.
  void _updateSetupResult(
    PersonalAgentSetupResult result, {
    String? contextName,
  }) {
    final contextKey = canonicalPersonalAiContextName(
      explicitContextName: contextName,
      contextId: result.contextId,
      displayName: result.profile.displayName,
    );
    final updatedMap = Map<String, PersonalAgentSetupResult>.from(
      state.setupResultsByContext,
    );
    updatedMap[contextKey] = result;

    state = state.copyWith(
      setupResult: result,
      setupResultsByContext: updatedMap,
    );
  }

  Future<void> removeSetupForContext(AgentContext target) async {
    final contextKey = target.setupContextName;
    final updatedMap = Map<String, PersonalAgentSetupResult>.from(
      state.setupResultsByContext,
    )..remove(contextKey);

    final fallbackSetup = _fallbackSetupResult(updatedMap);
    final nextStatus = _deriveStatusFromSetupMap(updatedMap);

    state = state.copyWith(
      status: nextStatus,
      setupResult: fallbackSetup,
      setupResultsByContext: updatedMap,
      contextProvisioned: updatedMap.isNotEmpty && state.contextProvisioned,
      showSetupPrompt: false,
      contextUploading: false,
      clearErrorMessage: true,
      clearContextUploadError: true,
      clearSetupResult: fallbackSetup == null,
    );

    if (updatedMap.isEmpty) {
      final storage = await _ref.read(secureStorageProvider.future);
      await storage.clearPersonalAiHolderDid();
    }
  }

  PersonalAgentSetupResult? _fallbackSetupResult(
    Map<String, PersonalAgentSetupResult> setupsByContext,
  ) {
    if (setupsByContext.isEmpty) {
      return null;
    }

    for (final setup in setupsByContext.values) {
      if (_isConnectionReady(setup)) {
        return setup;
      }
    }

    return setupsByContext.values.first;
  }

  PersonalAiSetupStatus _deriveStatusFromSetupMap(
    Map<String, PersonalAgentSetupResult> setupsByContext,
  ) {
    if (setupsByContext.isEmpty) {
      return PersonalAiSetupStatus.notConfigured;
    }

    if (setupsByContext.values.any(_isConnectionReady)) {
      return PersonalAiSetupStatus.ready;
    }

    return PersonalAiSetupStatus.settingUp;
  }

  /// Upload the user's context file and store it as the agent's initial memory.
  Future<void> uploadContext({
    required String setupId,
    required String content,
    String setupContextName = 'work-ai',
    String agentDisplayName = 'Work AI',
  }) async {
    if (!_environment.personalAiEnabled) return;
    if (state.contextUploading) return;
    final sdk = await _loadSdk();

    final contextKey = _routeKeyForSetupContextName(setupContextName);

    state = state.copyWith(
      contextUploading: true,
      clearContextUploadError: true,
    );

    try {
      // Upload first for the common case (already connected + valid setup).
      // If setup record was lost after a backend restart, fallback to
      // re-register + retry once.
      var effectiveSetupId = setupId;
      PersonalAgentContextStatus uploadStatus;
      try {
        uploadStatus = await sdk.uploadPersonalAgentContext(
          setupId: effectiveSetupId,
          content: content,
          contextKey: contextKey,
        );
      } on VtaClientException catch (error) {
        if (!_isMissingSetupError(error)) {
          rethrow;
        }

        final identity = _ref.read(
          identitiesServiceProvider.currentIdentityOrPrimary,
        );
        final holderDidFromIdentity = identity?.did.trim() ?? '';
        final contextSpecificSetup =
            state.setupResultsByContext[setupContextName];
        final holderDid = holderDidFromIdentity.isNotEmpty
            ? holderDidFromIdentity
            : (contextSpecificSetup?.holderDid.trim() ??
                  state.setupResult?.holderDid.trim() ??
                  '');
        if (holderDid.isEmpty) {
          rethrow;
        }

        final freshSetup = await sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: holderDid,
            contextName: setupContextName,
            agentDisplayName: agentDisplayName,
          ),
        );
        effectiveSetupId = freshSetup.setupId ?? setupId;
        _updateSetupResult(freshSetup, contextName: setupContextName);

        uploadStatus = await sdk.uploadPersonalAgentContext(
          setupId: effectiveSetupId,
          content: content,
          contextKey: contextKey,
        );
      }

      if (!uploadStatus.provisioned) {
        throw StateError('Personal AI context upload was not provisioned.');
      }

      final setupResult = state.getSetupResultForContext(setupContextName);
      if (setupResult != null) {
        await _syncPersonalAiContactForSetup(
          setupResult,
          isInitialSetup: false,
        ).catchError((_) {});
        await _refreshAuthorizationSnapshotForSetup(setupResult);
      }

      state = state.copyWith(contextProvisioned: true, contextUploading: false);
    } catch (error) {
      state = state.copyWith(
        contextUploading: false,
        contextUploadError: error.toString(),
      );
    }
  }

  String _routeKeyForSetupContextName(String setupContextName) {
    return AgentContext.work.routeKey;
  }

  bool _isMissingSetupError(VtaClientException error) {
    if (error.statusCode == 404) {
      return true;
    }
    final body = (error.body ?? '').toLowerCase();
    final message = error.message.toLowerCase();
    return body.contains('unknown setup_id') ||
        message.contains('unknown setup_id');
  }

  /// Refresh context provisioning status from the backend.
  Future<void> refreshContextStatus() async {
    if (!_environment.personalAiEnabled) return;
    final setupId = state.setupResult?.setupId?.trim();
    if (setupId == null || setupId.isEmpty) return;
    if (state.contextProvisioned) return;

    try {
      final sdk = await _loadSdk();
      final status = await sdk.fetchPersonalAgentContextStatus(
        setupId: setupId,
      );
      if (status.provisioned && !state.contextProvisioned) {
        state = state.copyWith(contextProvisioned: true);
      }
    } catch (_) {
      // Best-effort — don't surface transient check failures.
    }
  }

  Future<void> setupPersonalAi({
    required String holderDid,
    String contextName = 'work-ai',
    String agentDisplayName = 'Work AI',
  }) async {
    if (!_environment.personalAiEnabled) {
      return;
    }

    final normalizedHolderDid = holderDid.trim();
    if (normalizedHolderDid.isEmpty) {
      _logger.error(
        'Cannot connect Personal AI: holder DID is missing.',
        name: _logKey,
      );
      state = state.copyWith(
        status: PersonalAiSetupStatus.failed,
        errorMessage:
            'Unable to set up Personal AI because the current identity '
            'is missing a DID.',
      );
      return;
    }

    state = state.copyWith(
      status: PersonalAiSetupStatus.settingUp,
      clearErrorMessage: true,
    );

    String? personalAiBaseUrl;
    try {
      personalAiBaseUrl = await _resolvePersonalAiBaseUrl();
      _logger.info(
        'Connecting to Personal AI URL: '
        'baseUrl=$personalAiBaseUrl '
        'endpoint=${_environment.personalAiSetupEndpoint} '
        'context=$contextName '
        'holderDid=${_redact(normalizedHolderDid)}',
        name: _logKey,
      );

      final sdk = await _loadSdk();
      _logger.info(
        'Requesting personal agent setup from Personal AI URL...',
        name: _logKey,
      );
      final result = await sdk.ensurePersonalAgentSetup(
        request: PersonalAgentSetupRequest(
          holderDid: normalizedHolderDid,
          contextName: contextName,
          agentDisplayName: agentDisplayName,
        ),
      );
      _logger.info(
        'Setup response received: '
        'setupId=${_redact(result.setupId ?? '')} '
        'contextId=${result.contextId} '
        'setupStatus=${result.setupStatus ?? '(none)'} '
        'mpxConnectionCreated=${result.mpxConnectionCreated} '
        'availableInContacts=${result.availableInContacts}',
        name: _logKey,
      );

      final offer = await _autoConnectPersonalAgent(
        result: result,
        holderDid: normalizedHolderDid,
      );
      _logger.info(
        'Auto-connect resolved offer: '
        'status=${offer.status} '
        'channelDid=${_redact(offer.channelDid ?? '')} '
        'channelId=${_redact(offer.channelId ?? '')}',
        name: _logKey,
      );

      // Refresh setup status after connect so state carries up-to-date
      // connection flags for follow-up flows (like context upload).
      var setupSnapshot = result;
      try {
        setupSnapshot = await sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: normalizedHolderDid,
            contextName: contextName,
            agentDisplayName: agentDisplayName,
          ),
        );
      } catch (error, stackTrace) {
        // Keep the original setup payload if status refresh fails.
        _logger.warning(
          'Post-connect setup status refresh failed, keeping original '
          'payload: $error',
          name: _logKey,
        );
        _logger.debug('$stackTrace', name: _logKey);
      }

      final offerChannelDid = offer.channelDid?.trim();
      final offerLink = await _resolveOfferLinkForChannelDid(offerChannelDid);
      await _ensurePersonalAiContactFromChannel(
        offerChannelDid,
        offerLink: offerLink,
      );
      await _waitForPersonalAiContact(
        channelDid: offerChannelDid,
        offerLink: offerLink,
      );
      await _ensurePersonalAiContact(
        setupSnapshot,
        preferredChannelDid: offerChannelDid,
        offerLink: offerLink,
        isInitialSetup: true,
      );
      await _refreshAuthorizationSnapshotForSetup(
        setupSnapshot,
        preferredChannelDid: offerChannelDid,
      );

      _updateSetupResult(setupSnapshot, contextName: contextName);
      final isReady = _isConnectionReady(setupSnapshot);
      _logger.info(
        'Personal AI connect finished: '
        'ready=$isReady '
        'setupStatus=${setupSnapshot.setupStatus ?? '(none)'} '
        'channelDid=${_redact(offerChannelDid ?? '')}',
        name: _logKey,
      );
      state = state.copyWith(
        status: isReady
            ? PersonalAiSetupStatus.ready
            : PersonalAiSetupStatus.settingUp,
        showSetupPrompt: false,
        promptDismissed: true,
      );

      final storage = await _ref.read(secureStorageProvider.future);
      await storage.writePersonalAiHolderDid(normalizedHolderDid);
    } catch (error, stackTrace) {
      _logger.error(
        'Personal AI connect failed for URL '
        '${personalAiBaseUrl ?? '(unresolved)'}',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(
        status: PersonalAiSetupStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  /// Poll setup until the backend reports the channel is connected for the
  /// requested context.
  Future<PersonalAgentSetupResult?> waitUntilConnected({
    required String holderDid,
    String contextName = 'work-ai',
    String agentDisplayName = 'Work AI',
    int maxAttempts = 20,
    Duration pollEvery = const Duration(seconds: 1),
  }) async {
    final sdk = await _loadSdk();
    PersonalAgentSetupResult? latest;
    // Poll setup status while ControlPlaneService continuously advances the
    // pending OfferFinalised event (so channel inauguration is sent) instead of
    // waiting for a push notification or app resume/restart.
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        latest = await sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: holderDid,
            contextName: contextName,
            agentDisplayName: agentDisplayName,
          ),
        );

        _logger.info(
          'Personal AI setup poll '
          '(attempt=$attempt/$maxAttempts, '
          'setupId=${latest.setupId?.trim() ?? '-'}, '
          'status=${latest.setupStatus ?? '-'}, '
          'mpxConnectionCreated=${latest.mpxConnectionCreated}, '
          'availableInContacts=${latest.availableInContacts})',
          name: _logKey,
        );

        if (_isConnectionReady(latest)) {
          _updateSetupResult(latest, contextName: contextName);
          state = state.copyWith(
            status: PersonalAiSetupStatus.ready,
            clearErrorMessage: true,
          );
          return latest;
        }
      } catch (_) {
        // Best-effort polling; keep trying until timeout.
      }

      await Future<void>.delayed(pollEvery);
    }
    // });

    if (state.isReady) {
      return latest;
    }

    final result = latest;
    if (result != null) {
      _updateSetupResult(result, contextName: contextName);
    }
    return latest;
  }

  bool _isConnectionReady(PersonalAgentSetupResult result) {
    final setupStatus = (result.setupStatus ?? '').trim().toLowerCase();
    if (setupStatus == 'inaugurated' || setupStatus == 'ready') {
      return true;
    }
    if (result.mpxConnectionCreated == true) {
      return true;
    }
    return result.availableInContacts == true;
  }

  @visibleForTesting
  static bool isConnectedForRestore({
    required PersonalAgentSetupResult setupResult,
    PersonalAgentOfferResult? offer,
  }) {
    final setupStatus = (setupResult.setupStatus ?? '').trim().toLowerCase();
    if (setupStatus == 'inaugurated' || setupStatus == 'ready') {
      return true;
    }
    if (setupResult.mpxConnectionCreated == true) {
      return true;
    }
    if (setupResult.availableInContacts == true) {
      return true;
    }

    final normalizedOffer = offer;
    if (normalizedOffer == null) {
      return false;
    }

    final offerStatus = normalizedOffer.status.trim().toLowerCase();
    if (offerStatus == 'inaugurated' || offerStatus == 'ready') {
      return true;
    }

    return (normalizedOffer.channelDid?.trim().isNotEmpty ?? false) ||
        (normalizedOffer.channelId?.trim().isNotEmpty ?? false);
  }

  Future<void> _restoreSessionAfterRestart() async {
    if (!_environment.personalAiEnabled || state.isReady || state.isSettingUp) {
      return;
    }

    try {
      final sdk = await _loadSdk();
      final storage = await _ref.read(secureStorageProvider.future);
      final persistedHolderDid = (await storage.readPersonalAiHolderDid())
          ?.trim();
      if (persistedHolderDid == null || persistedHolderDid.isEmpty) {
        return;
      }

      final identitiesService = _ref.read(identitiesServiceProvider.notifier);
      await identitiesService.ensureInitialized();
      final identity = _ref.read(
        identitiesServiceProvider.currentIdentityOrPrimary,
      );
      final currentHolderDid = identity?.did.trim();
      if (currentHolderDid == null || currentHolderDid.isEmpty) {
        return;
      }

      if (persistedHolderDid != currentHolderDid) {
        return;
      }

      var anyConnected = false;
      for (final contextName in const ['work-ai']) {
        try {
          final contextResult = await sdk.ensurePersonalAgentSetup(
            request: PersonalAgentSetupRequest(
              holderDid: currentHolderDid,
              contextName: contextName,
            ),
          );
          PersonalAgentOfferResult? offer;
          if (!isConnectedForRestore(setupResult: contextResult)) {
            final setupId = contextResult.setupId?.trim();
            if (setupId != null && setupId.isNotEmpty) {
              try {
                offer = await sdk.fetchPersonalAgentOffer(setupId: setupId);
              } catch (_) {
                // Best-effort restore; leave offer null when unavailable.
              }
            }
          }
          // Only restore a context as set-up when it is actually connected.
          // After a reinstall the persisted holder DID survives in the
          // keychain while the local channel/contact store is wiped and the
          // connector has published a fresh, unaccepted offer. Restoring such
          // a context would falsely show "Already set up" with no contact and
          // block re-setup.
          if (isConnectedForRestore(setupResult: contextResult, offer: offer)) {
            _updateSetupResult(contextResult, contextName: contextName);
            anyConnected = true;
          }
        } catch (_) {
          // Best-effort restore for each configured context.
        }
      }

      if (!anyConnected) {
        // No connected context: the persisted session is stale (e.g. after a
        // reinstall). Leave state not-ready so the setup prompt returns and
        // the user can re-run setup.
        return;
      }

      state = state.copyWith(
        status: PersonalAiSetupStatus.ready,
        showSetupPrompt: false,
        promptDismissed: true,
        clearErrorMessage: true,
      );

      await refreshContextStatus();
      await refreshPersonalAiContactSync();
    } catch (_) {
      // Best-effort restore: startup should continue even if backend is
      // temporarily unavailable.
    }
  }

  Future<PersonalAgentOfferResult> _autoConnectPersonalAgent({
    required PersonalAgentSetupResult result,
    required String holderDid,
  }) async {
    final sdk = await _loadSdk();
    final initialSetupId = result.setupId?.trim();
    if (initialSetupId == null || initialSetupId.isEmpty) {
      throw StateError('Personal AI setup did not return a setup id.');
    }
    var setupId = initialSetupId;

    final contextName = AgentContext.work.setupContextName;

    final identitiesService = _ref.read(identitiesServiceProvider.notifier);
    await identitiesService.ensureInitialized();

    final identitiesState = _ref.read(identitiesServiceProvider);
    final identity =
        identitiesState.getIdentityByDid(holderDid) ??
        _ref.read(identitiesServiceProvider.currentIdentityOrPrimary);
    if (identity == null) {
      throw StateError(
        'Unable to find an identity to accept Personal AI offer.',
      );
    }

    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    for (var attempt = 0; attempt < 2; attempt++) {
      final offer = await _waitForOffer(
        setupId: setupId,
        holderDid: holderDid,
        contextName: contextName,
        agentDisplayName: result.profile.displayName,
      );
      final mnemonic = offer.mnemonic?.trim();
      final status = offer.status.trim().toLowerCase();
      final isAlreadyConnected =
          status == 'inaugurated' ||
          status == 'ready' ||
          (offer.channelDid?.trim().isNotEmpty ?? false) ||
          (offer.channelId?.trim().isNotEmpty ?? false);

      // An already-connected channel needs no accept-offer roundtrip even when
      // the offer file still carries its original mnemonic (the connector does
      // not clear it after inauguration). Reuse the live channel so a missing
      // local contact is rebuilt instead of re-accepting a consumed offer.
      if (isAlreadyConnected) {
        final canReuseChannel = await _canReuseConnectedOffer(
          result: result,
          offer: offer,
        );
        if (canReuseChannel) {
          return offer;
        }
        // Connected upstream but the channel is not present locally (e.g. it
        // was removed on disconnect). Re-accept below when the mnemonic is
        // still known to rebuild the channel; otherwise nothing to recover.
        if (mnemonic == null || mnemonic.isEmpty) {
          throw StateError(
            'AI offer reports connected but no channel is available for '
            '${result.profile.displayName.trim()}.',
          );
        }
      }

      if (mnemonic == null || mnemonic.isEmpty) {
        throw StateError('Personal AI setup did not return an offer mnemonic.');
      }

      final findResult = await coreSdk.findOffer(mnemonic: mnemonic);
      if (findResult.errorCode == null && findResult.connectionOffer != null) {
        final connectionsService = _ref.read(
          connectionsServiceProvider.notifier,
        );
        await connectionsService.acceptOffer(
          findResult.connectionOffer!,
          identity: identity,
        );

        // After accepting, wait for the connector to inaugurate a channel and
        // write channel_did into the offer file. When the peer reinstalled, its
        // previous channel is stale: the connector republishes a fresh offer
        // with a rotated mnemonic, so accept each fresh offer until a new
        // channel DID appears and pairing completes within this setup pass.
        return awaitChannelAfterAccept(
          acceptedMnemonic: mnemonic,
          previousChannelDid: offer.channelDid?.trim(),
          fetchOffer: () => sdk.fetchPersonalAgentOffer(setupId: setupId),
          acceptRotatedOffer: (rotatedMnemonic) async {
            final rotatedFind = await coreSdk.findOffer(
              mnemonic: rotatedMnemonic,
            );
            if (rotatedFind.errorCode != null ||
                rotatedFind.connectionOffer == null) {
              return false;
            }
            await connectionsService.acceptOffer(
              rotatedFind.connectionOffer!,
              identity: identity,
            );
            return true;
          },
        );
      }

      if (attempt == 0) {
        final refreshed = await sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: holderDid,
            contextName: contextName,
            agentDisplayName: result.profile.displayName,
          ),
        );
        _updateSetupResult(refreshed, contextName: contextName);
        final refreshedSetupId = refreshed.setupId?.trim();
        if (refreshedSetupId != null && refreshedSetupId.isNotEmpty) {
          setupId = refreshedSetupId;
          continue;
        }
      }

      throw StateError(
        'Unable to find Personal AI offer: ${findResult.errorCode}',
      );
    }

    throw StateError('Unable to resolve Personal AI offer from mnemonic.');
  }

  /// Waits for the connector to inaugurate a channel after an offer is
  /// accepted, re-accepting a rotated offer when the peer reinstalled.
  ///
  /// After [acceptedMnemonic] is accepted, polls [fetchOffer]. Returns as soon
  /// as the offer carries a channel DID that differs from [previousChannelDid].
  /// If instead the connector republishes a fresh pending offer with a new
  /// mnemonic, [acceptRotatedOffer] is invoked with it; when that returns
  /// `true` polling continues for the new offer, otherwise the loop stops.
  /// Falls back to a final [fetchOffer] result if no new channel appears within
  /// [maxPollsPerRound] polls (per round), for up to [maxRounds] rounds.
  @visibleForTesting
  static Future<PersonalAgentOfferResult> awaitChannelAfterAccept({
    required String acceptedMnemonic,
    required String? previousChannelDid,
    required Future<PersonalAgentOfferResult> Function() fetchOffer,
    required Future<bool> Function(String rotatedMnemonic) acceptRotatedOffer,
    int maxRounds = 3,
    int maxPollsPerRound = 20,
    Duration pollInterval = const Duration(seconds: 1),
  }) async {
    final acceptedMnemonics = <String>{acceptedMnemonic};
    var priorChannelDid = previousChannelDid;
    for (var round = 0; round < maxRounds; round++) {
      String? rotatedMnemonic;
      for (var poll = 1; poll <= maxPollsPerRound; poll++) {
        try {
          final current = await fetchOffer();
          final channelDid = current.channelDid?.trim();
          final hasNewChannel =
              channelDid != null &&
              channelDid.isNotEmpty &&
              (priorChannelDid == null || channelDid != priorChannelDid);
          if (hasNewChannel) {
            return current;
          }
          final freshMnemonic = current.mnemonic?.trim();
          if (current.status.trim().toLowerCase() ==
                  'offer_pending_acceptance' &&
              freshMnemonic != null &&
              freshMnemonic.isNotEmpty &&
              !acceptedMnemonics.contains(freshMnemonic)) {
            rotatedMnemonic = freshMnemonic;
            break;
          }
        } on VtaClientException catch (_) {
          // keep polling
        }
        await Future<void>.delayed(pollInterval);
      }
      if (rotatedMnemonic == null) {
        break;
      }
      final accepted = await acceptRotatedOffer(rotatedMnemonic);
      if (!accepted) {
        break;
      }
      acceptedMnemonics.add(rotatedMnemonic);
      priorChannelDid = null;
    }
    return fetchOffer();
  }

  Future<PersonalAgentOfferResult> _waitForOffer({
    required String setupId,
    required String holderDid,
    required String contextName,
    required String agentDisplayName,
  }) async {
    final sdk = await _loadSdk();
    final offerLabel =
        contextName.trim().toLowerCase() == AgentContext.work.setupContextName
        ? 'Work AI'
        : 'Personal AI';
    var currentSetupId = setupId;
    const maxAttempts = 12;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final offer = await sdk.fetchPersonalAgentOffer(
          setupId: currentSetupId,
        );
        final status = offer.status;
        final hasMnemonic = offer.mnemonic?.trim().isNotEmpty ?? false;
        _logger.info(
          'Waiting for offer (attempt $attempt/$maxAttempts): '
          'status=$status hasMnemonic=$hasMnemonic',
          name: _logKey,
        );
        if (hasMnemonic || status == 'inaugurated' || status == 'ready') {
          return offer;
        }
      } on VtaClientException catch (error) {
        final body = (error.body ?? '').toLowerCase();
        final message = error.message.toLowerCase();
        final unknownSetup =
            error.statusCode == 404 ||
            body.contains('unknown setup_id') ||
            message.contains('unknown setup_id');
        _logger.warning(
          'Offer fetch attempt $attempt/$maxAttempts failed: '
          'statusCode=${error.statusCode} unknownSetup=$unknownSetup '
          'message=${error.message}',
          name: _logKey,
        );
        if (unknownSetup) {
          try {
            final refreshed = await sdk.ensurePersonalAgentSetup(
              request: PersonalAgentSetupRequest(
                holderDid: holderDid,
                contextName: contextName,
                agentDisplayName: agentDisplayName,
              ),
            );
            final refreshedSetupId = refreshed.setupId?.trim();
            if (refreshedSetupId != null && refreshedSetupId.isNotEmpty) {
              _logger.info(
                'Refreshed setup id after unknown setup_id: '
                '${_redact(refreshedSetupId)}',
                name: _logKey,
              );
              currentSetupId = refreshedSetupId;
            }
          } catch (refreshError) {
            // Best effort; continue polling using the last known setup id.
            _logger.warning(
              'Setup id refresh failed, continuing with last known id: '
              '$refreshError',
              name: _logKey,
            );
          }
        }
        // Backend may still be preparing offer state; keep polling briefly.
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    }

    _logger.error(
      'Timed out waiting for $offerLabel offer details after '
      '$maxAttempts attempts.',
      name: _logKey,
    );
    throw StateError('Timed out waiting for $offerLabel offer details.');
  }

  Future<bool> _waitForPersonalAiContact({
    String? channelDid,
    String? offerLink,
    int maxAttempts = 20,
    Duration pollEvery = const Duration(milliseconds: 500),
  }) async {
    final normalizedChannelDid = channelDid?.trim();
    final normalizedOfferLink = offerLink?.trim();
    if ((normalizedChannelDid == null || normalizedChannelDid.isEmpty) &&
        (normalizedOfferLink == null || normalizedOfferLink.isEmpty)) {
      return false;
    }

    final contactsService = _ref.read(contactsServiceProvider.notifier);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await contactsService.fetchContacts();
      final contactsState = _ref.read(contactsServiceProvider);
      final foundByOffer =
          normalizedOfferLink != null &&
          normalizedOfferLink.isNotEmpty &&
          contactsState.getContactByOfferLink(normalizedOfferLink) != null;
      final foundByChannel =
          normalizedChannelDid != null &&
          normalizedChannelDid.isNotEmpty &&
          contactsState.getContactByChannelDid(normalizedChannelDid) != null;
      if (foundByOffer || foundByChannel) {
        return true;
      }

      await Future<void>.delayed(pollEvery);
    }

    return false;
  }

  Future<void> _ensurePersonalAiContact(
    PersonalAgentSetupResult result, {
    String? preferredChannelDid,
    String? offerLink,
    required bool isInitialSetup,
  }) async {
    final contactsService = _ref.read(contactsServiceProvider.notifier);
    await contactsService.ensureInitialized();

    final routingState = _ref.read(contextRoutingServiceProvider);
    final targetContext = agentContextForSetup(
      contextId: result.contextId,
      displayName: result.profile.displayName,
    );
    final normalizedPreferred = preferredChannelDid?.trim();
    final resolvedOfferLink =
        offerLink ?? await _resolveOfferLinkForChannelDid(normalizedPreferred);

    var currentContact = findPersonalAiContactForContext(
      contacts: _ref.read(contactsServiceProvider).contacts,
      contactContexts: routingState.contactContexts,
      targetContext: targetContext,
      offerLink: resolvedOfferLink,
      channelDid: normalizedPreferred,
    );

    if (currentContact == null) {
      await _ensurePersonalAiContactFromChannel(
        normalizedPreferred,
        offerLink: resolvedOfferLink,
      );

      currentContact = findPersonalAiContactForContext(
        contacts: _ref.read(contactsServiceProvider).contacts,
        contactContexts: routingState.contactContexts,
        targetContext: targetContext,
        offerLink: resolvedOfferLink,
        channelDid: normalizedPreferred,
      );
      if (currentContact == null) {
        return;
      }
    }

    if (isAiContactBoundToOtherContext(
      contact: currentContact,
      targetContext: targetContext,
      contactContexts: routingState.contactContexts,
    )) {
      return;
    }

    final normalizedOfferLink = resolvedOfferLink?.trim();
    if (normalizedOfferLink != null &&
        normalizedOfferLink.isNotEmpty &&
        currentContact.offerLink != normalizedOfferLink) {
      return;
    }

    if (isEstablishedPersonalAiContact(
      contact: currentContact,
      targetContext: targetContext,
      contactContexts: routingState.contactContexts,
    )) {
      if (!isInitialSetup) {
        await _ref
            .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
            .assignContactContext(currentContact.id, targetContext);
        return;
      }
    }

    final desiredName = result.profile.displayName.trim();
    final needsCategoryUpdate =
        currentContact.category != ContactCategory.robot;
    final needsNameUpdate = shouldRenamePersonalAiContact(
      contact: currentContact,
      desiredName: desiredName,
      isInitialSetup: isInitialSetup,
    );
    final shouldMarkPending =
        isInitialSetup &&
        needsCategoryUpdate &&
        currentContact.status == ContactStatus.active;

    if (!needsNameUpdate && !shouldMarkPending && !needsCategoryUpdate) {
      await _ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .assignContactContext(currentContact.id, targetContext);
      return;
    }

    final updatedContact = currentContact.copyWith(
      status: shouldMarkPending
          ? ContactStatus.pendingInauguration
          : currentContact.status,
      displayName: needsNameUpdate ? desiredName : currentContact.displayName,
      category: needsCategoryUpdate
          ? ContactCategory.robot
          : currentContact.category,
      card: needsNameUpdate
          ? currentContact.card.copyWith(
              displayName: desiredName,
              firstName: desiredName,
            )
          : currentContact.card,
    );
    await contactsService.updateContact(updatedContact);

    await _ref
        .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
        .assignContactContext(updatedContact.id, targetContext);
  }

  Future<String?> _resolveOfferLinkForChannelDid(String? channelDid) async {
    final normalized = channelDid?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    final channel =
        await coreSdk.getChannelByOtherPartyPermanentDid(normalized) ??
        await coreSdk.getChannelByDid(normalized);
    final offerLink = channel?.offerLink.trim();
    if (offerLink == null || offerLink.isEmpty) {
      return null;
    }
    return offerLink;
  }

  Future<bool> _canReuseConnectedOffer({
    required PersonalAgentSetupResult result,
    required PersonalAgentOfferResult offer,
  }) async {
    final channelDid = offer.channelDid?.trim();
    if (channelDid == null || channelDid.isEmpty) {
      return false;
    }

    final offerLink = await _resolveOfferLinkForChannelDid(channelDid);
    if (offerLink == null) {
      return false;
    }

    final targetContext = agentContextForSetup(
      contextId: result.contextId,
      displayName: result.profile.displayName,
    );
    final contactsState = _ref.read(contactsServiceProvider);
    final routingState = _ref.read(contextRoutingServiceProvider);
    final existingContact = contactsState.getContactByOfferLink(offerLink);
    if (existingContact == null) {
      return true;
    }

    return !isAiContactBoundToOtherContext(
      contact: existingContact,
      targetContext: targetContext,
      contactContexts: routingState.contactContexts,
    );
  }

  Future<void> _ensurePersonalAiContactFromChannel(
    String? channelDid, {
    String? offerLink,
  }) async {
    final normalized = channelDid?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }

    final contactsService = _ref.read(contactsServiceProvider.notifier);
    await contactsService.ensureInitialized();

    final contactsState = _ref.read(contactsServiceProvider);
    final normalizedOfferLink = offerLink?.trim();
    if (normalizedOfferLink != null &&
        normalizedOfferLink.isNotEmpty &&
        contactsState.getContactByOfferLink(normalizedOfferLink) != null) {
      return;
    }

    final existingByChannelDid = contactsState.getContactByChannelDid(
      normalized,
    );
    if (existingByChannelDid != null) {
      if (normalizedOfferLink == null ||
          normalizedOfferLink.isEmpty ||
          existingByChannelDid.offerLink == normalizedOfferLink) {
        return;
      }
    }

    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    final channel =
        await coreSdk.getChannelByOtherPartyPermanentDid(normalized) ??
        await coreSdk.getChannelByDid(normalized);
    if (channel != null) {
      await contactsService.updateContactFromChannelActivity(channel);
    }
  }

  Future<void> refreshAuthorizationSnapshotForChannel(
    String channelDid, {
    bool suppressErrors = true,
  }) async {
    final normalized = channelDid.trim();
    if (!_environment.personalAiEnabled || normalized.isEmpty) {
      return;
    }

    final setups = state.setupResultsByContext.values.toList();
    for (final setup in setups) {
      final contextName = canonicalPersonalAiContextName(
        contextId: setup.contextId,
        displayName: setup.profile.displayName,
      );

      final setupResultForContext = state.getSetupResultForContext(contextName);
      if (setupResultForContext == null) {
        continue;
      }

      final contact = await _findContactForSetup(setupResultForContext);
      if (contact?.channelDid == normalized) {
        await _refreshAuthorizationSnapshotForSetup(
          setupResultForContext,
          preferredChannelDid: normalized,
          suppressErrors: suppressErrors,
        );
        return;
      }
    }
  }

  Future<void> _refreshAuthorizationSnapshotForSetup(
    PersonalAgentSetupResult setupResult, {
    String? preferredChannelDid,
    bool suppressErrors = true,
  }) async {
    final sdk = await _loadSdk();
    final setupId = setupResult.setupId?.trim();
    if (setupId == null || setupId.isEmpty) {
      return;
    }

    Contact? contact;
    try {
      contact = await _findContactForSetup(
        setupResult,
        preferredChannelDid: preferredChannelDid,
      );
      if (contact == null) {
        return;
      }

      final sdkSnapshot = await sdk.fetchPersonalAgentAuthorizationSnapshot(
        setupId: setupId,
      );
      final snapshot = PersonalAiAuthorizationSnapshot.fromSdk(sdkSnapshot);
      final encoded = snapshot.toEncodedJson();
      if (contact.personalAgentAuthorizationSnapshot == encoded) {
        return;
      }

      final updatedContact = contact.copyWith(
        personalAgentAuthorizationSnapshot: encoded,
      );
      await _ref
          .read(contactsServiceProvider.notifier)
          .updateContact(updatedContact);
    } catch (_) {
      if (!suppressErrors) {
        rethrow;
      }
      // Authorization refresh is best-effort and must never block chat/setup.
    }
  }

  Future<Contact?> _findContactForSetup(
    PersonalAgentSetupResult setupResult, {
    String? preferredChannelDid,
  }) async {
    final sdk = await _loadSdk();
    final routingState = _ref.read(contextRoutingServiceProvider);
    final contactsState = _ref.read(contactsServiceProvider);
    final targetContext = agentContextForSetup(
      contextId: setupResult.contextId,
      displayName: setupResult.profile.displayName,
    );

    final setupId = setupResult.setupId?.trim();
    String? offerLink;
    var channelDid = preferredChannelDid?.trim();
    if (setupId != null && setupId.isNotEmpty) {
      try {
        final offer = await sdk.fetchPersonalAgentOffer(setupId: setupId);
        offerLink = await _resolveOfferLinkForChannelDid(offer.channelDid);
        channelDid ??= offer.channelDid?.trim();
      } catch (_) {
        // Continue with local-contact resolution.
      }
    }

    return findPersonalAiContactForContext(
      contacts: contactsState.contacts,
      contactContexts: routingState.contactContexts,
      targetContext: targetContext,
      offerLink: offerLink,
      channelDid: channelDid,
    );
  }

  String _redact(String value) {
    if (value.isEmpty) return '(empty)';
    if (value.length <= 12) return '${value.substring(0, 3)}...';
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }
}

class _PersonalAiLifecycleObserver extends WidgetsBindingObserver {
  _PersonalAiLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
