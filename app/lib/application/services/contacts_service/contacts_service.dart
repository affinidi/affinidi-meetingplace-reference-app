import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_category.dart';
import '../../../domain/models/contacts/contact_origin.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../domain/models/contacts/contact_type.dart';
import '../../../domain/repositories/contacts_repository.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/did_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/contacts_repository_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../chat_service/open_chat_registry.dart';
import '../connections_service/connections_service.dart';
import '../control_plane_service/control_plane_service.dart';
import 'contacts_service_state.dart';

part 'contacts_service.g.dart';

/// Service responsible for managing contacts derived from channels and offers.
///
/// This service provides functionality to:
/// - Create contacts from invitation accepted events and approved offers
/// - Update contacts when a channel is inaugurated
/// - Persist, fetch, add, update and delete contacts via a repository
/// - Maintain contact-specific state such as badge counts and card updates
///
/// The service listens to control plane events to automatically create/update
/// contacts and exposes streams for processing and contact-card updates.
@Riverpod(keepAlive: true)
class ContactsService extends _$ContactsService {
  ContactsService() : super();
  static const _logKey = 'CTXSVC';

  late final AppLogger _logger = ref.read(appLoggerProvider);

  ContactsRepository? _repository;

  final StreamController<String> _contactCardUpdatedController =
      StreamController<String>.broadcast();
  Stream<String> get onContactCardUpdated =>
      _contactCardUpdatedController.stream;

  final StreamController<sdk.Channel> _contactLeftChatController =
      StreamController<sdk.Channel>.broadcast();
  Stream<sdk.Channel> get onContactLeftChat =>
      _contactLeftChatController.stream;

  @override
  ContactsServiceState build() {
    final controlPlaneNotifier = ref.read(controlPlaneServiceProvider.notifier);
    controlPlaneNotifier.onInvitationAccepted.listen((channel) {
      Future.microtask(() => _createContactFromInvitationAccepted(channel));
    });

    controlPlaneNotifier.onGroupInvitationAccepted.listen((channel) {
      Future.microtask(
        () => _updateContactFromGroupInvitationAccepted(channel),
      );
    });

    controlPlaneNotifier.onConnectionOfferApproved.listen((channel) {
      Future.microtask(() => _createContactFromOfferApproved(channel));
    });

    controlPlaneNotifier.onChannelActivity.listen((channel) {
      Future.microtask(() => updateContactFromChannelActivity(channel));
    });

    ref.listen(
      meetingPlaceSdkProvider,
      (_, next) => _bindToCallSignals(next.value),
      fireImmediately: true,
    );

    return ContactsServiceState(contacts: []);
  }

  StreamSubscription<CallSignal>? _callSignalSub;

  /// Channel DIDs already credited with a missed-call badge bump for their
  /// current unread episode.
  ///
  /// A single missed/declined call can surface more than one decline signal on
  /// this device — for example when the local user is busy and the SDK
  /// auto-rejects a competing incoming call (call glare): the losing caller's
  /// decline can be observed alongside the auto-reject, so a naive per-signal
  /// bump over-counts and the contact badge exceeds its single call chat item.
  /// Tracking credited contacts keeps the bump idempotent per episode; the
  /// entry is cleared in [resetContactBadgeCount] when the chat is opened, so a
  /// later call counts again.
  final Set<String> _missedCallCreditedChannelDids = {};

  /// Subscribes to call signals so the unread badge for an unanswered outgoing
  /// call is owned here, next to the other channel-event handlers, rather than
  /// bumped by the call UI.
  ///
  /// A [CallDeclineSignal] is only ever received by the caller: the recipient
  /// emits it, both on an explicit decline and on ring timeout. So receiving
  /// one always means this device's outgoing call went unanswered.
  void _bindToCallSignals(MeetingPlaceMatrixSDK? sdk) {
    if (sdk == null) return;
    _callSignalSub?.cancel();
    _callSignalSub = sdk.callSignals.listen((signal) {
      if (signal is CallDeclineSignal) {
        Future.microtask(
          () => _recordDeclinedOutgoingCall(signal.ownChannelDid),
        );
      }
    });
    ref.onDispose(() => _callSignalSub?.cancel());
  }

  /// Bumps the contact's unread badge for an unanswered outgoing call.
  ///
  /// [ownChannelDid] is the local channel DID carried by the decline signal; it
  /// is mapped to the contact through the channel's other-party DID.
  Future<void> _recordDeclinedOutgoingCall(String ownChannelDid) async {
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByDid(ownChannelDid);
    final otherPartyDid = channel?.otherPartyPermanentChannelDid;
    if (otherPartyDid == null) {
      _logger.warning(
        '_recordDeclinedOutgoingCall: no channel for $ownChannelDid',
        name: _logKey,
      );
      return;
    }
    await incrementMissedCallBadge(otherPartyDid);
  }

  Future<void>? initializing;
  Future<void> ensureInitialized() async {
    initializing ??= fetchContacts();
    await initializing;
  }

  /// Create or update a contact when a channel is inaugurated.
  ///
  /// If a contact matching the channel's offer link exists, update its status
  /// and badge count. Otherwise attempt to build a new Contact from the
  /// channel and persist it.
  ///
  /// [channel] - The inaugurated channel used to create/update the contact.
  ///
  /// Returns:
  /// - `Future<void>` completes when the contact is created or updated.
  ///
  /// Throws [AppException] if:
  /// - Unable to extract a contact from the channel when one does not exist.
  Future<void> updateContactFromChannelActivity(sdk.Channel channel) async {
    _logger.info(
      'Channel inaugurated - creating/updating contact for channel: ${channel.permanentChannelDid}',
      name: _logKey,
    );

    final existingContact = state.getContactByChannelDid(
      channel.otherPartyPermanentChannelDid!,
    );
    if (existingContact == null) {
      _logger.info(
        'Contact does not exist - creating new contact',
        name: _logKey,
      );
      final contact = await _makeContactFromChannel(
        channel,
        ContactStatus.active,
      );
      if (contact == null) {
        throw AppException(
          'Unable to extract a contact from the channel',
          code: AppExceptionType.missingContactCard.name,
        );
      }
      _logger.info(
        'Creating contact with contact: ${contact.card.displayName}',
        name: _logKey,
      );
      await addContact(contact);
      _logger.info(
        'Contact created successfully: ${contact.card.displayName}',
        name: _logKey,
      );
    } else {
      _logger.info(
        'Existing contact found, updating status to active',
        name: _logKey,
      );

      final calculatedBadgeCount =
          channel.seqNo - existingContact.currentMessageSeqNo;
      final persistedContact = await _getPersistedContactByChannelDid(
        channel.otherPartyPermanentChannelDid!,
      );
      final updatedContact = existingContact.copyWith(
        status: ContactStatus.active,
        badgeCount:
            max(0, calculatedBadgeCount) + existingContact.missedCallCount,
        badgeUpdateInProgress: false,
        pendingMissedCallAt:
            persistedContact?.pendingMissedCallAt ??
            existingContact.pendingMissedCallAt,
      );
      await updateContact(updatedContact);
    }
  }

  /// Build a Contact model from a channel if possible.
  ///
  /// Extracts contact card and metadata from [channel]
  /// and constructs a Contact.
  ///
  /// [channel] - The channel to convert into a Contact.
  ///
  /// Returns:
  /// - `Contact?` the constructed contact, or `null` if the channel
  ///  lacks a contact card.
  Future<Contact?> _makeContactFromChannel(
    sdk.Channel channel,
    ContactStatus status,
  ) async {
    final sourceCard = channel.type == sdk.ChannelType.group
        ? channel.contactCard
        : channel.otherPartyContactCard;
    if (sourceCard == null) return null;

    final displayName = await _getGroupOfferNameFromChannel(channel);
    final domainCard = ContactCardUtils.fromSdkContactCard(sourceCard);
    final category = channel.isGroup
        ? ContactCategory.group
        : ContactCategory.fromContactCardType(
            channel.otherPartyContactCard?.type,
          );

    final origin = ContactOrigin.from(channel.type);
    return Contact(
      id: const Uuid().v4(),
      channelDid: channel.otherPartyPermanentChannelDid,
      channelDidSha256: channel.otherPartyPermanentChannelDid?.toDidSha256,
      offerLink: channel.offerLink,
      card: domainCard,
      displayName: displayName,
      dateAdded: clock.now(),
      mediatorDid: channel.mediatorDid,
      type: ContactType.from(channel.type),
      status: status,
      origin: origin,
      category: category,
      notificationBannerDismissed: origin != ContactOrigin.directInteractive,
    );
  }

  Future<String?> _getGroupOfferNameFromChannel(sdk.Channel channel) async {
    if (channel.type != sdk.ChannelType.group) {
      return null;
    }

    return ref
        .read(connectionsServiceProvider)
        .getConnectionByOfferLink(channel.offerLink)
        ?.offerName;
  }

  /// Load contacts from the repository into state.
  ///
  /// Ensures the repository is initialized then lists persisted contacts and
  /// updates provider state.
  ///
  /// Returns:
  /// - `Future<void>` completes when contacts have been loaded into state.
  Future<void> fetchContacts() async {
    _logger.info('Starting contacts fetch operation', name: _logKey);

    try {
      _repository ??= await _ensureRepositoryInitialized();
      _logger.info('Repository ready, fetching contacts', name: _logKey);

      final contacts = await _repository!.listContacts();
      _logger.info(
        'Retrieved ${contacts.length} contacts from repository',
        name: _logKey,
      );

      final totalBadgeCount = contacts.fold(
        0,
        (sum, contact) => sum + contact.badgeCount,
      );

      state = state.copyWith(contacts: contacts);
      _logger.info(
        'Contacts state updated successfully - '
        'total: ${contacts.length}, '
        'badgeCount: $totalBadgeCount',
        name: _logKey,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to fetch contacts',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  /// Persist a new contact and refresh state.
  ///
  /// [contact] - The Contact to persist.
  ///
  /// Returns:
  /// - `Future<void>` completes when the contact is stored and state refreshed.
  Future<void> addContact(Contact contact) async {
    _repository ??= await _ensureRepositoryInitialized();
    await _repository!.addContact(contact);
    await fetchContacts();
  }

  /// Delete contacts (soft then hard) and refresh state.
  ///
  /// Performs a visual soft-delete by setting status to `deleted`, refreshes
  /// state, waits briefly, then removes the record from the repository and
  /// refreshes again.
  ///
  /// [contacts] - The contact/s to delete.
  ///
  /// Returns:
  /// - `Future<void>` completes when the delete operations and refresh finish.
  Future<void> deleteContacts(List<Contact> contacts) async {
    if (contacts.isEmpty) return;

    await _markContactsAsDeleted(contacts);
    await fetchContacts();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    await _permanentlyDeleteContacts(contacts);
    await fetchContacts();
  }

  /// Mark multiple contacts as deleted (for visual
  /// feedback) without actually deleting them
  Future<void> _markContactsAsDeleted(List<Contact> contacts) async {
    _repository ??= await _ensureRepositoryInitialized();

    for (final contact in contacts) {
      final deletedContact = contact.copyWith(status: ContactStatus.deleted);
      await _repository!.updateContact(deletedContact);
    }
  }

  /// Actually delete a contact that's already marked as deleted
  Future<void> _permanentlyDeleteContacts(List<Contact> contacts) async {
    _repository ??= await _ensureRepositoryInitialized();

    for (final contact in contacts) {
      await _leaveChat(contact);
      await _repository!.deleteContact(contact);
    }
  }

  Future<void> _leaveChat(Contact contact) async {
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      contact.channelDid!,
    );
    if (channel == null) {
      throw AppException(
        'Should have received a channel',
        code: AppExceptionType.missingChannel.name,
      );
    }

    await coreSdk.leaveChannel(channel);
    _contactLeftChatController.add(channel);
  }

  /// Update an existing contact and refresh state.
  ///
  /// [contact] - The contact to update.
  ///
  /// Returns:
  /// - `Future<void>` completes when the update and refresh finish.
  Future<void> updateContact(
    Contact contact, {
    bool preservePendingMissedCallState = true,
  }) async {
    _repository ??= await _ensureRepositoryInitialized();
    final mergedContact = preservePendingMissedCallState
        ? await _mergeContactForPersistence(contact)
        : contact;
    await _repository!.updateContact(mergedContact);
    await fetchContacts();
  }

  /// Preserves durable contact state that should survive concurrent stale
  /// writes from unrelated contact-update flows.
  Future<Contact> _mergeContactForPersistence(Contact contact) async {
    final channelDid = contact.channelDid;
    if (channelDid == null) return contact;

    final persistedContact = await _getPersistedContactByChannelDid(channelDid);
    if (persistedContact?.pendingMissedCallAt == null ||
        contact.pendingMissedCallAt != null) {
      return contact;
    }

    _logger.info(
      '_mergeContactForPersistence: preserving pendingMissedCallAt for '
      '${contact.id}',
      name: _logKey,
    );
    return contact.copyWith(
      pendingMissedCallAt: persistedContact!.pendingMissedCallAt,
    );
  }

  /// Update the contact card for a contact identified by channel DID.
  ///
  /// This method updates the in-memory state and schedules a repository update
  /// asynchronously. Also emits a `onContactCardUpdated` event with the DID.
  ///
  /// [did] - Channel DID identifying the contact to update.
  /// [card] - New ContactCard to set on the contact.
  void updateContactCard(String did, ContactCard card) async {
    final contact = state.getContactByChannelDid(did);
    if (contact == null) {
      return;
    }
    final amendedContact = contact.copyWith(card: card);
    unawaited(updateContact(amendedContact));
    _contactCardUpdatedController.add(did);
  }

  /// Update the contact's last keep-alive timestamp if the new value is later.
  ///
  /// [did] - Channel DID identifying the contact.
  /// [dateTime] - New timestamp to consider.
  Future<void> updateContactLastKeepAliveMessage(
    String did,
    DateTime dateTime,
  ) async {
    final contact = state.getContactByChannelDid(did);
    if (contact == null) {
      return;
    }

    if (!(contact.lastKeepAliveMessage?.isBefore(dateTime) ?? true)) {
      return;
    }

    final amendedContact = contact.copyWith(lastKeepAliveMessage: dateTime);
    await updateContact(amendedContact);
  }

  Future<void> updateContactSequenceNumber(String did, int seqNo) async {
    final contact = state.getContactByChannelDid(did);
    if (contact == null) {
      return;
    }

    final persistedContact = await _getPersistedContactByChannelDid(did);
    final amendedContact = contact.copyWith(
      currentMessageSeqNo: seqNo,
      pendingMissedCallAt:
          persistedContact?.pendingMissedCallAt ?? contact.pendingMissedCallAt,
    );
    await updateContact(amendedContact);
  }

  /// Reset the badge count for a contact.
  ///
  /// [channelDid] - The channel DID of the contact to reset.
  ///
  /// Returns:
  /// - `Future<void>` completes when the update and refresh finish.
  Future<void> resetContactBadgeCount(String channelDid) async {
    final contact = state.getContactByChannelDid(channelDid);
    if (contact == null) {
      return;
    }

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      channelDid,
    );
    final persistedContact = await _getPersistedContactByChannelDid(channelDid);

    final amendedContact = contact.copyWith(
      badgeCount: 0,
      missedCallCount: 0,
      hasBeenOpened: true,
      currentMessageSeqNo: channel?.seqNo ?? contact.currentMessageSeqNo,
      pendingMissedCallAt:
          persistedContact?.pendingMissedCallAt ?? contact.pendingMissedCallAt,
    );
    _missedCallCreditedChannelDids.remove(channelDid);
    await updateContact(amendedContact);
  }

  /// Increment the unread badge for a missed call.
  ///
  /// Missed calls are not reflected in the channel sequence number, so they are
  /// tracked in [Contact.missedCallCount] to survive the seqNo-derived badge
  /// recompute in [updateContactFromChannelActivity]. Both the durable
  /// missed-call counter and the displayed [Contact.badgeCount] are bumped by
  /// one. Cleared together by [resetContactBadgeCount] when the chat is opened.
  ///
  /// [channelDid] - The channel DID of the contact whose call was missed.
  ///
  /// Returns:
  /// - `Future<void>` completes when the update and refresh finish.
  Future<void> incrementMissedCallBadge(String channelDid) async {
    final contact = state.getContactByChannelDid(channelDid);
    if (contact == null) {
      _logger.warning(
        'incrementMissedCallBadge: no contact for $channelDid',
        name: _logKey,
      );
      return;
    }

    // Skip the bump while the user is viewing this chat: they see the call
    // outcome on screen, and the chat's open-time reset already cleared the
    // badge, so a bump here would only linger on the contact list after they
    // navigate back.
    if (ref.read(openChatRegistryProvider.notifier).isOpen(contact.id)) {
      _logger.info(
        'incrementMissedCallBadge: chat open for ${contact.id}, skipping bump',
        name: _logKey,
      );
      return;
    }

    // Idempotent per unread episode: a single missed call can raise more than
    // one decline signal on this device (e.g. call glare while busy), so credit
    // the contact at most once until the chat is opened and the badge reset.
    if (!_missedCallCreditedChannelDids.add(channelDid)) {
      _logger.info(
        'incrementMissedCallBadge: already credited ${contact.id} this '
        'episode, skipping bump',
        name: _logKey,
      );
      return;
    }

    final amendedContact = contact.copyWith(
      missedCallCount: contact.missedCallCount + 1,
      badgeCount: contact.badgeCount + 1,
    );
    await updateContact(amendedContact);
  }

  /// Records that the current incoming call from [channelDid] was missed, so
  /// the receiver's call chat item can be reconciled to `missed` even if the
  /// caller's message has not synced yet or the app restarts before it does.
  ///
  /// Durable on [Contact.pendingMissedCallAt]; cleared by
  /// [clearPendingMissedCall] once the item is healed.
  Future<void> setPendingMissedCall(String channelDid) async {
    final contact = await _getPersistedContactByChannelDid(channelDid);
    if (contact == null) {
      _logger.error(
        'setPendingMissedCall: CRITICAL — no contact exists for $channelDid; '
        'marker cannot be written. Incoming call chat item will not be '
        'reconciled to missed on replay.',
        name: _logKey,
      );
      return;
    }
    final pendingAt = DateTime.now().toUtc();
    _logger.info(
      'setPendingMissedCall: Marked contact ${contact.id}',
      name: _logKey,
    );
    await updateContact(contact.copyWith(pendingMissedCallAt: pendingAt));
  }

  /// Clears the pending missed-call marker for [channelDid] after the call chat
  /// item has been reconciled to `missed`. A no-op when no marker is set.
  Future<void> clearPendingMissedCall(String channelDid) async {
    final contact = await _getPersistedContactByChannelDid(channelDid);
    if (contact == null || contact.pendingMissedCallAt == null) {
      return;
    }
    _logger.info(
      'clearPendingMissedCall: Unmarked contact ${contact.id}',
      name: _logKey,
    );
    await updateContact(
      contact.copyWith(pendingMissedCallAt: null),
      preservePendingMissedCallState: false,
    );
  }

  /// Returns the durable pending missed-call marker for [channelDid].
  Future<DateTime?> getPendingMissedCallAt(String channelDid) async {
    return (await _getPersistedContactByChannelDid(
      channelDid,
    ))?.pendingMissedCallAt;
  }

  /// Update an existing contact when a group invitation is accepted.
  ///
  /// Sets the contact status to pending approval and updates card/profile
  /// picture and member count.
  ///
  /// [channel] - The channel event triggering the update.
  ///
  /// Returns:
  /// - `Future<void>` completes when the contact is updated.
  ///
  /// Throws:
  /// - None. Domain validation is performed elsewhere; unexpected errors
  ///   propagate as exceptions.
  Future<void> _updateContactFromGroupInvitationAccepted(
    sdk.Channel channel,
  ) async {
    _logger.info(
      'Group invitation accepted for channel ${channel.permanentChannelDid}',
      name: _logKey,
    );

    final existingContact = channel.otherPartyPermanentChannelDid == null
        ? null
        : state.getContactByChannelDid(channel.otherPartyPermanentChannelDid!);
    if (existingContact == null) {
      _logger.warning('No existing contact found', name: _logKey);
      return;
    }

    _logger.info(
      'Existing contact found, updating status to active',
      name: _logKey,
    );
    final src = channel.otherPartyContactCard;
    final updatedContact = existingContact.copyWith(
      status: ContactStatus.pendingApproval,
      otherPartyCard: src == null
          ? null
          : ContactCard(
              id: const Uuid().v4(),
              did: src.did,
              type: src.type,
              firstName: src.firstName,
              displayName: src.fullName,
              lastName: src.lastName.isEmpty ? null : src.lastName,
              email: src.email.isEmpty ? null : src.email,
              mobile: src.mobile.isEmpty ? null : src.mobile,
              profilePic: src.profilePic.isEmpty ? null : src.profilePic,
              cardColor: src.meetingplaceIdentityCardColor.isEmpty
                  ? null
                  : src.meetingplaceIdentityCardColor,
            ),
    );
    await updateContact(updatedContact);
  }

  /// Retrieves a persisted contact by channel DID.
  Future<Contact?> _getPersistedContactByChannelDid(String channelDid) async {
    _repository ??= await _ensureRepositoryInitialized();
    final contacts = await _repository!.listContacts();
    return contacts.firstWhereOrNull((c) => c.channelDid == channelDid);
  }

  /// Create a new contact when an invitation is accepted.
  ///
  /// Extracts required data from [channel] and persists a new Contact.
  ///
  /// [channel] - Channel data from which the contact is created.
  ///
  /// Returns:
  /// - `Future<void>` completes when the contact has been added.
  ///
  /// Throws [AppException] if:
  /// - The channel does not include the other party permanent channel DID.
  /// - The channel does not include the other party contact card.
  Future<void> _createContactFromInvitationAccepted(sdk.Channel channel) async {
    _logger.info('Creating new contact with channel $channel', name: _logKey);

    if (channel.otherPartyPermanentChannelDid == null) {
      throw AppException(
        '''An invitation was accepted but did not provide the other party channel Did''',
        code: AppExceptionType.missingOtherPartyChannelDid.name,
      );
    }

    if (channel.otherPartyContactCard == null) {
      throw AppException(
        '''An invitation was accepted but did not provide their contact card''',
        code: AppExceptionType.missingOtherPartyCard.name,
      );
    }

    final contact = await _makeContactFromChannel(
      channel,
      ContactStatus.pendingApproval,
    );

    if (contact == null) {
      throw AppException(
        '''An invitation was accepted but did not provide contact details''',
        code: AppExceptionType.missingContact.name,
      );
    }

    await addContact(contact);
  }

  /// Create a new contact when a connection offer is approved.
  ///
  /// Extracts required data from [channel] and persists a new Contact with
  /// status `active`.
  ///
  /// [channel] - Channel data from which the contact is created.
  ///
  /// Returns:
  /// - `Future<void>` completes when the contact has been added.
  ///
  /// Throws [AppException] if:
  /// - The channel is missing a permanent channel DID.
  /// - The channel does not include the other party contact card.
  Future<void> _createContactFromOfferApproved(sdk.Channel channel) async {
    _logger.info(
      'Creating new contact with connection $channel',
      name: _logKey,
    );
    if (channel.permanentChannelDid == null) {
      throw AppException(
        '''An offer was approved but did not provide the permanent channel Did''',
        code: AppExceptionType.missingPermanentChannelDid.name,
      );
    }

    if (channel.otherPartyContactCard == null) {
      throw AppException(
        '''An offer was approved but did not provide their contact card''',
        code: AppExceptionType.missingOtherPartyCard.name,
      );
    }

    final contact = await _makeContactFromChannel(
      channel,
      ContactStatus.active,
    );

    if (contact == null) {
      throw AppException(
        '''An offer was approved but did not provide contact details''',
        code: AppExceptionType.missingContact.name,
      );
    }

    await addContact(contact);
  }

  /// Ensure and return the initialized contacts repository.
  ///
  /// Returns:
  /// - `Future<ContactsRepository>` the initialized repository instance.
  Future<ContactsRepository> _ensureRepositoryInitialized() async =>
      await ref.read(contactsRepositoryProvider.future);
}
