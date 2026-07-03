import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/duration_extensions.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'active_call_controller.dart';

/// Banner shown between status bar and AppBar when a call is minimized.
class ActiveCallBanner extends ConsumerWidget {
  const ActiveCallBanner({super.key});

  static const double height = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(activeCallControllerProvider);
    if (callState == null || !callState.isMinimized) {
      return const SizedBox.shrink();
    }

    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    final phase = resolveCallUiPhase(
      status: callState.status,
      hasHadPeer: callState.hasHadPeer,
    );
    final statusLabel = switch (phase) {
      CallUiPhase.inCall => Duration(
        seconds: callState.callDurationSeconds,
      ).label,
      CallUiPhase.ringing => l10n.videoCallRinging,
      CallUiPhase.calling => l10n.videoCallCalling,
      CallUiPhase.ended => l10n.videoCallNoAnswer,
    };
    final showDuration = phase == CallUiPhase.inCall;

    final callIcon = callState.isAudioOnly ? Icons.phone : Icons.videocam;

    final bannerController = ref.read(activeCallControllerProvider.notifier);

    final textStyle = (context.textTheme.bodyLarge ?? const TextStyle())
        .copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        );

    return Container(
      width: double.infinity,
      height: height,
      color: colors.success,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _BannerIconButton(
              icon: callState.isMicEnabled ? Icons.mic : Icons.mic_off,
              semanticsLabel: callState.isMicEnabled
                  ? l10n.videoCallMute
                  : l10n.videoCallUnmute,
              backgroundColor: colorScheme.onSurface.withAlpha(50),
              onTap: bannerController.toggleMic,
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () {
                ref
                    .read(navigatorProvider)
                    .go(
                      AudioVideoCallRoute(
                        contactId: callState.contactId,
                        isAudioOnly: callState.isAudioOnly,
                      ).location,
                    );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(callIcon, color: colorScheme.onSurface, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      callState.peerName,
                      style: textStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ' - ',
                    style: textStyle.copyWith(
                      color: colorScheme.onSurface.withAlpha(204),
                    ),
                  ),
                  Text(
                    showDuration
                        ? Duration(seconds: callState.callDurationSeconds).label
                        : statusLabel,
                    style: textStyle.copyWith(
                      color: colorScheme.onSurface.withAlpha(204),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _BannerIconButton(
              icon: Icons.call_end,
              semanticsLabel: l10n.videoCallEnd,
              backgroundColor: colorScheme.error,
              onTap: bannerController.hangUp,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerIconButton extends StatelessWidget {
  const _BannerIconButton({
    required this.icon,
    required this.semanticsLabel,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String semanticsLabel;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        label: semanticsLabel,
        button: true,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colorScheme.onSurface, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
