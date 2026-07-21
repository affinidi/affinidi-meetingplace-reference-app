import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_personal_agent/meeting_place_personal_agent.dart';
import 'package:vta_dart_client/vta_dart_client.dart';

import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_category.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
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

  Environment get _environment => _ref.read(environmentProvider);

  late final MeetingPlacePersonalAgentSDK _sdk =
      MeetingPlacePersonalAgentSDK.hosted(
        baseUrl: _environment.personalAiBaseUrl,
        endpoint: _environment.personalAiSetupEndpoint,
      );

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
    String? channelDid;
    String? offerLink;
    final setupId = setupResult.setupId?.trim() ?? '';
    if (setupId.isNotEmpty) {
      try {
        final offer = await _sdk.fetchPersonalAgentOffer(setupId: setupId);
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

  /// Upload the user's context file and store it as the agent's initial memory.
  Future<void> uploadContext({
    required String setupId,
    required String content,
    String setupContextName = 'personal-ai',
    String agentDisplayName = 'My Personal AI',
  }) async {
    if (!_environment.personalAiEnabled) return;
    if (state.contextUploading) return;

    state = state.copyWith(
      contextUploading: true,
      clearContextUploadError: true,
    );

    try {
      // Upload first for the common case (already connected + valid setup).
      // If setup record was lost after a backend restart, fallback to
      // re-register + retry once.
      var effectiveSetupId = setupId;
      try {
        await _sdk.uploadPersonalAgentContext(
          setupId: effectiveSetupId,
          content: content,
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

        final freshSetup = await _sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: holderDid,
            contextName: setupContextName,
            agentDisplayName: agentDisplayName,
          ),
        );
        effectiveSetupId = freshSetup.setupId ?? setupId;
        if (state.setupResult == null) {
          _updateSetupResult(freshSetup, contextName: setupContextName);
        }

        await _sdk.uploadPersonalAgentContext(
          setupId: effectiveSetupId,
          content: content,
        );
      }

      state = state.copyWith(contextProvisioned: true, contextUploading: false);
    } catch (error) {
      state = state.copyWith(
        contextUploading: false,
        contextUploadError: error.toString(),
      );
    }
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
      final status = await _sdk.fetchPersonalAgentContextStatus(
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
    String contextName = 'personal-ai',
    String agentDisplayName = 'My Personal AI',
  }) async {
    if (!_environment.personalAiEnabled) {
      return;
    }

    if (state.isSettingUp) {
      return;
    }

    final normalizedHolderDid = holderDid.trim();
    if (normalizedHolderDid.isEmpty) {
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

    try {
      final result = await _sdk.ensurePersonalAgentSetup(
        request: PersonalAgentSetupRequest(
          holderDid: normalizedHolderDid,
          contextName: contextName,
          agentDisplayName: agentDisplayName,
        ),
      );

      final offer = await _autoConnectPersonalAgent(
        result: result,
        holderDid: normalizedHolderDid,
      );

      // Refresh setup status after connect so state carries up-to-date
      // connection flags for follow-up flows (like context upload).
      var setupSnapshot = result;
      try {
        setupSnapshot = await _sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: normalizedHolderDid,
            contextName: contextName,
            agentDisplayName: agentDisplayName,
          ),
        );
      } catch (_) {
        // Keep the original setup payload if status refresh fails.
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
      state = state.copyWith(
        status: PersonalAiSetupStatus.ready,
        showSetupPrompt: false,
        promptDismissed: true,
      );

      final storage = await _ref.read(secureStorageProvider.future);
      await storage.writePersonalAiHolderDid(normalizedHolderDid);
    } catch (error) {
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
    String contextName = 'personal-ai',
    String agentDisplayName = 'My Personal AI',
    int maxAttempts = 20,
    Duration pollEvery = const Duration(seconds: 1),
  }) async {
    PersonalAgentSetupResult? latest;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        latest = await _sdk.ensurePersonalAgentSetup(
          request: PersonalAgentSetupRequest(
            holderDid: holderDid,
            contextName: contextName,
            agentDisplayName: agentDisplayName,
          ),
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

    if (latest != null) {
      _updateSetupResult(latest, contextName: contextName);
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

  Future<void> _restoreSessionAfterRestart() async {
    if (!_environment.personalAiEnabled || state.isReady || state.isSettingUp) {
      return;
    }

    try {
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

      for (final contextName in const ['work-ai', 'personal-ai']) {
        try {
          final contextResult = await _sdk.ensurePersonalAgentSetup(
            request: PersonalAgentSetupRequest(
              holderDid: currentHolderDid,
              contextName: contextName,
            ),
          );
          _updateSetupResult(contextResult, contextName: contextName);
        } catch (_) {
          // Best-effort restore for each configured context.
        }
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
    final setupId = result.setupId?.trim();
    if (setupId == null || setupId.isEmpty) {
      throw StateError('Personal AI setup did not return a setup id.');
    }

    final contextName =
        result.contextId.trim().toLowerCase().startsWith('work-ai')
        ? 'work-ai'
        : 'personal-ai';
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

    // Resumed connector sessions may report a ready/inaugurated channel with
    // no mnemonic. In that case setup is already connected and no accept-offer
    // roundtrip is required when the channel belongs to this context.
    if ((mnemonic == null || mnemonic.isEmpty) && isAlreadyConnected) {
      final canReuseChannel = await _canReuseConnectedOffer(
        result: result,
        offer: offer,
      );
      if (canReuseChannel) {
        return offer;
      }
      throw StateError(
        'AI offer reports connected but no channel is available for '
        '${result.profile.displayName.trim()}.',
      );
    }

    if (mnemonic == null || mnemonic.isEmpty) {
      throw StateError('Personal AI setup did not return an offer mnemonic.');
    }

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
    final findResult = await coreSdk.findOffer(mnemonic: mnemonic);
    if (findResult.errorCode != null) {
      throw StateError(
        'Unable to find Personal AI offer: ${findResult.errorCode}',
      );
    }
    final foundOffer = findResult.connectionOffer;
    if (foundOffer == null) {
      throw StateError('Unable to resolve Personal AI offer from mnemonic.');
    }

    final connectionsService = _ref.read(connectionsServiceProvider.notifier);
    await connectionsService.acceptOffer(foundOffer, identity: identity);

    // After accepting, wait for the connector to process inauguration and
    // write channel_did to the offer file. _waitForOffer would return
    // immediately (mnemonic still present), leaving channel_did null and
    // causing the contact name to never be set.
    return await _waitForOfferChannelDid(setupId: setupId);
  }

  /// Polls the offer until [PersonalAgentOfferResult.channelDid] is populated.
  /// Used after accepting an offer to wait for the connector's inauguration
  /// handler to write the permanent channel DID into the offer file.
  Future<PersonalAgentOfferResult> _waitForOfferChannelDid({
    required String setupId,
  }) async {
    const maxAttempts = 20;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final offer = await _sdk.fetchPersonalAgentOffer(setupId: setupId);
        final hasChannelDid = offer.channelDid?.trim().isNotEmpty ?? false;
        if (hasChannelDid) {
          return offer;
        }
      } on VtaClientException catch (_) {
        // keep polling
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    // Connector did not write channel_did in time — fall back to a plain fetch
    // so setup can still complete (name update may be deferred to next sync).
    return _sdk.fetchPersonalAgentOffer(setupId: setupId);
  }

  Future<PersonalAgentOfferResult> _waitForOffer({
    required String setupId,
    required String holderDid,
    required String contextName,
    required String agentDisplayName,
  }) async {
    var currentSetupId = setupId;
    const maxAttempts = 12;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final offer = await _sdk.fetchPersonalAgentOffer(
          setupId: currentSetupId,
        );
        final status = offer.status;
        final hasMnemonic = offer.mnemonic?.trim().isNotEmpty ?? false;
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
        if (unknownSetup) {
          try {
            final refreshed = await _sdk.ensurePersonalAgentSetup(
              request: PersonalAgentSetupRequest(
                holderDid: holderDid,
                contextName: contextName,
                agentDisplayName: agentDisplayName,
              ),
            );
            final refreshedSetupId = refreshed.setupId?.trim();
            if (refreshedSetupId != null && refreshedSetupId.isNotEmpty) {
              currentSetupId = refreshedSetupId;
            }
          } catch (_) {
            // Best effort; continue polling using the last known setup id.
          }
        }
        // Backend may still be preparing offer state; keep polling briefly.
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    }

    throw StateError('Timed out waiting for Personal AI offer details.');
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

      final sdkSnapshot = await _sdk.fetchPersonalAgentAuthorizationSnapshot(
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
        final offer = await _sdk.fetchPersonalAgentOffer(setupId: setupId);
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
