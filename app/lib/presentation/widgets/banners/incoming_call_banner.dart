import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' show CallMediaType;

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/incoming_call_service/incoming_call_service.dart';
import '../../../domain/models/contacts/contact_type.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/incoming_call_state_provider.dart';
import '../../../navigation/navigator.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../banners/active_call/active_call_controller.dart';

class IncomingCallBanner extends ConsumerStatefulWidget {
  const IncomingCallBanner({super.key});

  @override
  ConsumerState<IncomingCallBanner> createState() => _IncomingCallBannerState();
}

class _IncomingCallBannerState extends ConsumerState<IncomingCallBanner> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    // Hide banner when a call is active
    final callState = ref.watch(activeCallControllerProvider);
    if (callState != null) return const SizedBox.shrink();

    if (_accepted) return const SizedBox.shrink();

    final event = ref.watch(incomingCallStateProvider);
    if (event == null) return const SizedBox.shrink();

    final contact = ref.watch(
      contactsServiceProvider.select(
        (s) => s.getContactByChannelDid(event.otherPartyChannelDid),
      ),
    );

    final callerName =
        contact?.displayName ??
        contact?.card.displayName ??
        context.l10n.incomingCallBannerUnknownCaller;

    final isGroup = contact?.type == ContactType.group;
    final callService = ref.read(incomingCallServiceProvider.notifier);

    void onJoinOrAccept() {
      setState(() => _accepted = true);
      callService.accept(callId: event.callId);
      final routeContactId = contact?.id ?? event.otherPartyChannelDid;
      ref
          .read(navigatorProvider)
          .go(
            AudioVideoCallRoute(
              contactId: routeContactId,
              isAudioOnly: event.mediaType == CallMediaType.audio,
            ).location,
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  onTap: () => callService.decline(callId: event.callId),
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
