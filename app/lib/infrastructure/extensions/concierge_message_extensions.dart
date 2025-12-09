import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import '../../domain/models/contact_card/contact_card.dart';

import 'contact_card_extensions.dart';

/// Convenience accessors to extract member-related data from a
///  ConciergeMessage.
/// - `memeberName` reads the display name when message is user input.
/// - `card` reconstructs a ContactCard from the message `data`
///   map when present.
extension ConciergeMessageExtensions on ConciergeMessage {
  String? get memeberName {
    if (status != ChatItemStatus.userInput) return null;
    return contactCard?.displayName;
  }

  ContactCard? get contactCard {
    final contactInfo = data['contactInfo'];
    if (contactInfo is! Map<String, dynamic>) return null;

    final sdkCard = sdk.ContactCard(
      did: '',
      type: '',
      contactInfo: contactInfo,
    );

    return ContactCardUtils.fromSdkContactCard(sdkCard);
  }
}
