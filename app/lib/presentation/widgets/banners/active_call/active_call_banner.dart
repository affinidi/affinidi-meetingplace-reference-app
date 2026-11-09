import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/duration_extensions.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import '../../../themes/tokens/mc_colors.dart';
import '../../../themes/tokens/mc_icons.dart';
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

    // Call UI stays dark in both modes, so its status colours are the dark
    // mode's.
    final colors = context.customColors;
    final onCall = colors.pureWhite;
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

    final callIcon = callState.isAudioOnly ? McIcons.phone : McIcons.video;

    final bannerController = ref.read(activeCallControllerProvider.notifier);

    final textStyle = (context.textTheme.bodyLarge ?? const TextStyle())
        .copyWith(
          color: onCall,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        );

    return Container(
      width: double.infinity,
      height: height,
      color: colors.callControlSurface,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _BannerIconButton(
              icon: callState.isMicEnabled ? McIcons.mic : McIcons.micOff,
              semanticsLabel: callState.isMicEnabled
                  ? l10n.videoCallMute
                  : l10n.videoCallUnmute,
              backgroundColor: onCall.withAlpha(50),
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
                  Icon(callIcon, color: McColors.dark.ok, size: 24),
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
                    style: textStyle.copyWith(color: onCall.withAlpha(204)),
                  ),
                  Text(
                    showDuration
                        ? Duration(seconds: callState.callDurationSeconds).label
                        : statusLabel,
                    style: textStyle.copyWith(color: onCall.withAlpha(204)),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _BannerIconButton(
              icon: McIcons.hangUp,
              semanticsLabel: l10n.videoCallEnd,
              backgroundColor: McColors.dark.dangerText.withValues(alpha: 0.12),
              foregroundColor: McColors.dark.dangerText,
              borderColor: McColors.dark.dangerText,
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
    this.foregroundColor,
    this.borderColor,
  });

  final IconData icon;
  final String semanticsLabel;
  final Color backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
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
                border: borderColor == null
                    ? null
                    : Border.all(color: borderColor!),
              ),
              child: Icon(
                icon,
                color: foregroundColor ?? context.customColors.pureWhite,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
