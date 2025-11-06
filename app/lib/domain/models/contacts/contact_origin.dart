import 'package:meeting_place_core/meeting_place_core.dart';

/// Represents the origin or source of a contact entry.
///
/// This enum defines the different ways a contact can be added or imported
/// into the application, allowing for proper categorization and handling
/// based on the contact's source.
enum ContactOrigin {
  directInteractive(1),
  individualOfferPublished(2),
  individualOfferRequested(3),
  groupOfferPublished(4),
  groupOfferRequested(5),
  unknown(0),
  ;

  const ContactOrigin(this.value);

  factory ContactOrigin.from(ChannelType type) {
    switch (type) {
      case ChannelType.individual:
        return individualOfferPublished;
      case ChannelType.group:
        return groupOfferPublished;
      case ChannelType.oob:
        return directInteractive;
    }
  }

  final int value;
}
