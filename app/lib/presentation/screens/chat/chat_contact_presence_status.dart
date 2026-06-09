part of 'chat_screen.dart';

class ChatContactPresenceStatus extends ConsumerWidget {
  const ChatContactPresenceStatus({required this._contactId});

  final String _contactId;

  @override
  Widget build(Object context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final status = ref.watch(
      provider.select((state) => state.contactPresenceStatus),
    );
    final isGroupChat = ref.watch(provider.isGroupChat);

    if (isGroupChat) return const SizedBox.shrink();

    return Text(status.dot, style: const TextStyle(fontSize: 10));
  }
}

extension ContactPresenceStatusDot on ContactPresenceStatus {
  String get dot {
    switch (this) {
      case ContactPresenceStatus.unknown:
        return '⚪';
      case ContactPresenceStatus.online:
        return '🟢';
      case ContactPresenceStatus.offline:
        return '🔴';
    }
  }
}
