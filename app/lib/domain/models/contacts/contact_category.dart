import 'package:meeting_place_core/meeting_place_core.dart';

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
  factory ContactCategory.from(ChannelType type) {
    switch (type) {
      case ChannelType.individual:
        return person;
      case ChannelType.group:
        return group;
      case ChannelType.oob:
        return person;
    }
  }

  final int value;
}
