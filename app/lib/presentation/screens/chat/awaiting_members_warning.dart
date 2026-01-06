part of 'chat_screen.dart';

/// Informs the admin that the messages they're sending may or may NOT be
/// delivered to the member immediately after they have just accepted
/// their offer request.
class _AwaitingMembersWarning extends ConsumerWidget {
  _AwaitingMembersWarning({required String contactId}) : _contactId = contactId;

  final String _contactId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final awaitingMemberNames = ref.watch(provider.awaitingMemberNames);

    if (awaitingMemberNames.isEmpty) {
      return const SizedBox.shrink();
    }

    final namesCount = awaitingMemberNames.length;
    final message = context.l10n.awaitingMembersToJoin(
      awaitingMemberNames.last,
      namesCount,
      math.max(0, namesCount - 1),
    );

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey.shade700,
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFEEEEEE),
          fontWeight: FontWeight.w300,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
