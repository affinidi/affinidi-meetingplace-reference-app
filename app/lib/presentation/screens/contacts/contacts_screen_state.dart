import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../domain/models/contacts/contact_type.dart';
import '../../../domain/models/mediator/mediator.dart';
import 'contacts_screen_filter.dart';

part 'contacts_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ContactsScreenState with _$ContactsScreenState {
  ContactsScreenState._();

  factory ContactsScreenState({
    @Default(false) bool isEditMode,
    @Default(true) bool shouldShowGrid,
    @Default(false) bool shouldShowFilter,
    @Default([]) List<Contact> contacts,
    @Default([]) List<Contact> selectedContacts,
    @Default({}) Map<String, Mediator> contactMediators,
    @Default(ContactsScreenFilter.any) ContactsScreenFilter filter,
    Identity? identity,
  }) = _ContactsScreenState;

  bool isChatAvailable(Contact contact) =>
      isIndividualChatAvailable(contact) || isGroupChatAvailable(contact);

  bool isIndividualChatAvailable(Contact contact) =>
      contact.type == ContactType.individual &&
      contact.status == ContactStatus.active;

  bool isGroupChatAvailable(Contact contact) =>
      contact.type == ContactType.group &&
      (contact.status == ContactStatus.active ||
          contact.status == ContactStatus.pendingApproval);
}
