import 'package:meeting_place_chat/meeting_place_chat.dart';
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

    final firstName = ContactCardUtils.getPathValue(
      contactInfo,
      ContactCardPaths.firstName.paths,
    );
    final lastName = ContactCardUtils.getPathValue(
      contactInfo,
      ContactCardPaths.lastName.paths,
    );
    final email = ContactCardUtils.getPathValue(
      contactInfo,
      ContactCardPaths.email.paths,
    );
    final mobile = ContactCardUtils.getPathValue(
      contactInfo,
      ContactCardPaths.mobile.paths,
    );
    final profilePic = ContactCardUtils.getPathValue(
      contactInfo,
      ContactCardPaths.profilePic.paths,
    );
    final color = ContactCardUtils.getPathValue(
      contactInfo,
      ContactCardPaths.meetingplaceIdentityCardColor.paths,
    );

    return ContactCard(
      id: 'concierge-msg-card',
      firstName: firstName,
      displayName: [firstName, lastName].where((s) => s.isNotEmpty).join(' '),
      lastName: lastName.isEmpty ? null : lastName,
      email: email.isEmpty ? null : email,
      mobile: mobile.isEmpty ? null : mobile,
      profilePic: profilePic.isEmpty ? null : profilePic,
      cardColor: color.isEmpty ? null : color,
    );
  }
}
