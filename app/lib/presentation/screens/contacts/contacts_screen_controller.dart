import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/mediator_service/mediator_service.dart';
import '../../../application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import '../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../domain/models/mediator/mediator.dart';
import '../../../infrastructure/extensions/string_list_extensions.dart';
import '../../widgets/async_loaders/async_loading_controller.dart';
import 'contacts_screen_state.dart';

part 'contacts_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class ContactsScreenController extends _$ContactsScreenController {
  ContactsScreenController() : super();
  late final deleteContactLoadingController = AsyncLoadingController.provider(
    'deleteContactLoadingController',
  );
  late final deleteMultipleContactsLoadingController =
      AsyncLoadingController.provider(
        'deleteMultipleContactsLoadingController',
      );

  bool _isDisposed = false;

  @override
  ContactsScreenState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });

    ref.listen(identitiesServiceProvider.currentIdentityOrPrimary, (
      prev,
      next,
    ) {
      if (prev == next) return;

      Future.microtask(() {
        if (_isDisposed) return;

        state = state.copyWith(identity: next);
      });
    }, fireImmediately: true);

    ref.listen(
      contactsServiceProvider.select((state) => state.contacts),
      (prev, next) {
        if (prev == next) return;

        final prevIds = prev?.map((c) => c.mediatorDid).toSet() ?? <String>{};
        final nextIds = next.map((c) => c.mediatorDid).toSet();
        final newIds = nextIds.difference(prevIds);

        final newContacts = next.where((c) => newIds.contains(c.mediatorDid));
        // Contacts share a mediator, so a new channel is told by its offer
        // link, not by a new mediator.
        final prevOfferLinks = {...?prev?.map((c) => c.offerLink)};
        final hasNewChannel = next.any(
          (c) => !prevOfferLinks.contains(c.offerLink),
        );

        Future.microtask(() async {
          if (_isDisposed) return;

          final communityContacts = _communityContacts(next);
          state = state.copyWith(contacts: _sortContacts(communityContacts));
          _updateContactMediators(newContacts);
          // A group chat just joined is recorded once its contact is made.
          if (hasNewChannel) await _readCommunityChannels();
        });
      },
      fireImmediately: true,
    );

    // A group chat created or joined may be recorded after its contact is
    // made: read the community's channels again once it is.
    final chatsChanged = ref
        .read(vtcGroupChatServiceProvider)
        .chatsChanged
        .listen((_) {
          if (!_isDisposed) unawaited(_readCommunityChannels());
        });
    ref.onDispose(chatsChanged.cancel);

    // Listen to mediator service to update connection mediators when
    // mediators load
    ref.listen(mediatorServiceProvider, (prev, next) {
      if (prev == next) return;

      Future.microtask(() {
        if (_isDisposed) return;

        _updateContactMediators();
      });
    }, fireImmediately: true);

    return ContactsScreenState();
  }

  /// Shows the channels of [communityDid] only.
  Future<void> showCommunity(String communityDid) async {
    // Another community's channels never show, not even while reading.
    if (state.communityDid != communityDid) {
      state = state.copyWith(
        communityDid: communityDid,
        communityOfferLinks: const {},
        contacts: const [],
        selectedContacts: const [],
        isEditMode: false,
      );
    }
    await _readCommunityChannels();
  }

  Future<void> _readCommunityChannels() async {
    final communityDid = state.communityDid;
    if (communityDid == null) return;
    final offerLinks = await ref.refresh(
      communityChannelOfferLinksProvider(communityDid).future,
    );
    if (_isDisposed || state.communityDid != communityDid) return;
    state = state.copyWith(communityOfferLinks: offerLinks);
    state = state.copyWith(
      contacts: _sortContacts(
        _communityContacts(ref.read(contactsServiceProvider).contacts),
      ),
    );
  }

  void cancelEdit() async {
    state = state.copyWith(isEditMode: false, selectedContacts: []);
  }

  void toggleEditMode() async {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  Future<void> deleteSelectedContacts() async {
    if (!state.isEditMode) return;

    await ref.read(deleteMultipleContactsLoadingController.notifier).start(
      () async {
        await ref
            .read(contactsServiceProvider.notifier)
            .deleteContacts(state.selectedContacts);
        state = state.copyWith(isEditMode: false, selectedContacts: []);
      },
    );
  }

  void toggleGridView(bool shouldShowGrid) {
    state = state.copyWith(shouldShowGrid: shouldShowGrid);
  }

  void toggleFilterVisibility() {
    if (state.shouldShowFilter) {
      clearSearch();
    }
    state = state.copyWith(shouldShowFilter: !state.shouldShowFilter);
  }

  void search(String query) {
    final lowerQuery = query.toLowerCase();
    final allContacts = _communityContacts();
    final filteredContacts = allContacts.where((contact) {
      final searchableText = ContactCardFieldDefinitions.values
          .where((f) => f.hasTag(ContactCardFieldTags.searchable))
          .map((f) => f.valueFrom(contact.card))
          .nonEmpty
          .join(' ')
          .toLowerCase();
      final displayName = contact.displayName?.toLowerCase() ?? '';
      return searchableText.contains(lowerQuery) ||
          displayName.contains(lowerQuery);
    }).toList();

    if (state.contacts != filteredContacts) {
      state = state.copyWith(contacts: _sortContacts(filteredContacts));
    }
  }

  void clearSearch() {
    final allContacts = _communityContacts();
    if (state.contacts != allContacts) {
      state = state.copyWith(contacts: _sortContacts(allContacts));
    }
  }

  void deselectContact(Contact contact) {
    state = state.copyWith(
      selectedContacts: List.of(state.selectedContacts)..remove(contact),
    );
  }

  void selectContact(Contact contact) {
    state = state.copyWith(
      selectedContacts: List.of(state.selectedContacts)..add(contact),
    );
  }

  Future<void> deleteContact(Contact contact) async {
    await ref.read(deleteContactLoadingController.notifier).start(() async {
      await ref.read(contactsServiceProvider.notifier).deleteContacts([
        contact,
      ]);
    });
  }

  List<Contact> _sortContacts(List<Contact> contacts) {
    int getPriority(Contact contact) {
      final hasActivity =
          contact.badgeCount > 0 || contact.currentMessageSeqNo != 0;

      return switch (contact.status) {
        ContactStatus.pendingApproval => 1,
        ContactStatus.approved || ContactStatus.active when hasActivity => 3,
        ContactStatus.approved || ContactStatus.active => 2,
        ContactStatus.pendingInauguration => 4,
        ContactStatus.deleted ||
        ContactStatus.error ||
        ContactStatus.rejected => 5,
        ContactStatus.unknown => 6,
      };
    }

    final sorted = contacts.toList();
    sorted.sort((a, b) => getPriority(a).compareTo(getPriority(b)));
    return sorted;
  }

  /// Updates the contact mediators map by finding the nearest mediator
  /// for each contact based on creation time and DID.
  void _updateContactMediators([Iterable<Contact>? contactsToProcess]) {
    final mediatorService = ref.read(mediatorServiceProvider.notifier);
    final contactMediators = Map<String, Mediator>.from(state.contactMediators);

    final contacts = contactsToProcess ?? state.contacts;

    for (final contact in contacts) {
      final mediator = mediatorService.findNearestMediatorBefore(
        dateTime: contact.dateAdded,
        did: contact.mediatorDid,
      );
      if (mediator != null) {
        contactMediators[contact.mediatorDid] = mediator;
      } else {
        contactMediators.remove(contact.mediatorDid);
      }
    }

    state = state.copyWith(contactMediators: contactMediators);
  }

  /// Those of [contacts], else of all contacts, that are channels of the
  /// community shown.
  List<Contact> _communityContacts([List<Contact>? contacts]) {
    final all = contacts ?? ref.read(contactsServiceProvider).contacts;
    return all
        .where(
          (contact) => state.communityOfferLinks.contains(contact.offerLink),
        )
        .toList();
  }
}

/// The offer links of the channels of [communityDid]: its groups' chats.
@riverpod
Future<Set<String>> communityChannelOfferLinks(Ref ref, String communityDid) =>
    ref.read(vtcGroupChatServiceProvider).chatOfferLinks(communityDid);

extension ContactsScreenControllerSelector on ContactsScreenControllerProvider {
  ProviderListenable<bool> get hasContacts =>
      select((state) => state.contacts.isNotEmpty);
  ProviderListenable<bool> get hasAnySelectedContacts =>
      select((state) => state.selectedContacts.isNotEmpty);
  ProviderListenable<bool> get hasIdentity =>
      select((state) => state.identity != null);
}
