import 'package:meeting_place_chat/meeting_place_chat.dart';

/// Extension methods on [PlainTextMessage] for working with effects.
extension PlainTextMessageExtensions on PlainTextMessage {
  /// Returns the effect name associated with this message, if available.
  String? get effectName {
    var parent = body;

    if (body?['group_message'] != null) {
      parent = body?['group_message'] as Map<String, dynamic>;
    }

    return parent?['effect'] as String?;
  }
}
