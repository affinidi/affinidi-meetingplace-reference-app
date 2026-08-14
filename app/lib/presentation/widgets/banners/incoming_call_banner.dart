import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart'
    show CallMediaType;

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/incoming_call_service/incoming_call_notifier.dart';
import '../../../domain/models/contacts/contact_type.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import '../banners/active_call/active_call_controller.dart';
import '../banners/incoming_call/incoming_call_banner_controller.dart';

class IncomingCallBanner extends ConsumerStatefulWidget {
  const IncomingCallBanner({super.key});

  static const double height = 72;

  @override
  ConsumerState<IncomingCallBanner> createState() => _IncomingCallBannerState();
}

class _IncomingCallBannerState extends ConsumerState<IncomingCallBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @visibleForTesting
  AnimationController get slideController => _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide banner when a call is active
    final callState = ref.watch(activeCallControllerProvider);
    if (callState != null) return const SizedBox.shrink();

    final bannerController = ref.watch(incomingCallBannerControllerProvider);
    if (bannerController) return const SizedBox.shrink();

    final event = ref.watch(incomingCallProvider).eventOrNull;
    if (event == null) return const SizedBox.shrink();

    final contact = ref.watch(
      contactsServiceProvider.select(
        (s) => s.getContactByChannelDid(event.otherPartyPermanentChannelDid),
      ),
    );

    final callerName =
        contact?.displayName ??
        contact?.card.displayName ??
        context.l10n.incomingCallBannerUnknownCaller;

    final isGroup = contact?.type == ContactType.group;
    final bannerNotifier = ref.read(
      incomingCallBannerControllerProvider.notifier,
    );

    void onJoinOrAccept() {
      final routeContactId = contact?.id ?? event.otherPartyPermanentChannelDid;
      final isAudioOnly = event.mediaType == CallMediaType.audio;
      final callId = event.callId;
      final callScreenProvider = audioVideoCallScreenControllerProvider(
        routeContactId,
      );

      if (ref.exists(callScreenProvider) &&
          ref.read(callScreenProvider).peerIsCallingBack) {
        bannerNotifier.acceptRecall(
          callId: callId,
          contactId: routeContactId,
          isAudioOnly: isAudioOnly,
        );
      } else {
        bannerNotifier.accept(
          callId: callId,
          otherPartyChannelDid: event.otherPartyPermanentChannelDid,
          mediaType: event.mediaType,
          contactId: contact?.id,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          // Dismiss on upward swipe (negative velocity = upward)
          if (details.velocity.pixelsPerSecond.dy < -300) {
            _slideController.forward().then((_) {
              if (!mounted) return;
              bannerNotifier.hide(callId: event.callId);
              // Restore the resting position after the banner is hidden so the
              // next call is not left off-screen (behind the notch).
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _slideController.reset();
              });
            });
          }
        },
        child: SlideTransition(
          position: _slideAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: context.customColors.incomingCallBannerBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    event.mediaType == CallMediaType.audio
                        ? Icons.phone
                        : Icons.videocam,
                    color: context.customColors.incomingCallBannerCallTypeLabel,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.mediaType == CallMediaType.audio
                              ? context.l10n.incomingCallBannerAudioCall
                              : context.l10n.incomingCallBannerVideoCall,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context
                                .customColors
                                .incomingCallBannerCallTypeLabel,
                          ),
                        ),
                        Text(
                          callerName,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isGroup)
                    _ActionButton(
                      icon: Icons.call_end,
                      color: context.colorScheme.error,
                      semanticsLabel: context.l10n.incomingCallBannerDecline,
                      onTap: () => bannerNotifier.dismiss(callId: event.callId),
                    ),
                  if (!isGroup) const SizedBox(width: 8),
                  if (isGroup)
                    TextButton(
                      onPressed: onJoinOrAccept,
                      style: TextButton.styleFrom(
                        foregroundColor: context.customColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        context.l10n.videoCallGroupCallJoin,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.customColors.success,
                        ),
                      ),
                    )
                  else
                    _ActionButton(
                      icon: Icons.call,
                      color: context.colorScheme.primary,
                      semanticsLabel: context.l10n.incomingCallBannerAccept,
                      onTap: onJoinOrAccept,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: Icon(icon, color: context.colorScheme.onPrimary, size: 18),
        ),
      ),
    );
  }
}
