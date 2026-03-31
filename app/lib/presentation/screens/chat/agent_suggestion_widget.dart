part of 'chat_screen.dart';

/// Shown above the text entry when the agent has generated a suggested reply
/// (or is currently generating one). The user can tap to send it immediately
/// or dismiss it without acting.
class _AgentSuggestionWidget extends ConsumerWidget {
  const _AgentSuggestionWidget(this._contactId);

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AgentConfig.backendUrl.isEmpty) return const SizedBox.shrink();

    final provider = chatScreenControllerProvider(_contactId);
    final isThinking = ref.watch(provider.select((s) => s.isAgentThinking));
    final suggestion = ref.watch(provider.select((s) => s.agentSuggestion));

    if (!isThinking && suggestion == null) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0A3B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.45),
          ),
        ),
        child: isThinking
            ? _buildThinking()
            : _buildSuggestion(context, ref, suggestion!),
      ),
    );
  }

  Widget _buildThinking() => Row(
    children: [
      const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.deepPurpleAccent,
        ),
      ),
      const SizedBox(width: 10),
      const Text(
        'AI is composing a reply…',
        style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12),
      ),
    ],
  );

  Widget _buildSuggestion(
    BuildContext context,
    WidgetRef ref,
    String suggestion,
  ) {
    final provider = chatScreenControllerProvider(_contactId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        Row(
          children: [
            const Icon(
              Icons.smart_toy_outlined,
              size: 13,
              color: Colors.deepPurpleAccent,
            ),
            const SizedBox(width: 6),
            const Text(
              'Suggested reply',
              style: TextStyle(
                fontSize: 11,
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => ref.read(provider.notifier).dismissSuggestion(),
              child: const Icon(Icons.close, size: 15, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Suggestion bubble — tap to send
        GestureDetector(
          onTap: () => ref.read(provider.notifier).acceptSuggestion(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
