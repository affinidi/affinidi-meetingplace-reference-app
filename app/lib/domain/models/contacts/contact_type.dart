import 'package:meeting_place_core/meeting_place_core.dart';

/// Enum representing different types of contacts in the application.
///
/// This enum defines the various categories or classifications that can be
/// assigned to contacts, allowing for better organization and filtering
/// of contact information.
enum ContactType {
  individual(1),
  group(2),
  unknown(0);

  const ContactType(this.value);
  factory ContactType.from(ChannelType type) {
    switch (type) {
      case ChannelType.oob:
      case ChannelType.individual:
        return ContactType.individual;
      case ChannelType.group:
        return ContactType.group;
    }
  }

  final int value;
}
