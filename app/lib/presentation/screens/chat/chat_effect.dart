part of 'chat_screen.dart';

class ChatEffect extends ConsumerWidget {
  ChatEffect({super.key, required String contactId}) : _contactId = contactId;

  final String _contactId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final currentScreenEffect =
        ref.watch(provider.select((state) => state.effect));

    if (currentScreenEffect == null) {
      return const SizedBox.shrink();
    }

    return _ScreenEffectOverlay(
      effect: currentScreenEffect,
      onComplete: controller.clearEffect,
    );
  }
}

class _ScreenEffectOverlay extends StatefulWidget {
  const _ScreenEffectOverlay({
    required this.effect,
    this.onComplete,
  });

  final ScreenEffect effect;
  final VoidCallback? onComplete;

  @override
  State<_ScreenEffectOverlay> createState() => _ScreenEffectOverlayState();
}

class _ScreenEffectOverlayState extends State<_ScreenEffectOverlay>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    switch (widget.effect.type) {
      case chat.Effect.confetti:
        return ConfettiEffect(onComplete: widget.onComplete);

      case chat.Effect.balloons:
        return LayoutBuilder(
          builder: (context, constraints) {
            return BalloonEffect(
              onComplete: widget.onComplete,
              size: Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
