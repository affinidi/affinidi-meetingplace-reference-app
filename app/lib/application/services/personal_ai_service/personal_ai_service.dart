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
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../connections_service/connections_service.dart';
import '../contacts_service/contacts_service.dart';
import '../identities_service/identities_service.dart';
import 'personal_ai_service_state.dart';

final personalAiServiceProvider =
    StateNotifierProvider<PersonalAiService, PersonalAiServiceState>(
      PersonalAiService.new,
    );

class PersonalAiService extends StateNotifier<PersonalAiServiceState> {
  PersonalAiService(this._ref) : super(const PersonalAiServiceState.initial()) {
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
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
  }

  Future<void> refreshPersonalAiContactSync() async {
    if (!_environment.personalAiEnabled) {
      return;
    }
    final setupResult = state.setupResult;
    if (setupResult == null) {
      return;
    }
    await _waitForPersonalAiContact(
      setupResult.agentDid,
      maxAttempts: 3,
      pollEvery: const Duration(milliseconds: 300),
    );
    await _ensurePersonalAiContact(setupResult);
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

  Future<void> setupPersonalAi({required String holderDid}) async {
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
            '''Unable to set up Personal AI because the current identity is missing a DID.''',
      );
      return;
    }

    state = state.copyWith(
      status: PersonalAiSetupStatus.settingUp,
      clearErrorMessage: true,
    );

    try {
      final result = await _sdk.ensurePersonalAgentSetup(
        request: PersonalAgentSetupRequest(holderDid: normalizedHolderDid),
      );

      final offer = await _autoConnectPersonalAgent(
        result: result,
        holderDid: normalizedHolderDid,
      );

      final offerChannelDid = offer.channelDid?.trim();
      await _ensurePersonalAiContactFromChannel(offerChannelDid);
      await _waitForPersonalAiContact(
        result.agentDid,
        channelDid: offerChannelDid,
      );
      await _ensurePersonalAiContact(
        result,
        preferredChannelDid: offerChannelDid,
      );

      state = state.copyWith(
        status: PersonalAiSetupStatus.ready,
        setupResult: result,
        showSetupPrompt: false,
        promptDismissed: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: PersonalAiSetupStatus.failed,
        errorMessage: error.toString(),
      );
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

    final offer = await _waitForOffer(setupId: setupId);
    final mnemonic = offer.mnemonic?.trim();
    final status = offer.status.trim().toLowerCase();
    final isAlreadyConnected =
        status == 'inaugurated' ||
        status == 'ready' ||
        (offer.channelDid?.trim().isNotEmpty ?? false) ||
        (offer.channelId?.trim().isNotEmpty ?? false);

    // Resumed connector sessions may report a ready/inaugurated channel with
    // no mnemonic. In that case setup is already connected and no accept-offer
    // roundtrip is required.
    if ((mnemonic == null || mnemonic.isEmpty) && isAlreadyConnected) {
      return offer;
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

    final connectionsService = _ref.read(connectionsServiceProvider.notifier);
    await connectionsService.getOffer(mnemonic);

    final selectedOffer = _ref.read(connectionsServiceProvider).selectedOffer;
    if (selectedOffer == null) {
      throw StateError('Unable to resolve Personal AI offer from mnemonic.');
    }

    await connectionsService.acceptOffer(selectedOffer, identity: identity);

    return await _waitForOffer(setupId: setupId);
  }

  Future<PersonalAgentOfferResult> _waitForOffer({
    required String setupId,
  }) async {
    const maxAttempts = 12;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final offer = await _sdk.fetchPersonalAgentOffer(setupId: setupId);
        final status = offer.status;
        final hasMnemonic = offer.mnemonic?.trim().isNotEmpty ?? false;
        if (hasMnemonic || status == 'inaugurated' || status == 'ready') {
          return offer;
        }
      } on VtaClientException catch (_) {
        // Backend may not have written offer state yet; keep polling briefly.
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    }

    throw StateError('Timed out waiting for Personal AI offer details.');
  }

  Future<bool> _waitForPersonalAiContact(
    String agentDid, {
    String? channelDid,
    int maxAttempts = 20,
    Duration pollEvery = const Duration(milliseconds: 500),
  }) async {
    final normalizedAgentDid = agentDid.trim();
    final normalizedChannelDid = channelDid?.trim();
    final lookupDids = <String>{};
    if (normalizedAgentDid.isNotEmpty) {
      lookupDids.add(normalizedAgentDid);
    }
    if (normalizedChannelDid != null && normalizedChannelDid.isNotEmpty) {
      lookupDids.add(normalizedChannelDid);
    }
    if (lookupDids.isEmpty) {
      throw StateError('Personal AI setup did not return a usable DID.');
    }

    final contactsService = _ref.read(contactsServiceProvider.notifier);

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await contactsService.fetchContacts();
      final contactsState = _ref.read(contactsServiceProvider);
      final found = lookupDids.any(
        (did) => contactsState.getContactByChannelDid(did) != null,
      );
      if (found) {
        return true;
      }

      await Future<void>.delayed(pollEvery);
    }

    // Control-plane/contact propagation can be delayed (especially when app
    // notifications are not delivered in background). Do not fail setup for
    // this; we retry sync on app resume and subsequent refreshes.
    return false;
  }

  Future<void> _ensurePersonalAiContact(
    PersonalAgentSetupResult result, {
    String? preferredChannelDid,
  }) async {
    final contactsService = _ref.read(contactsServiceProvider.notifier);
    await contactsService.ensureInitialized();

    final current = _ref.read(contactsServiceProvider).contacts;
    final candidateDids = <String>{result.agentDid};
    final normalizedPreferred = preferredChannelDid?.trim();
    if (normalizedPreferred != null && normalizedPreferred.isNotEmpty) {
      candidateDids.add(normalizedPreferred);
    }

    var existing = current.where((contact) {
      final did = contact.channelDid;
      return did != null && candidateDids.contains(did);
    });
    if (existing.isEmpty) {
      // Do not create a synthetic contact before mnemonic acceptance.
      // Contacts are created/activated by real channel activity events.
      return;
    }

    final currentContact = existing.first;
    final desiredName = result.profile.displayName.trim();
    final needsNameUpdate =
        desiredName.isNotEmpty &&
        (currentContact.displayName == null ||
            currentContact.displayName!.trim().isEmpty ||
            currentContact.displayName != desiredName ||
            currentContact.card.displayName.trim().isEmpty ||
            currentContact.card.displayName != desiredName);
    final shouldMarkPending =
        currentContact.status == ContactStatus.active &&
        currentContact.category == ContactCategory.robot;

    if (!needsNameUpdate && !shouldMarkPending) {
      return;
    }

    await contactsService.updateContact(
      currentContact.copyWith(
        status: shouldMarkPending
            ? ContactStatus.pendingInauguration
            : currentContact.status,
        displayName: needsNameUpdate ? desiredName : currentContact.displayName,
        card: needsNameUpdate
            ? currentContact.card.copyWith(
                displayName: desiredName,
                firstName: desiredName,
              )
            : currentContact.card,
      ),
    );
  }

  Future<void> _ensurePersonalAiContactFromChannel(String? channelDid) async {
    final normalized = channelDid?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }

    final contactsService = _ref.read(contactsServiceProvider.notifier);
    await contactsService.ensureInitialized();

    final existing = _ref
        .read(contactsServiceProvider)
        .getContactByChannelDid(normalized);
    if (existing != null) {
      return;
    }

    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    final channel =
        await coreSdk.getChannelByOtherPartyPermanentDid(normalized) ??
        await coreSdk.getChannelByDid(normalized);
    if (channel != null) {
      await contactsService.updateContactFromChannelActivity(channel);
    }
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
