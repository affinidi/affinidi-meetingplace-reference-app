import '../../../infrastructure/extensions/contact_card_extensions.dart';

/// Represents the category of a contact.
///
/// Used to classify contacts into different groups or types within the
/// application.
enum ContactCategory {
  unknown(0),
  person(1),
  adult(2),
  robot(4),
  service(8),
  organization(16),
  poll(32),
  group(64);

  const ContactCategory(this.value);
  factory ContactCategory.fromContactCardType(String? type) {
    if (type == null) {
      return unknown;
    }

    final cardType = ContactCardType.fromString(type);
    switch (cardType) {
      case ContactCardType.individual:
        return person;
      case ContactCardType.aiAgent:
        return robot;
      case null:
        return unknown;
    }
  }

  final int value;
}
