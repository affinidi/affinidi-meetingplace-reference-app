import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import '../../domain/models/contact_card/contact_card.dart';
import 'contact_card_extensions.dart';

const _groupMemberRemovedReason = 'removed';

extension EventMessageContactCard on EventMessage {
  ContactCard? get contactCard {
    final cardField = data['contactCard'];
    if (cardField is! Map<String, dynamic>) return null;

    final values = cardField['contactInfo'];
    if (values is! Map<String, dynamic>) return null;

    final sdkCard = sdk.ContactCard(
      did: cardField['did'] as String,
      type: cardField['type'] as String,
      contactInfo: values,
    );

    return ContactCardUtils.fromSdkContactCard(sdkCard);
  }

  /// Returns the memberDid from data, or null if not present.
  String? get memberDid {
    return data['memberDid'] as String?;
  }

  bool get isGroupMemberRemoved {
    return data['reason'] == _groupMemberRemovedReason;
  }
}
