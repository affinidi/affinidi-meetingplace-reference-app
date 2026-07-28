import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart'
    show AudioVideoCallView;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../../presentation/widgets/action_button.dart';
import '../../../../presentation/widgets/call/call_overlay_widgets.dart';
import '../../../../presentation/widgets/call/call_participant_mute_badge.dart';
import '../../../../presentation/widgets/call/call_top_bar_widget.dart';
import '../../../../presentation/widgets/call/video_call_background.dart';
import '../../../../presentation/widgets/call/video_call_peer_placeholder.dart';
import '../../../../presentation/widgets/call/video_call_pip_action_buttons.dart';
import '../../../../presentation/widgets/call/video_call_pip_window.dart';
import '../../../../presentation/widgets/images/default_profile_image.dart';
import '../../../../presentation/widgets/profile_circle_avatar.dart';
import '../../../widgets/call_ended/call_ended_controller.dart';
import 'audio_video_call_screen_controller.dart';
import 'audio_video_call_screen_state.dart';
import 'call_controls_bar.dart';
import 'group_video_call_screen.dart';
import 'participants/call_participants_sheet.dart';
import 'rules/call_participant_identity_rules.dart';
import 'rules/call_ui_rules.dart';
import 'rules/group_audio_call_view_rules.dart';

part 'audio_call_screen.dart';
part 'call_draggable_mini_grid.dart';
part 'call_error_scaffold.dart';
part 'call_no_answer_screen.dart';
part 'call_overlays.dart';
part 'call_participant_grid.dart';
part 'call_top_bar.dart';
part 'video_call_screen.dart';

class AudioVideoCallScreen extends HookConsumerWidget {
  const AudioVideoCallScreen({
    super.key,
    required this.contactId,
    this.isAudioOnly = false,
  });

  final String contactId;
  final bool isAudioOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasContact = ref.watch(
      audioVideoCallScreenControllerProvider(
        contactId,
      ).select((s) => s.peerName.isNotEmpty || !s.isGroupContact),
    );

    if (!hasContact) {
      return const _ErrorScaffold();
    }

    return _CallScreenBody(contactId: contactId, isAudioOnly: isAudioOnly);
  }
}

class _CallScreenBody extends HookConsumerWidget {
  const _CallScreenBody({required this.contactId, this.isAudioOnly = false});

  final String contactId;
  final bool isAudioOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);

    useEffect(() {
      Future.microtask(() => controller.startCall(isAudioOnly: isAudioOnly));
      return null;
    }, const []);

    // Routing state — only what is needed to decide which screen to show.
    final status = ref.watch(provider.select((s) => s.status));
    final callIsAudioOnly = ref.watch(provider.select((s) => s.isAudioOnly));
    final hasHadPeer = ref.watch(provider.select((s) => s.hasHadPeer));
    final peerName = ref.watch(provider.select((s) => s.peerName));

    // Snackbar side-effects.
    final actionFailure = ref.watch(provider.select((s) => s.actionFailure));
    final micPermissionError = ref.watch(
      provider.select((s) => s.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      provider.select((s) => s.cameraPermissionError),
    );

    final l10n = context.l10n;

    useEffect(() {
      if (actionFailure == null) return null;
      final message = switch (actionFailure.action) {
        CallActionFailure.microphone => l10n.videoCallMicToggleFailed,
        CallActionFailure.camera => l10n.videoCallCameraToggleFailed,
        CallActionFailure.speaker => l10n.videoCallSpeakerToggleFailed,
        CallActionFailure.memberNames => l10n.videoCallMemberNamesFailed,
        CallActionFailure.hangUp => l10n.videoCallHangUpFailed,
      };
      _showCallSnackBar(context, message);
      return null;
    }, [actionFailure]);

    useEffect(() {
      if (!micPermissionError) return null;
      _showCallSnackBar(
        context,
        l10n.videoCallMicPermissionDenied,
        duration: const Duration(seconds: 4),
      );
      return null;
    }, [micPermissionError]);

    useEffect(() {
      if (!cameraPermissionError) return null;
      _showCallSnackBar(
        context,
        l10n.videoCallCameraPermissionDenied,
        duration: const Duration(seconds: 4),
      );
      return null;
    }, [cameraPermissionError]);

    final phase = resolveCallUiPhase(status: status, hasHadPeer: hasHadPeer);
    final mediaType = getMediaTypeFromFlag(callIsAudioOnly);
    final endState = phase == CallUiPhase.ended
        ? resolveCallEndState(status, hasHadPeer: hasHadPeer)
        : null;
    final errorCode = ref.watch(provider.select((s) => s.errorCode));

    final peerIsCallingBack = ref.watch(
      provider.select((s) => s.peerIsCallingBack),
    );
    final isCallEnded =
        endState == CallEndState.callEnded && !peerIsCallingBack;
    final isJoinFailure = status == AudioVideoCallStatus.error;
    final localizedJoinError = errorCode == null
        ? l10n.videoCallError('')
        : l10n.videoCallError(errorCode.name);

    useEffect(() {
      if (!isCallEnded && !isJoinFailure) return null;
      final durationSeconds = ref.read(
        provider.select((s) => s.callDurationSeconds),
      );
      Future.microtask(() {
        ref
            .read(callEndedControllerProvider.notifier)
            .show(
              contactId: contactId,
              peerName: peerName,
              callDurationSeconds: durationSeconds,
              isAudioOnly: callIsAudioOnly,
              errorMessage: isJoinFailure ? localizedJoinError : null,
            );
        if (context.mounted &&
            (ModalRoute.of(context)?.isCurrent ?? false) &&
            Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return null;
    }, [isCallEnded, isJoinFailure, localizedJoinError]);

    // Ended state: call finished (missed, declined, disconnected, error).
    if (phase == CallUiPhase.ended) {
      if (isCallEnded) {
        // The global overlay renders the Call Ended screen.
        return const SizedBox.shrink();
      }
      final calleeCard = ref
          .read(contactsServiceProvider)
          .getContactById(contactId)
          ?.card;
      final calleeAvatarImage = calleeCard?.hasProfilePic == true
          ? calleeCard!.image(cacheManager: ref.read(cacheManagerProvider))
          : null;
      if (shouldShowNoAnswerScreen(
        endState: endState,
        peerIsCallingBack: peerIsCallingBack,
      )) {
        return _CallNoAnswerScreen(
          contactId: contactId,
          mediaType: mediaType,
          peerName: peerName,
          message: l10n.videoCallNoAnswer,
          calleeAvatarImage: callIsAudioOnly ? calleeAvatarImage : null,
        );
      }
      if (peerIsCallingBack) {
        return _CallNoAnswerScreen(
          contactId: contactId,
          mediaType: mediaType,
          peerName: peerName,
          message: null,
          calleeAvatarImage: callIsAudioOnly ? calleeAvatarImage : null,
        );
      }
      if (status == AudioVideoCallStatus.error) {
        return const SizedBox.shrink();
      }
      return const SizedBox.shrink();
    }

    // Route by media type — each screen watches its own state.
    switch (mediaType) {
      case CallMediaType.audio:
        return _AudioCallScreen(contactId: contactId);
      case CallMediaType.video:
        return _VideoCallScreen(contactId: contactId);
    }
  }
}
