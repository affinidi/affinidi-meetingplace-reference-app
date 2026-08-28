import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../profile_circle_avatar.dart';
import 'ongoing_group_call_banner_state.dart';
import 'ongoing_group_call_controller.dart';

/// Diameter of each overlapping avatar in the ongoing-call banner.
const double kOngoingCallAvatarSize = 32;

/// Horizontal overlap between adjacent avatars. Small so the row stays
/// avatar-focused while still reading as a stack.
const double kOngoingCallAvatarOverlap = 10;

/// Computes how many avatars fit within [maxWidth] without overflowing, given
/// each avatar is [avatarSize] wide and adjacent avatars overlap by [overlap].
///
/// The rendered width of `k` avatars is
/// `avatarSize + (k - 1) * (avatarSize - overlap)`. Returns the largest `k`
/// (capped at [total]) whose width fits, or `0` when not even one avatar fits.
/// This is what keeps avatars from ever reaching or overlapping the Join
/// button: rendering stops once the next avatar would exceed the available
/// width.
int visibleAvatarCount({
  required double maxWidth,
  required int total,
  double avatarSize = kOngoingCallAvatarSize,
  double overlap = kOngoingCallAvatarOverlap,
}) {
  if (total <= 0 || maxWidth <= 0 || avatarSize <= 0) return 0;
  if (avatarSize > maxWidth) return 0;

  final advance = avatarSize - overlap;
  if (advance <= 0) return 1; // Fully overlapping: only one avatar is visible.

  final fit = 1 + ((maxWidth - avatarSize) / advance).floor();
  return fit.clamp(1, total);
}

/// Banner shown below the chat title while a group call is in progress
/// and the local user has not joined it. Tapping Join opens the call screen.
class OngoingGroupCallBanner extends ConsumerWidget {
  const OngoingGroupCallBanner({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref
        .watch(ongoingGroupCallBannerProvider(contactId))
        .asData
        ?.value;
    if (data == null) return const SizedBox.shrink();

    return OngoingGroupCallBannerView(
      data: data,
      onJoin: () => context.push(
        AudioVideoCallRoute(
          contactId: contactId,
          isAudioOnly: data.isAudioOnly,
        ).location,
      ),
    );
  }
}

/// Pure presentation of the ongoing-call banner. Kept ref-free so it can be
/// exercised directly in widget tests.
class OngoingGroupCallBannerView extends StatelessWidget {
  const OngoingGroupCallBannerView({
    super.key,
    required this.data,
    required this.onJoin,
  });

  final OngoingGroupCallBannerData data;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.customColors.darkGrey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.videoCallOngoingCall(data.participantCount),
                  style: context.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _OngoingCallAvatarStack(avatars: data.avatars),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _JoinButton(onPressed: onJoin),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.call, size: 18),
      label: Text(context.l10n.videoCallGroupCallJoin),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Renders the ongoing participants as overlapping avatars, dropping any that
/// would not fit the available width so they never reach the Join button.
class _OngoingCallAvatarStack extends StatelessWidget {
  const _OngoingCallAvatarStack({required this.avatars});

  final List<OngoingGroupCallAvatar> avatars;

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return const SizedBox(height: kOngoingCallAvatarSize);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final visible = visibleAvatarCount(
          maxWidth: constraints.maxWidth,
          total: avatars.length,
        );
        if (visible == 0) {
          return const SizedBox(height: kOngoingCallAvatarSize);
        }

        const advance = kOngoingCallAvatarSize - kOngoingCallAvatarOverlap;
        final width = kOngoingCallAvatarSize + (visible - 1) * advance;

        return SizedBox(
          height: kOngoingCallAvatarSize,
          width: width,
          child: Stack(
            children: [
              for (var i = 0; i < visible; i++)
                Positioned(
                  left: i * advance,
                  child: _RingedAvatar(
                    key: ValueKey(avatars[i].id),
                    avatar: avatars[i],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RingedAvatar extends StatelessWidget {
  const _RingedAvatar({super.key, required this.avatar});

  final OngoingGroupCallAvatar avatar;

  @override
  Widget build(BuildContext context) {
    final initial = (avatar.firstName ?? '').trim();
    return Container(
      width: kOngoingCallAvatarSize,
      height: kOngoingCallAvatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.customColors.darkGrey, width: 2),
      ),
      child: ProfileCircleAvatar(
        image: avatar.image,
        radius: kOngoingCallAvatarSize / 2,
        child: initial.isEmpty
            ? const Icon(Icons.person, size: 18)
            : Text(
                initial.substring(0, 1).toUpperCase(),
                style: context.textTheme.labelMedium,
              ),
      ),
    );
  }
}
