import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../themes/tokens/mc_colors.dart';
import 'end_call_banner_controller.dart';

/// Banner shown when the user dismisses a missed or declined call screen.
///
/// Allows the user to either dismiss the notification or place the call again
/// directly from the banner. Auto-dismisses after 4 seconds or can be dismissed
/// by swiping up.
class EndCallBanner extends ConsumerWidget {
  const EndCallBanner({super.key});

  static const double height = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerState = ref.watch(endCallBannerControllerProvider);
    if (bannerState == null) return const SizedBox.shrink();

    // Call UI stays dark in both modes; the ended call is the danger icon,
    // not a red fill.
    final colors = context.customColors;
    final onCall = colors.pureWhite;
    final l10n = context.l10n;
    final controller = ref.read(endCallBannerControllerProvider.notifier);

    final statusLabel = l10n.videoCallNoAnswer;

    final callIcon = bannerState.isAudioOnly ? Icons.call : Icons.videocam;

    final slideOffset = bannerState.slideOutOffset;

    final textStyle = (context.textTheme.bodyLarge ?? const TextStyle())
        .copyWith(
          color: onCall,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        );

    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
          .animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(slideOffset),
              curve: Curves.easeInBack,
            ),
          ),
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < -500) {
            controller.onSwipeUp();
          }
        },
        child: Container(
          width: double.infinity,
          height: height,
          color: colors.callControlSurface,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.dismiss();
              ref
                  .read(navigatorProvider)
                  .go(
                    AudioVideoCallRoute(
                      contactId: bannerState.contactId,
                      isAudioOnly: bannerState.isAudioOnly,
                    ).location,
                  );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(callIcon, color: McColors.dark.dangerText, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    bannerState.peerName,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' - ',
                  style: textStyle.copyWith(color: onCall.withAlpha(204)),
                ),
                Flexible(
                  child: Text(
                    statusLabel,
                    style: textStyle.copyWith(color: onCall.withAlpha(204)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
