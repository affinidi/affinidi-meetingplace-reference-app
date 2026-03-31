part of 'chat_screen.dart';

/// Thin banner shown at the top of the chat body when the agent backend is
/// configured. Lets the user toggle focus mode on/off per conversation.
class _AgentFocusBanner extends ConsumerWidget {
  const _AgentFocusBanner(this._contactId);

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AgentConfig.backendUrl.isEmpty) return const SizedBox.shrink();

    final ownerDid = ref.watch(
      identitiesServiceProvider.select((s) => s.currentIdentity?.did ?? ''),
    );
    final isDeployed = ref.watch(
      agentReadinessProvider(
        ownerDid,
      ).select((a) => a.valueOrNull?.isDeployed ?? false),
    );
    if (!isDeployed) return const SizedBox.shrink();

    final provider = chatScreenControllerProvider(_contactId);
    final isActive = ref.watch(provider.select((s) => s.isFocusModeActive));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: isActive
          ? const Color(0xFF1A0A3B)
          : context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 15,
            color: isActive
                ? Colors.deepPurpleAccent
                : context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isActive
                  ? 'AI representative is handling this chat'
                  : 'AI representative — tap to enable focus mode',
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? Colors.deepPurpleAccent
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: (_) => ref.read(provider.notifier).toggleFocusMode(),
            activeColor: Colors.deepPurpleAccent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
