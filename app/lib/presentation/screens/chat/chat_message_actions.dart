part of 'chat_screen.dart';

/// Bottom-sheet menu of actions available on a single chat message.
///
/// Shown on long-press of a message bubble. Always offers Copy; offers
/// Delete-for-everyone and Delete-for-me only on the user's own non-deleted
/// messages.
class _ChatMessageActions extends ConsumerWidget {
  const _ChatMessageActions({
    required String contactId,
    required chat.Message message,
  }) : _contactId = contactId,
       _message = message;

  final String _contactId;
  final chat.Message _message;

  static Future<void> show({
    required BuildContext context,
    required String contactId,
    required chat.Message message,
  }) async => await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _ChatMessageActions(contactId: contactId, message: message),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      chatScreenControllerProvider(_contactId).notifier,
    );

    Future<void> copy() async {
      if (!context.mounted) return;
      if (_message.value.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      await Clipboard.setData(ClipboardData(text: _message.value));
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.messageCopiedClipboard),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    Future<void> delete({required bool localOnly}) async {
      Navigator.of(context).pop();
      try {
        await controller.deleteMessage(
          _message.messageId,
          deleteForMeOnly: localOnly,
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chatMessageDeleteFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    final canDelete =
        _message.isFromMe && !_message.isDeleted && !_message.isDeletedLocally;

    // Delete-for-everyone is allowed only inside the SDK's redaction window.
    // Outside the window the SDK throws, so disable the action upfront rather
    // than letting the user tap and fail.
    final window = controller.deleteMessageWindow;
    final age = DateTime.now().toUtc().difference(_message.dateCreated);
    final isWithinDeleteWindow = window > Duration.zero && age <= window;

    final items = <_ChatMessageActionItem>[
      if (_message.value.isNotEmpty && !_message.isDeleted)
        _ChatMessageActionItem(
          icon: Icons.copy,
          label: context.l10n.chatMessageActionCopy,
          onTap: copy,
        ),
      if (canDelete) ...[
        _ChatMessageActionItem(
          icon: Icons.delete_outline,
          label: context.l10n.chatMessageActionDelete,
          isDestructive: true,
          enabled: isWithinDeleteWindow,
          onTap: () => delete(localOnly: false),
        ),
        _ChatMessageActionItem(
          icon: Icons.visibility_off_outlined,
          label: context.l10n.chatMessageActionDeleteLocal,
          onTap: () => delete(localOnly: true),
        ),
      ],
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: BottomSheetMenu(
        showHandle: true,
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _ChatMessageActionTile(item: items[index]),
      ),
    );
  }
}

class _ChatMessageActionItem {
  const _ChatMessageActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool enabled;
}

class _ChatMessageActionTile extends StatelessWidget {
  const _ChatMessageActionTile({required _ChatMessageActionItem item})
    : _item = item;

  final _ChatMessageActionItem _item;

  @override
  Widget build(BuildContext context) {
    final baseColor = _item.isDestructive ? Colors.redAccent : Colors.white;
    final color = _item.enabled ? baseColor : baseColor.withValues(alpha: 0.4);
    return ListTile(
      leading: Icon(_item.icon, color: color, size: 28),
      title: Text(_item.label, style: TextStyle(color: color, fontSize: 18)),
      enabled: _item.enabled,
      onTap: _item.enabled ? _item.onTap : null,
    );
  }
}
