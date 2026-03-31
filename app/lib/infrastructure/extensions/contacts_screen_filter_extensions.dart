import '../../domain/models/contacts/contact_category.dart';
import '../../presentation/screens/contacts/contacts_screen_filter.dart';

/// Map UI contact filters to domain contact categories used for filtering
///  lists.
extension ContactsScreenFilterExtensions on ContactsScreenFilter {
  Set<ContactCategory> get categories {
    switch (this) {
      case ContactsScreenFilter.person:
        return {ContactCategory.person, ContactCategory.adult};
      case ContactsScreenFilter.group:
        return {ContactCategory.group};
      case ContactsScreenFilter.service:
        return {ContactCategory.service, ContactCategory.robot};
      case ContactsScreenFilter.any:
        return {
          ContactCategory.person,
          ContactCategory.adult,
          ContactCategory.group,
          ContactCategory.service,
          ContactCategory.robot,
          ContactCategory.organization,
          ContactCategory.poll,
          ContactCategory.unknown,
        };
    }
  }
}
