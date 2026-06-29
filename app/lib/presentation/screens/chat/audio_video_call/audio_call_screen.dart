part of 'audio_video_call_screen.dart';

/// Shows a confirmation dialog to switch from audio to video call.
Future<void> _showSwitchToVideoDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) async {
  final l10n = context.l10n;
  await showAdaptiveDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog.adaptive(
      title: Text(l10n.videoCallSwitchToVideoTitle),
      actions: [
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          label: l10n.videoCallCancel,
          isDestructiveAction: true,
        ),
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop();
            onConfirm();
          },
          label: l10n.videoCallSwitch,
          isDefaultAction: true,
        ),
      ],
    ),
  );
}

/// Audio-only call UI for ringing and active states.
class _AudioCallScreen extends ConsumerWidget {
  const _AudioCallScreen({required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final showControls = ref.watch(provider.select((s) => s.showControlsBar));
    final controller = ref.read(provider.notifier);

    final isMicEnabled = ref.watch(provider.select((s) => s.isMicEnabled));
    final isSpeakerEnabled = ref.watch(
      provider.select((s) => s.isSpeakerEnabled),
    );
    final micPermissionError = ref.watch(
      provider.select((s) => s.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      provider.select((s) => s.cameraPermissionError),
    );

    final peerCard = ref
        .read(contactsServiceProvider)
        .getContactById(contactId)
        ?.card;
    final peerAvatarImage = peerCard?.hasProfilePic == true
        ? peerCard!.image(cacheManager: ref.read(cacheManagerProvider))
        : null;

    final controls = _CallControls(
      mic: CallButtonConfig(
        isEnabled: isMicEnabled,
        isDisabled: micPermissionError,
        onTap: controller.toggleMic,
      ),
      speaker: CallButtonConfig(
        isEnabled: isSpeakerEnabled,
        onTap: controller.toggleSpeaker,
      ),
      camera: CallButtonConfig(
        isEnabled: false,
        isDisabled: cameraPermissionError,
        onTap: () => _showSwitchToVideoDialog(
          context: context,
          onConfirm: () =>
              unawaited(controller.restartCall(isAudioOnly: false)),
        ),
      ),
      onEndCall: () {
        unawaited(controller.hangUp());
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    return _AudioCallScaffold(
      contactId: contactId,
      peerAvatarImage: peerAvatarImage,
      showControls: showControls,
      controls: controls,
      onToggleControls: controller.toggleControlsBar,
      onMinimize: () {
        controller.minimize();
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}

class _AudioCallScaffold extends StatelessWidget {
  const _AudioCallScaffold({
    required this.contactId,
    required this.peerAvatarImage,
    required this.showControls,
    required this.controls,
    required this.onToggleControls,
    required this.onMinimize,
  });

  final String contactId;
  final ImageProvider<Object>? peerAvatarImage;
  final bool showControls;
  final _CallControls controls;
  final VoidCallback onToggleControls;
  final VoidCallback onMinimize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: GestureDetector(
        onTap: onToggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AudioCallBackground(peerAvatarImage: peerAvatarImage),
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CallTopBarOverlay(
                      visible: showControls,
                      child: _CallTopBar(
                        contactId: contactId,
                        onMinimize: onMinimize,
                      ),
                    ),
                    if (peerAvatarImage == null)
                      const Center(child: _CallPersonAvatar()),
                    _AnimatedControlsOverlay(
                      visible: showControls,
                      duration: const Duration(milliseconds: 100),
                      child: _ControlsOverlayContent(controls: controls),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioCallBackground extends StatelessWidget {
  const _AudioCallBackground({required this.peerAvatarImage});

  final ImageProvider<Object>? peerAvatarImage;

  @override
  Widget build(BuildContext context) {
    if (peerAvatarImage != null) {
      return Image(
        image: peerAvatarImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Container(color: context.colorScheme.surface);
  }
}
