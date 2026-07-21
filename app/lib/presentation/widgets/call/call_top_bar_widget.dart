import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/duration_extensions.dart';
import '../../screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import '../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'call_overlay_widgets.dart';

/// Call header bar showing peer name, call status, duration, and optional
/// trailing action.
class CallTopBarWidget extends ConsumerWidget {
  const CallTopBarWidget({
    super.key,
    required this.contactId,
    required this.onMinimize,
    this.trailingIcon,
    this.onTrailingPressed,
    this.trailing,
    this.statusPill,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.centerPadding = EdgeInsets.zero,
  });

  final String contactId;
  final VoidCallback onMinimize;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final Widget? trailing;
  final Widget? statusPill;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry centerPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final peerName = ref.watch(provider.select((s) => s.peerName));
    final phase = ref.watch(
      provider.select(
        (s) => resolveCallUiPhase(status: s.status, hasHadPeer: s.hasHadPeer),
      ),
    );
    final callDurationSeconds = ref.watch(
      provider.select((s) => s.callDurationSeconds),
    );
    final isRinging = phase != CallUiPhase.inCall;

    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          CallTopBarActionButton(
            icon: Icons.close_fullscreen,
            onPressed: onMinimize,
          ),
          Expanded(
            child: Padding(
              padding: centerPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    peerName,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    switch (phase) {
                      CallUiPhase.inCall => Duration(
                        seconds: callDurationSeconds,
                      ).label,
                      CallUiPhase.ringing => context.l10n.videoCallRinging,
                      CallUiPhase.calling ||
                      CallUiPhase.ended => context.l10n.videoCallCalling,
                    },
                    style: textTheme.titleMedium?.copyWith(
                      color: isRinging
                          ? colorScheme.onSurface.withAlpha(153)
                          : colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (statusPill != null) ...[
                    const SizedBox(height: 8),
                    statusPill!,
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (trailingIcon != null && onTrailingPressed != null)
            CallTopBarActionButton(
              icon: trailingIcon!,
              onPressed: onTrailingPressed!,
            )
          else
            const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}
