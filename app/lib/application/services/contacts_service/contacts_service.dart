import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
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

  /// Prevents concurrent contact updates from stepping on each other. Without
  /// it, a status update can wipe out the pending missed-call marker.
  final Lock _contactWriteLock = Lock();

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

    return ContactsServiceState(contacts: []);
  }

  /// Missed-call badge credits already applied for the current unread episode,
  /// keyed by contact channel DID → the set of call-item message ids counted
  /// for it.
  ///
  /// Each call has a unique call chat item message id, and its terminal
  /// (`missed`/`declined`) transition can be observed more than once (repeated
  /// upserts, reconciliation, re-sync). Counting per message id keeps a single
  /// call idempotent while letting distinct calls each count. Entries are
  /// cleared per channel in [resetContactBadgeCount] when the chat is opened,
  /// so a later call counts again.
  final Map<String, Set<String>> _creditedMissedCallIds = {};
  final Map<String, int> _openChannelReadSeqNos = {};

  /// Serializes badge-affecting read-modify-write flows so a concurrent
  /// [updateContactFromChannelActivity] recompute cannot clobber a missed-call
  /// increment (or vice versa) by writing back a value read before the other
  /// landed.
  Future<void> _badgeMutationQueue = Future<void>.value();

  Future<void> _serializeBadgeMutation(Future<void> Function() mutate) {
    final next = _badgeMutationQueue.then((_) => mutate());
    _badgeMutationQueue = next.then((_) {}, onError: (_) {});
    return next;
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

    // AI work/personal setups can share the same remote DID while using
    // different offer links. Prefer offer-link matching first to avoid
    // collapsing both contexts into a single contact.
    Contact? existingContact;
    final existingByOfferLink = state.contacts.where((contact) {
      return contact.offerLink == channel.offerLink;
    });
    if (existingByOfferLink.isNotEmpty) {
      existingContact = existingByOfferLink.first;
    } else {
      final otherPartyDid = channel.otherPartyPermanentChannelDid;
      if (otherPartyDid != null && otherPartyDid.isNotEmpty) {
        final existingByDid = state.getContactByChannelDid(otherPartyDid);
        if (existingByDid != null) {
          final remoteType = channel.otherPartyContactCard?.type
              .trim()
              .toLowerCase();
          final sameDidDifferentOffer =
              existingByDid.offerLink != channel.offerLink;
          final isAiContact =
              existingByDid.category == ContactCategory.robot ||
              remoteType == 'ai-agent';

          // For AI contacts, keep one contact per offer link (work/personal)
          // even when the remote DID is the same.
          if (!(sameDidDifferentOffer && isAiContact)) {
            existingContact = existingByDid;
          }
        }
      }
    }

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

      await _serializeBadgeMutation(() async {
        final current = state.getContactByChannelDid(
          channel.otherPartyPermanentChannelDid!,
        );
        if (current == null) return;
        final isChatOpen = ref
            .read(openChatRegistryProvider.notifier)
            .isOpen(current.id);
        // The read baseline is established once, when the contact is first
        // materialised from the channel (see [_makeContactFromChannel]): a
        // group joins with `channel.seqNo == startSeqNo`, so pre-join history
        // is already excluded from the unread delta. Post-join inbound messages
        // then advance `channel.seqNo` and must count as unread until the chat
        // is opened. While the chat is open the read position tracks the
        // channel so live messages are not badged.
        final currentMessageSeqNo = isChatOpen
            ? max(current.currentMessageSeqNo, channel.seqNo)
            : current.currentMessageSeqNo;
        if (isChatOpen) {
          _openChannelReadSeqNos[channel.otherPartyPermanentChannelDid!] =
              currentMessageSeqNo;
        }
        final calculatedBadgeCount = channel.seqNo - currentMessageSeqNo;
        final persistedContact = await _getPersistedContactByChannelDid(
          channel.otherPartyPermanentChannelDid!,
        );
        final updatedContact = current.copyWith(
          status: ContactStatus.active,
          currentMessageSeqNo: currentMessageSeqNo,
          badgeCount: max(0, calculatedBadgeCount) + current.missedCallCount,
          badgeUpdateInProgress: false,
          pendingMissedCallAt:
              persistedContact?.pendingMissedCallAt ??
              current.pendingMissedCallAt,
          pendingMissedCallId:
              persistedContact?.pendingMissedCallId ??
              current.pendingMissedCallId,
        );
        await updateContact(updatedContact, preserveBadgeState: false);
      });
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
      // Baseline the read position to the channel's current seqNo at creation
      // so a freshly materialised contact does not count pre-existing channel
      // history as unread. Group channels are created with a non-zero seqNo
      // (the group's message history at join time); without this baseline the
      // whole backlog inflates the unread badge on the first channel-activity
      // recompute. Individual channels start at seqNo 0, so they are
      // unaffected.
      currentMessageSeqNo: channel.seqNo,
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
    bool preserveBadgeState = true,
  }) async {
    _repository ??= await _ensureRepositoryInitialized();
    await _contactWriteLock.synchronized(() async {
      final mergedContact = await _mergeContactForPersistence(
        contact,
        preservePendingMissedCallState: preservePendingMissedCallState,
        preserveBadgeState: preserveBadgeState,
      );
      await _repository!.updateContact(mergedContact);
    });
    await fetchContacts();
  }

  /// Preserves durable contact state that should survive concurrent stale
  /// writes from unrelated contact-update flows.
  Future<Contact> _mergeContactForPersistence(
    Contact contact, {
    required bool preservePendingMissedCallState,
    required bool preserveBadgeState,
  }) async {
    final channelDid = contact.channelDid;
    if (channelDid == null) return contact;
    if (!preservePendingMissedCallState && !preserveBadgeState) return contact;

    final persistedContact = await _getPersistedContactByChannelDid(channelDid);
    if (persistedContact == null) return contact;

    var mergedContact = contact;
    if (preservePendingMissedCallState &&
        persistedContact.pendingMissedCallAt != null &&
        (contact.pendingMissedCallAt == null ||
            contact.pendingMissedCallId == null)) {
      _logger.info(
        '_mergeContactForPersistence: preserving pending missed-call state for '
        '${contact.id}',
        name: _logKey,
      );
      mergedContact = mergedContact.copyWith(
        pendingMissedCallAt: persistedContact.pendingMissedCallAt,
        pendingMissedCallId: persistedContact.pendingMissedCallId,
      );
    }

    if (preserveBadgeState &&
        (persistedContact.badgeCount != contact.badgeCount ||
            persistedContact.missedCallCount != contact.missedCallCount)) {
      _logger.info(
        '_mergeContactForPersistence: preserving badge state for ${contact.id}',
        name: _logKey,
      );
      mergedContact = mergedContact.copyWith(
        badgeCount: persistedContact.badgeCount,
        missedCallCount: persistedContact.missedCallCount,
      );
    }

    return mergedContact;
  }

  /// Update the contact card for a contact identified by channel DID.
  ///
  /// This method updates the in-memory state and schedules a repository update
  /// asynchronously. Also emits a `onContactCardUpdated` event with the DID.
  ///
  /// [did] - Channel DID identifying the contact to update.
  /// [card] - New ContactCard to set on the contact.
  void updateContactCard(String did, ContactCard card) async {
    final contact =
        state.getContactByChannelDid(did) ?? state.getContactByCardDid(did);
    if (contact == null) {
      return;
    }
    final amendedContact = contact.copyWith(card: card);
    unawaited(
      updateContact(amendedContact).then((_) => notifyContactCardUpdated(did)),
    );
  }

  /// Notify listeners that a contact card has been updated.
  ///
  /// This emits a signal on [onContactCardUpdated] stream with the DID of the
  /// contact whose card was updated. Used by active call controllers to refresh
  /// mid-call member profile pictures.
  ///
  /// [did] - The contact DID that was updated.
  void notifyContactCardUpdated(String did) {
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

    final amendedContact = contact.copyWith(currentMessageSeqNo: seqNo);
    await updateContact(amendedContact);
  }

  /// Marks the channel as read up to its current sequence number when the chat
  /// closes, so activity observed while the chat was open that does not flow
  /// through the message sequence-number path is not recounted as unread after
  /// leaving.
  ///
  /// Incoming chat messages advance [Contact.currentMessageSeqNo] via
  /// [updateContactSequenceNumber] while the chat is open, but call chat items
  /// (ringing/calling/declined/missed) and their reconciliation updates do not,
  /// even though they still advance the channel sequence number. Without this
  /// sync, a call that is the last activity before the user leaves the chat
  /// leaks into the seqNo-derived unread count on the next channel-activity
  /// recompute (e.g. a single later text shows +2). The badge itself is left
  /// untouched: it is already cleared on chat open and only recomputed on the
  /// next channel activity, which reads the synced sequence number.
  Future<void> syncChannelReadSeqNo(String channelDid) async {
    final readSeqNo = _openChannelReadSeqNos.remove(channelDid);
    if (readSeqNo == null) return;
    await _syncChannelReadSeqNoTo(channelDid, readSeqNo);
  }

  Future<void> syncOpenChannelReadSeqNo(String channelDid) async {
    if (!ref.mounted) return;
    if (state.getContactByChannelDid(channelDid) == null) return;
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    if (!ref.mounted) return;
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      channelDid,
    );
    if (channel == null || !ref.mounted) return;
    final readSeqNo = channel.seqNo;
    _openChannelReadSeqNos.update(
      channelDid,
      (current) => max(current, readSeqNo),
      ifAbsent: () => readSeqNo,
    );
    await _syncChannelReadSeqNoTo(channelDid, readSeqNo);
  }

  Future<void> _syncChannelReadSeqNoTo(String channelDid, int readSeqNo) async {
    if (!ref.mounted) return;
    if (state.getContactByChannelDid(channelDid) == null) return;
    await _serializeBadgeMutation(() async {
      if (!ref.mounted) return;
      final current = state.getContactByChannelDid(channelDid);
      if (current == null) return;
      if (current.currentMessageSeqNo >= readSeqNo) return;
      final persistedContact = await _getPersistedContactByChannelDid(
        channelDid,
      );
      if (!ref.mounted) return;
      await updateContact(
        current.copyWith(
          currentMessageSeqNo: readSeqNo,
          pendingMissedCallAt:
              persistedContact?.pendingMissedCallAt ??
              current.pendingMissedCallAt,
          pendingMissedCallId:
              persistedContact?.pendingMissedCallId ??
              current.pendingMissedCallId,
        ),
      );
    });
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

    final amendedContact = contact.copyWith(
      badgeCount: 0,
      missedCallCount: 0,
      hasBeenOpened: true,
      currentMessageSeqNo: channel?.seqNo ?? contact.currentMessageSeqNo,
    );
    _openChannelReadSeqNos[channelDid] = amendedContact.currentMessageSeqNo;
    _creditedMissedCallIds.remove(channelDid);
    await updateContact(amendedContact, preserveBadgeState: false);
  }

  /// Increment the unread badge for a missed call, counted once per [callId].
  ///
  /// Missed calls are tracked separately from message seqNo so delayed terminal
  /// call updates can be counted idempotently and survive the seqNo-derived
  /// badge recompute in [updateContactFromChannelActivity]. Both the durable
  /// missed-call counter and the displayed [Contact.badgeCount] are bumped by
  /// one. Cleared together by [resetContactBadgeCount] when the chat is opened.
  ///
  /// [channelDid] - The channel DID of the contact whose call was missed.
  /// [callId] - A unique dedup key for this call episode. Counting per id keeps
  /// a single call idempotent across repeated terminal transitions, while
  /// distinct calls each count.
  ///
  /// Returns:
  /// - `Future<void>` completes when the update and refresh finish.
  Future<void> incrementMissedCallBadge(
    String channelDid, {
    required String callId,
  }) async {
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

    // Count each call once, keyed by its call-item message id: the terminal
    // transition can be observed more than once (repeated upserts, re-sync).
    // Distinct calls carry distinct ids, so each still counts.
    final creditedForChannel = _creditedMissedCallIds.putIfAbsent(
      channelDid,
      () => <String>{},
    );
    if (!creditedForChannel.add(callId)) {
      _logger.info(
        'incrementMissedCallBadge: already credited ${contact.id} call '
        '$callId this episode, skipping bump',
        name: _logKey,
      );
      return;
    }

    await _serializeBadgeMutation(() async {
      final current = state.getContactByChannelDid(channelDid);
      if (current == null) return;
      final amendedContact = current.copyWith(
        missedCallCount: current.missedCallCount + 1,
        badgeCount: current.badgeCount + 1,
      );
      await updateContact(amendedContact, preserveBadgeState: false);
    });
  }

  /// Records that the current incoming call from [channelDid] was missed, so
  /// the recipient's call chat item can be reconciled to `missed` even if the
  /// caller's message has not synced yet or the app restarts before it does.
  ///
  /// Durable on [Contact.pendingMissedCallAt]; cleared by
  /// [clearPendingMissedCall] once the item is healed.
  Future<void> setPendingMissedCall(String channelDid, {String? callId}) async {
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
    await updateContact(
      contact.copyWith(
        pendingMissedCallAt: pendingAt,
        pendingMissedCallId: callId,
      ),
    );
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
      contact.copyWith(pendingMissedCallAt: null, pendingMissedCallId: null),
      preservePendingMissedCallState: false,
    );
  }

  /// Returns the durable pending missed-call marker for [channelDid].
  Future<DateTime?> getPendingMissedCallAt(String channelDid) async {
    return (await _getPersistedContactByChannelDid(
      channelDid,
    ))?.pendingMissedCallAt;
  }

  /// Returns the transport call ID stored in the durable missed-call marker
  /// for [channelDid], or `null` if not set.
  Future<String?> getPendingMissedCallId(String channelDid) async {
    return (await _getPersistedContactByChannelDid(
      channelDid,
    ))?.pendingMissedCallId;
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

    final existing = _findExistingContactForChannel(channel);
    if (existing != null) {
      await updateContact(
        existing.copyWith(
          channelDid: contact.channelDid,
          channelDidSha256: contact.channelDidSha256,
          offerLink: contact.offerLink,
          mediatorDid: contact.mediatorDid,
          type: contact.type,
          status: contact.status,
          origin: contact.origin,
          category: contact.category,
          displayName: contact.displayName,
          card: contact.card,
        ),
      );
      return;
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

    final existing = _findExistingContactForChannel(channel);
    if (existing != null) {
      await updateContact(
        existing.copyWith(
          channelDid: contact.channelDid,
          channelDidSha256: contact.channelDidSha256,
          offerLink: contact.offerLink,
          mediatorDid: contact.mediatorDid,
          type: contact.type,
          status: contact.status,
          origin: contact.origin,
          category: contact.category,
          displayName: contact.displayName,
          card: contact.card,
        ),
      );
      return;
    }

    await addContact(contact);
  }

  Contact? _findExistingContactForChannel(sdk.Channel channel) {
    final existingByOfferLink = state.contacts.where(
      (contact) => contact.offerLink == channel.offerLink,
    );
    if (existingByOfferLink.isNotEmpty) {
      return existingByOfferLink.first;
    }

    final otherPartyDid = channel.otherPartyPermanentChannelDid;
    if (otherPartyDid == null || otherPartyDid.isEmpty) {
      return null;
    }

    final existingByDid = state.getContactByChannelDid(otherPartyDid);
    if (existingByDid == null) {
      return null;
    }

    final remoteType = channel.otherPartyContactCard?.type.trim().toLowerCase();
    final sameDidDifferentOffer = existingByDid.offerLink != channel.offerLink;
    final isAiContact =
        existingByDid.category == ContactCategory.robot ||
        remoteType == 'ai-agent';

    // For AI contacts, preserve separate contacts when the offer link differs.
    if (sameDidDifferentOffer && isAiContact) {
      return null;
    }

    return existingByDid;
  }

  /// Ensure and return the initialized contacts repository.
  ///
  /// Returns:
  /// - `Future<ContactsRepository>` the initialized repository instance.
  Future<ContactsRepository> _ensureRepositoryInitialized() async =>
      await ref.read(contactsRepositoryProvider.future);
}
