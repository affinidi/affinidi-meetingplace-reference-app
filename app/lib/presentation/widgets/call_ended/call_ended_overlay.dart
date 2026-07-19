import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../screens/chat/audio_video_call/call_ended_screen.dart';
import 'call_ended_controller.dart';

/// Global full-screen overlay shown to both parties after a connected call
/// ends.
///
/// Mounted at the top of the `AppHeaderBanner` stack so it covers any screen
/// the user is on, including minimized calls. Watches the call-ended controller
/// and renders `CallEndedScreen` with [Positioned.fill] when active.
class CallEndedOverlay extends ConsumerWidget {
  const CallEndedOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callEndedState = ref.watch(callEndedControllerProvider);
    if (callEndedState == null) return const SizedBox.shrink();

    final contactId = callEndedState.contactId;
    final calleeCard = ref
        .read(contactsServiceProvider)
        .getContactById(contactId)
        ?.card;
    final showAvatar = calleeCard?.hasProfilePic == true;
    final calleeAvatarImage = showAvatar
        ? calleeCard!.image(cacheManager: ref.read(cacheManagerProvider))
        : null;

    return Positioned.fill(
      child: CallEndedScreen(
        contactId: contactId,
        peerName: callEndedState.peerName,
        durationSeconds: callEndedState.callDurationSeconds,
        isAudioOnly: callEndedState.isAudioOnly,
        calleeAvatarImage: calleeAvatarImage,
        errorMessage: callEndedState.errorMessage,
      ),
    );
  }
}
