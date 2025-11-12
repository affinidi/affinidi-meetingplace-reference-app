import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'vcard_extensions.dart';

/// Convenience accessors to extract member-related data from a
///  ConciergeMessage.
/// - `memeberName` reads the display name when message is user input.
/// - `vCard` reconstructs a VCard from the message `data` map when present.
extension ConciergeMessageExtensions on ConciergeMessage {
  String? get memeberName {
    if (status != ChatItemStatus.userInput) return null;
    return vCard?.fullName;
  }

  VCard? get vCard {
    if (data['memberVCard'] is! Map<dynamic, dynamic>) return null;

    final memberVCard = data['memberVCard'] as Map<dynamic, dynamic>;

    if (memberVCard['values'] is! Map<dynamic, dynamic>) return null;

    final vCardValues = memberVCard['values'] as Map<dynamic, dynamic>;

    return VCard(values: vCardValues);
  }
}
