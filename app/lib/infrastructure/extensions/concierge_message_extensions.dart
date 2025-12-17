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
    final card = data['contactCard'] as Map<String, dynamic>;
    if (card['contactInfo'] is! Map<String, dynamic>) return null;

    final sdkCard = sdk.ContactCard(
      did: card['did'] as String,
      type: card['type'] as String,
      schema: card['schema'] as String,
      contactInfo: card['contactInfo'] as Map<String, dynamic>,
    );

    return ContactCardUtils.fromSdkContactCard(sdkCard);
  }
}
