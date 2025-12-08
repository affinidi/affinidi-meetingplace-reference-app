import 'package:meeting_place_chat/meeting_place_chat.dart';
import '../../domain/models/contact_card/contact_card.dart';
import 'contact_card_extensions.dart';

extension EventMessageContactCard on EventMessage {
  ContactCard? get contactCard {
    final cardField = data['card'];
    if (cardField is! Map<String, dynamic>) return null;

    final values = cardField['values'];
    if (values is! Map<String, dynamic>) return null;

    final firstName = ContactCardUtils.getPathValue(
      values,
      ContactCardPaths.firstName.paths,
    );
    final lastName = ContactCardUtils.getPathValue(
      values,
      ContactCardPaths.lastName.paths,
    );
    final email = ContactCardUtils.getPathValue(
      values,
      ContactCardPaths.email.paths,
    );
    final mobile = ContactCardUtils.getPathValue(
      values,
      ContactCardPaths.mobile.paths,
    );
    final profilePic = ContactCardUtils.getPathValue(
      values,
      ContactCardPaths.profilePic.paths,
    );
    final color = ContactCardUtils.getPathValue(
      values,
      ContactCardPaths.meetingplaceIdentityCardColor.paths,
    );

    return ContactCard(
      id: 'event-msg-card',
      firstName: firstName,
      displayName: [firstName, lastName].where((s) => s.isNotEmpty).join(' '),
      lastName: lastName.isEmpty ? null : lastName,
      email: email.isEmpty ? null : email,
      mobile: mobile.isEmpty ? null : mobile,
      profilePic: profilePic.isEmpty ? null : profilePic,
      cardColor: color.isEmpty ? null : color,
    );
  }

  /// Returns the memberDid from data, or null if not present.
  String? get memberDid {
    return data['memberDid'] as String?;
  }
}
