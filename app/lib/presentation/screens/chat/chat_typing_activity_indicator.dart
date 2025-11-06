part of 'chat_screen.dart';

class _ChatTypingActivityIndicator extends ConsumerWidget {
  const _ChatTypingActivityIndicator({required String contactId})
      : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final membersTyping =
        ref.watch(provider.select((state) => state.membersTyping));

    if (membersTyping.isEmpty) {
      return const SizedBox(height: 31);
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        height: 22,
        child: Row(
          children: [
            Text(
              context.l10n.typingMessage(
                  membersTyping.join(', '), membersTyping.length),
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const _TypingIndicator(),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends HookWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );

    useEffect(() {
      if (!context.mounted) return;
      controller.repeat();
      return null;
    }, [controller]);

    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final animation = CurvedAnimation(
                  parent: controller,
                  curve: Interval(
                    index * 0.3, // Stagger the animations
                    0.6 + index * 0.15,
                    curve: Curves.easeInOut,
                  ),
                );

                return Container(
                  width: 10,
                  height: 10,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey
                        .withAlpha((animation.value * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
