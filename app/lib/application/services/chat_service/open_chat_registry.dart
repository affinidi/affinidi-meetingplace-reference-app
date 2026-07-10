import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'open_chat_registry.g.dart';

/// Tracks which contact chats are currently open on screen.
///
/// The presentation layer owns navigation state, so the chat screen publishes
/// its open/closed lifecycle here (see `ChatScreenController`). Application
/// services can then check whether a chat is being viewed without reaching into
/// navigation internals such as the router.
@Riverpod(keepAlive: true)
class OpenChatRegistry extends _$OpenChatRegistry {
  @override
  Set<String> build() => const {};

  /// Marks [contactId]'s chat as open.
  void markOpened(String contactId) {
    if (!ref.mounted || state.contains(contactId)) return;
    state = {...state, contactId};
  }

  /// Marks [contactId]'s chat as closed.
  void markClosed(String contactId) {
    if (!ref.mounted || !state.contains(contactId)) return;
    state = {...state}..remove(contactId);
  }

  /// Whether [contactId]'s chat is currently open on screen.
  bool isOpen(String contactId) => state.contains(contactId);
}
