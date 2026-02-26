import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

extension ChatItemListExtensions on List<chat.ChatItem> {
  /// Inserts a [chat.ChatItem] into the list while maintaining sorted order.
  ///
  /// This method adds the given [item] to the list in the correct position
  /// to preserve the sorted arrangement of chat items.
  ///
  /// Parameters:
  /// - [item]: The [chat.ChatItem] to be inserted into the sorted list
  ///
  /// Returns:
  /// A new [List<ChatItem>] containing all existing items plus the newly
  /// inserted item, sorted according to the dateCreated.
  List<chat.ChatItem> insertSorted(chat.ChatItem item) {
    if (isEmpty) {
      return [item];
    }

    final messages = List<chat.ChatItem>.from(this);
    final insertIndex = messages.indexWhere(
      (m) => m.dateCreated.isBefore(item.dateCreated),
    );

    if (insertIndex == -1) {
      messages.add(item);
    } else {
      messages.insert(insertIndex, item);
    }
    return messages;
  }
}
