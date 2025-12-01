import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'unsent_messages_state.dart';

part 'unsent_messages_service.g.dart';

/// In-memory service for managing unsent messages per contact.
///
/// This service provides a lightweight, memory-only cache for draft messages
/// that users have typed but not sent.
@riverpod
class UnsentMessagesService extends _$UnsentMessagesService {
  @override
  UnsentMessagesServiceState build() {
    return const UnsentMessagesServiceState();
  }

  void saveUnsentMessage(String contactId, String? text) {
    final currentMessages = Map<String, String>.from(state.unsentMessages);

    if (text == null || text.isEmpty) {
      currentMessages.remove(contactId);
    } else {
      currentMessages[contactId] = text;
    }

    state = state.copyWith(unsentMessages: currentMessages);
  }

  String? getUnsentMessage(String contactId) {
    return state.unsentMessages[contactId];
  }

  void clearUnsentMessage(String contactId) {
    final currentMessages = Map<String, String>.from(state.unsentMessages);
    currentMessages.remove(contactId);
    state = state.copyWith(unsentMessages: currentMessages);
  }

  void clearAll() {
    state = const UnsentMessagesServiceState();
  }
}
