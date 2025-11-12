import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/mediator_service/mediator_service.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../domain/models/mediator/mediator.dart';
import '../../../infrastructure/extensions/contacts_screen_filter_extensions.dart';
import '../../../infrastructure/extensions/vcard_extensions.dart';
import '../../widgets/async_loaders/async_loading_controller.dart';
import 'contacts_screen_filter.dart';
import 'contacts_screen_state.dart';

part 'contacts_screen_controller.g.dart';

@Riverpod(keepAlive: true)
class ContactsScreenController extends _$ContactsScreenController {
  ContactsScreenController() : super();
  late final deleteContactLoadingController =
      AsyncLoadingController.provider('deleteContactLoadingController');
  late final deleteMultipleContactsLoadingController =
      AsyncLoadingController.provider(
          'deleteMultipleContactsLoadingController');

  @override
  ContactsScreenState build() {
    ref.listen(
      identitiesServiceProvider.currentIdentityOrPrimary,
      (prev, next) {
        if (prev == next) return;

        Future.microtask(() {
          state = state.copyWith(identity: next);
        });
      },
      fireImmediately: true,
    );

    ref.listen(
      contactsServiceProvider.select((state) => state.contacts),
      (prev, next) {
        if (prev == next) return;

        final prevIds = prev?.map((c) => c.mediatorDid).toSet() ?? <String>{};
        final nextIds = next.map((c) => c.mediatorDid).toSet();
        final newIds = nextIds.difference(prevIds);

        final newContacts = next.where((c) => newIds.contains(c.mediatorDid));

        Future.microtask(() {
          state = state.copyWith(contacts: _sortContacts(next));
          _updateContactMediators(newContacts);
        });
      },
      fireImmediately: true,
    );

    // Listen to mediator service to update connection mediators when
    // mediators load
    ref.listen(mediatorServiceProvider, (prev, next) {
      if (prev == next) return;

      Future.microtask(_updateContactMediators);
    }, fireImmediately: true);

    return ContactsScreenState();
  }

  void cancelEdit() async {
    state = state.copyWith(isEditMode: false, selectedContacts: []);
  }

  void toggleEditMode() async {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  Future<void> deleteSelectedContacts() async {
    if (!state.isEditMode) return;

    await ref
        .read(deleteMultipleContactsLoadingController.notifier)
        .start(() async {
      await ref
          .read(contactsServiceProvider.notifier)
          .deleteContacts(state.selectedContacts);
      state = state.copyWith(isEditMode: false, selectedContacts: []);
    });
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
    final allContacts = ref.read(contactsServiceProvider).contacts;
    final filteredContacts = allContacts.where((contact) {
      final vCard = contact.vCard;
      final displayName = contact.displayName?.toLowerCase() ?? '';
      final firstName = vCard.firstName.toLowerCase();
      final lastName = vCard.lastName.toLowerCase();
      return firstName.contains(lowerQuery) ||
          lastName.contains(lowerQuery) ||
          displayName.contains(lowerQuery);
    }).toList();

    if (state.contacts != filteredContacts) {
      state = state.copyWith(contacts: _sortContacts(filteredContacts));
    }
  }

  void clearSearch() {
    final allContacts = ref.read(contactsServiceProvider).contacts;
    if (state.contacts != allContacts) {
      state = state.copyWith(contacts: _sortContacts(allContacts));
    }
  }

  Future<void> applyFilter(ContactsScreenFilter filter) async {
    final allContacts = ref.read(contactsServiceProvider).contacts;
    final filteredContacts = allContacts.where((contact) {
      return filter.categories.contains(contact.category);
    }).toList();

    state = state.copyWith(contacts: _sortContacts(filteredContacts));
  }

  void deselectContact(Contact contact) {
    state = state.copyWith(
        selectedContacts: List.of(state.selectedContacts)..remove(contact));
  }

  void selectContact(Contact contact) {
    state = state.copyWith(
      selectedContacts: List.of(state.selectedContacts)..add(contact),
    );
  }

  Future<void> deleteContact(Contact contact) async {
    await ref.read(deleteContactLoadingController.notifier).start(() async {
      await ref
          .read(contactsServiceProvider.notifier)
          .deleteContacts([contact]);
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
        ContactStatus.rejected =>
          5,
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
}

extension ContactsScreenControllerSelector
    on NotifierProvider<ContactsScreenController, ContactsScreenState> {
  ProviderListenable<bool> get hasContacts =>
      select((state) => state.contacts.isNotEmpty);
  ProviderListenable<bool> get hasAnySelectedContacts =>
      select((state) => state.selectedContacts.isNotEmpty);
  ProviderListenable<bool> get hasIdentity =>
      select((state) => state.identity != null);
}
