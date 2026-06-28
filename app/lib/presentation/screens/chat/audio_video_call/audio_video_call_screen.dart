import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallErrorCode,
        AudioVideoCallParticipant,
        AudioVideoCallSession,
        AudioVideoCallStatus,
        CallMediaType;
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart'
    show AudioVideoCallView;

import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../../presentation/widgets/action_button.dart';
import '../../../../presentation/widgets/profile_circle_avatar.dart';
import '../../../../presentation/widgets/video_call_pip_window.dart';
import 'audio_video_call_screen_controller.dart';
import 'audio_video_call_screen_state.dart';
import 'call_controls_bar.dart';
import 'rules/call_ui_rules.dart';

class _CallControls {
  const _CallControls({
    required this.mic,
    required this.speaker,
    this.camera,
    required this.onEndCall,
  });

  final CallButtonConfig mic;
  final CallButtonConfig speaker;

  /// Null means audio-only — no camera button shown.
  final CallButtonConfig? camera;
  final VoidCallback onEndCall;
}

String _formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

void _showCallSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: context.colorScheme.error,
        duration: duration,
      ),
    );
  });
}

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

/// Shared top bar: minimize button (left) + peer name and call status (center).
///
/// Used by both [_AudioCallScreen] and [_VideoCallScreen].
class _CallTopBar extends ConsumerWidget {
  const _CallTopBar({required this.contactId, required this.onMinimize});

  final String contactId;
  final VoidCallback onMinimize;

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

    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onMinimize,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.darkGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_fullscreen,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                peerName,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                switch (phase) {
                  CallUiPhase.inCall => _formatDuration(callDurationSeconds),
                  CallUiPhase.ringing => context.l10n.videoCallRinging,
                  CallUiPhase.calling ||
                  CallUiPhase.ended => context.l10n.videoCallCalling,
                },
                style: textTheme.titleMedium?.copyWith(
                  color: isRinging
                      ? colorScheme.onSurface.withAlpha(153)
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared gradient person avatar placeholder.
///
/// Used in [_AudioCallScreen] (large center avatar when no profile picture).
class _CallPersonAvatar extends StatelessWidget {
  const _CallPersonAvatar();

  static const double _diameter = 192;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = context.customColors;

    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(
              colorScheme.surfaceContainerHigh,
              colors.pureWhite,
              0.3,
            )!,
            Color.lerp(
              colorScheme.surfaceContainerHigh,
              colors.pureWhite,
              0.1,
            )!,
            colorScheme.surfaceContainerHigh,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Icon(
        Icons.person,
        size: _diameter / 2,
        color: colorScheme.onSurface,
      ),
    );
  }
}

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

    // Ended state: call finished (missed, declined, disconnected, error).
    if (phase == CallUiPhase.ended) {
      final endState = resolveCallEndState(status);
      if (endState != null) {
        final calleeCard = ref
            .read(contactsServiceProvider)
            .getContactById(contactId)
            ?.card;
        final calleeAvatarImage = calleeCard?.hasProfilePic == true
            ? calleeCard!.image(cacheManager: ref.read(cacheManagerProvider))
            : null;
        return _NoAnswerScreen(
          contactId: contactId,
          mediaType: mediaType,
          peerName: peerName,
          message: endState == CallEndState.missedCall
              ? context.l10n.videoCallNoAnswer
              : context.l10n.videoCallCallDeclined,
          calleeAvatarImage: callIsAudioOnly ? calleeAvatarImage : null,
        );
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

/// Video call screen: peer camera full-screen with self-view PiP and call
/// overlays.
///
/// For 1:1 calls (at most one peer): the peer's camera fills the
/// background, with a draggable self-view window and the same top-bar and
/// controls overlay as the audio call screen.
///
/// For group calls (two or more peers): falls back to
/// [_ParticipantGrid] with a tiled layout.
class _VideoCallScreen extends ConsumerWidget {
  const _VideoCallScreen({required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);
    final colors = context.customColors;
    final showControls = ref.watch(provider.select((s) => s.showControlsBar));

    final participants = ref.watch(provider.select((s) => s.participants));
    final session = ref.watch(provider.select((s) => s.session));
    final status = ref.watch(provider.select((s) => s.status));
    final errorCode = ref.watch(provider.select((s) => s.errorCode));
    final peerName = ref.watch(provider.select((s) => s.peerName));
    final memberContactCards = ref.watch(
      provider.select((s) => s.memberContactCards),
    );
    final isMicEnabled = ref.watch(provider.select((s) => s.isMicEnabled));
    final isSpeakerEnabled = ref.watch(
      provider.select((s) => s.isSpeakerEnabled),
    );
    final isCameraEnabled = ref.watch(
      provider.select((s) => s.isCameraEnabled),
    );
    final micPermissionError = ref.watch(
      provider.select((s) => s.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      provider.select((s) => s.cameraPermissionError),
    );

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
        isEnabled: isCameraEnabled,
        isDisabled: cameraPermissionError,
        onTap: controller.toggleCamera,
      ),
      onEndCall: () {
        unawaited(controller.leaveCall());
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    final remotePeer = participants.where((p) => !p.isSelf).firstOrNull;
    final selfParticipant = participants.where((p) => p.isSelf).firstOrNull;

    // Group call: two or more peers use the tiled grid layout.
    final remoteCount = participants.where((p) => !p.isSelf).length;
    if (remoteCount > 1) {
      return Scaffold(
        backgroundColor: colors.grey900,
        body: _ParticipantGrid(
          contactId: contactId,
          status: status,
          errorCode: errorCode,
          isAudioOnly: false,
          participants: participants,
          session: session,
          peerName: peerName,
          memberContactCards: memberContactCards,
          controls: _ControlsOverlayContent(controls: controls),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.grey900,
      body: GestureDetector(
        onTap: controller.toggleControlsBar,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: peer camera view or dark fallback
            if (remotePeer != null)
              _VideoView(
                session: session,
                participantId: remotePeer.participantId,
                hasVideo: remotePeer.hasVideo,
                mirror: false,
              )
            else
              Container(color: colors.grey900),

            // Overlay: top bar, self-view window, controls
            Positioned.fill(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: showControls ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !showControls,
                            child: _CallTopBar(
                              contactId: contactId,
                              onMinimize: () {
                                controller.minimize();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      if (selfParticipant != null && isCameraEnabled)
                        VideoCallPiPWindow(
                          contactId: contactId,
                          session: session,
                          participant: selfParticipant,
                          isCameraEnabled: isCameraEnabled,
                          availableSize: constraints.biggest,
                          showControlsBar: showControls,
                          overlayChildren: [
                            if (isCameraEnabled && selfParticipant.hasVideo)
                              _InCallFlipCameraButton(
                                onTap: () =>
                                    unawaited(controller.switchCamera()),
                              ),
                            if (!showControls)
                              _InCallMuteButton(
                                isMicEnabled: isMicEnabled,
                                isPermissionError: micPermissionError,
                                onTap: () => unawaited(controller.toggleMic()),
                              ),
                          ],
                        ),
                      _AnimatedControlsOverlay(
                        visible: showControls,
                        duration: const Duration(milliseconds: 100),
                        child: _ControlsOverlayContent(controls: controls),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves the label shown beneath a participant tile.
///
/// The self participant is always "You". A group member is resolved to their
/// name via [memberContactCards], keyed by the participant's DID. A single
/// peer in a 1:1 call falls back to the contact name.
String _displayNameFor(
  AudioVideoCallParticipant participant, {
  required String youLabel,
  required String peerName,
  required int remoteCount,
  required Map<String, ContactCard> memberContactCards,
}) {
  if (participant.isSelf) return youLabel;
  final did = participant.did;
  if (did != null) {
    final name = memberContactCards[did]?.displayName;
    if (name != null && name.isNotEmpty) return name;
  }
  if (remoteCount <= 1) return peerName;
  return '';
}

class _ParticipantGrid extends ConsumerWidget {
  const _ParticipantGrid({
    required this.contactId,
    required this.status,
    required this.errorCode,
    required this.isAudioOnly,
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.controls,
  });

  final String contactId;
  final AudioVideoCallStatus status;
  final AudioVideoCallErrorCode? errorCode;
  final bool isAudioOnly;
  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final Widget controls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.customColors;
    final textTheme = context.textTheme;

    final provider = audioVideoCallScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);
    final showControls = ref.watch(provider.select((s) => s.showControlsBar));
    final focusedIndex = ref.watch(
      provider.select((s) => s.focusedParticipantIndex),
    );

    if (status == AudioVideoCallStatus.connecting ||
        status == AudioVideoCallStatus.waitingForKeys) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.cyan),
            const SizedBox(height: 16),
            Text(
              status == AudioVideoCallStatus.waitingForKeys
                  ? l10n.videoCallWaitingForEncryption
                  : l10n.videoCallJoiningCall,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.whiteOverlay30,
              ),
            ),
          ],
        ),
      );
    }

    if (status == AudioVideoCallStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.videoCallFailedToJoin(
              errorCode?.name ?? l10n.videoCallUnknownError,
            ),
            style: textTheme.bodyMedium?.copyWith(color: colors.rose),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (participants.isEmpty) {
      return Center(
        child: Text(
          l10n.videoCallWaitingForParticipants,
          style: textTheme.bodyMedium?.copyWith(color: colors.whiteOverlay30),
        ),
      );
    }

    if (focusedIndex != null && focusedIndex >= participants.length) {
      controller.setFocusedParticipant(null);
    }

    if (focusedIndex == null) {
      return _GridLayout(
        participants: participants,
        session: session,
        peerName: peerName,
        memberContactCards: memberContactCards,
        isAudioOnly: isAudioOnly,
        showControls: showControls,
        onToggleControls: controller.toggleControlsBar,
        onSetFocused: controller.setFocusedParticipant,
        onSetControlsVisible: controller.setControlsBarVisible,
        controls: controls,
      );
    }

    return _FocusedLayout(
      participants: participants,
      session: session,
      peerName: peerName,
      memberContactCards: memberContactCards,
      isAudioOnly: isAudioOnly,
      showControls: showControls,
      onToggleControls: controller.toggleControlsBar,
      onSetFocused: controller.setFocusedParticipant,
      miniGridExpanded: ref.watch(provider.select((s) => s.miniGridExpanded)),
      onToggleMiniGridExpanded: controller.toggleMiniGridExpanded,
      focusedIndex: focusedIndex,
      controls: controls,
    );
  }
}

class _GridLayout extends HookWidget {
  const _GridLayout({
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.isAudioOnly,
    required this.showControls,
    required this.onToggleControls,
    required this.onSetControlsVisible,
    required this.onSetFocused,
    required this.controls,
  });

  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final bool isAudioOnly;
  final bool showControls;
  final VoidCallback onToggleControls;
  final void Function({required bool visible}) onSetControlsVisible;
  final void Function(int?) onSetFocused;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final youLabel = context.l10n.videoCallYou;
    final remoteCount = participants.where((p) => !p.isSelf).length;
    final scrollController = useScrollController();
    final pointerDownPixels = useRef(0.0);

    bool scrolledSincePointerDown() {
      if (!scrollController.hasClients) return false;
      return (scrollController.position.pixels - pointerDownPixels.value)
              .abs() >
          1.0;
    }

    return SafeArea(
      child: Stack(
        children: [
          Listener(
            onPointerDown: (_) {
              pointerDownPixels.value = scrollController.hasClients
                  ? scrollController.position.pixels
                  : 0.0;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  onSetControlsVisible(visible: false);
                } else if (notification is ScrollEndNotification) {
                  onSetControlsVisible(visible: true);
                }
                return false;
              },
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 80,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: participants.length,
                itemBuilder: (_, i) {
                  final participant = participants[i];
                  return GestureDetector(
                    onTap: () {
                      if (!scrolledSincePointerDown()) {
                        onSetFocused(i);
                      }
                    },
                    child: _ParticipantTile(
                      participant: participant,
                      session: session,
                      isAudioOnly: isAudioOnly,
                      displayName: _displayNameFor(
                        participant,
                        youLabel: youLabel,
                        peerName: peerName,
                        remoteCount: remoteCount,
                        memberContactCards: memberContactCards,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _AnimatedControlsOverlay(
            visible: showControls,
            duration: const Duration(milliseconds: 100),
            child: controls,
          ),
        ],
      ),
    );
  }
}

class _FocusedLayout extends StatelessWidget {
  const _FocusedLayout({
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.isAudioOnly,
    required this.showControls,
    required this.onToggleControls,
    required this.onSetFocused,
    required this.miniGridExpanded,
    required this.onToggleMiniGridExpanded,
    required this.focusedIndex,
    required this.controls,
  });

  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final bool isAudioOnly;
  final bool showControls;
  final VoidCallback onToggleControls;
  final void Function(int?) onSetFocused;
  final bool miniGridExpanded;
  final VoidCallback onToggleMiniGridExpanded;
  final int focusedIndex;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final youLabel = context.l10n.videoCallYou;
    final remoteCount = participants.where((p) => !p.isSelf).length;

    final fi = focusedIndex;
    final others = <int>[];
    for (var i = 0; i < participants.length; i++) {
      if (i != fi) others.add(i);
    }

    final otherParticipants = <AudioVideoCallParticipant>[];
    final otherDisplayNames = <String>[];
    for (final idx in others) {
      otherParticipants.add(participants[idx]);
      otherDisplayNames.add(
        _displayNameFor(
          participants[idx],
          youLabel: youLabel,
          peerName: peerName,
          remoteCount: remoteCount,
          memberContactCards: memberContactCards,
        ),
      );
    }

    final focusedName = _displayNameFor(
      participants[fi],
      youLabel: youLabel,
      peerName: peerName,
      remoteCount: remoteCount,
      memberContactCards: memberContactCards,
    );

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onToggleControls,
              child: _FocusedTile(
                participant: participants[fi],
                session: session,
                isAudioOnly: isAudioOnly,
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: showControls ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!showControls) onToggleControls();
                        onSetFocused(null);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.grey900.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                    if (focusedName.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.grey900.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            focusedName,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (others.isNotEmpty)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: showControls ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showControls,
                child: _DraggableMiniGrid(
                  participants: otherParticipants,
                  session: session,
                  displayNames: otherDisplayNames,
                  isAudioOnly: isAudioOnly,
                  miniGridExpanded: miniGridExpanded,
                  onToggleMiniGridExpanded: onToggleMiniGridExpanded,
                  onTapParticipant: (tappedIdx) {
                    onSetFocused(others[tappedIdx]);
                  },
                ),
              ),
            ),
          _AnimatedControlsOverlay(
            visible: showControls,
            duration: const Duration(milliseconds: 150),
            child: controls,
          ),
        ],
      ),
    );
  }
}

class _FocusedTile extends StatelessWidget {
  const _FocusedTile({
    required this.participant,
    required this.session,
    required this.isAudioOnly,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final bool isAudioOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Container(
      color: colors.grey900,
      child: !isAudioOnly && participant.hasVideo
          ? IgnorePointer(
              child: _VideoView(
                session: session,
                participantId: participant.participantId,
                hasVideo: participant.hasVideo,
                mirror: participant.isSelf,
              ),
            )
          : Center(
              child: Icon(Icons.person, color: colors.whiteOverlay30, size: 48),
            ),
    );
  }
}

class _DraggableMiniGrid extends HookWidget {
  const _DraggableMiniGrid({
    required this.participants,
    required this.session,
    required this.displayNames,
    required this.isAudioOnly,
    required this.miniGridExpanded,
    required this.onToggleMiniGridExpanded,
    required this.onTapParticipant,
  });

  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final List<String> displayNames;
  final bool isAudioOnly;
  final bool miniGridExpanded;
  final VoidCallback onToggleMiniGridExpanded;
  final void Function(int index) onTapParticipant;

  static const double _tileSize = 64;
  static const double _spacing = 4;
  static const int _maxColumns = 2;
  static const int _maxCollapsed = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;

    final alignment = useState(const Alignment(1.0, -1.0));

    final hasOverflow = participants.length > _maxCollapsed;
    final isExpanded = miniGridExpanded && hasOverflow;
    final visibleCount = isExpanded
        ? participants.length
        : participants.length.clamp(0, _maxCollapsed);
    final overflow = participants.length - _maxCollapsed;

    final columns = visibleCount == 1 ? 1 : _maxColumns;
    final collapsedRows = (visibleCount / columns).ceil();
    final width = columns * _tileSize + (columns - 1) * _spacing + 8;

    const barHeight = 28.0;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxExpandedHeight = screenHeight * 0.6;
    final naturalTileHeight =
        collapsedRows * _tileSize + (collapsedRows - 1) * _spacing + 8;
    final totalNatural = naturalTileHeight + (hasOverflow ? barHeight : 0);
    final height = isExpanded
        ? totalNatural.clamp(0.0, maxExpandedHeight)
        : naturalTileHeight + (hasOverflow ? barHeight : 0);
    final tileAreaHeight = height - (hasOverflow ? barHeight : 0);
    final needsScroll = isExpanded && naturalTileHeight > tileAreaHeight;

    final snapController = useAnimationController();
    final miniScrollController = useScrollController();
    final miniPointerDownPixels = useRef(0.0);

    final startX = useRef(0.0);
    final targetX = useRef(1.0);

    useEffect(() {
      void listener() {
        final t = snapController.value;
        alignment.value = Alignment(
          startX.value + (targetX.value - startX.value) * t,
          alignment.value.y,
        );
      }

      snapController.addListener(listener);
      return () => snapController.removeListener(listener);
    }, [snapController]);

    return Align(
      alignment: alignment.value,
      child: GestureDetector(
        onPanStart: isExpanded ? null : (_) => snapController.stop(),
        onPanUpdate: isExpanded
            ? null
            : (details) {
                final size = MediaQuery.sizeOf(context);
                final dx = details.delta.dx / (size.width / 4);
                final dy = details.delta.dy / (size.height / 4);
                alignment.value = Alignment(
                  (alignment.value.x + dx).clamp(-1.0, 1.0),
                  (alignment.value.y + dy).clamp(-1.0, 1.0),
                );
              },
        onPanEnd: isExpanded
            ? null
            : (_) {
                startX.value = alignment.value.x;
                targetX.value = alignment.value.x >= 0 ? 1.0 : -1.0;
                snapController
                  ..reset()
                  ..animateWith(
                    SpringSimulation(
                      const SpringDescription(
                        mass: 1,
                        stiffness: 150,
                        damping: 18,
                      ),
                      0,
                      1,
                      0,
                    ),
                  );
              },
        onTapUp: isExpanded
            ? null
            : (details) {
                final x = details.localPosition.dx - 4;
                final y = details.localPosition.dy - 4;
                final col = (x / (_tileSize + _spacing)).floor();
                final row = (y / (_tileSize + _spacing)).floor();
                final index = row * columns + col;
                if (index >= 0 && index < visibleCount) {
                  onTapParticipant(index);
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.grey900.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors.grey900.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(
                child: !isExpanded
                    ? _MiniGridTileWrap(
                        count: visibleCount,
                        isExpandedMode: false,
                        participants: participants,
                        session: session,
                        displayNames: displayNames,
                        isAudioOnly: isAudioOnly,
                        onTapParticipant: onTapParticipant,
                      )
                    : needsScroll
                    ? Listener(
                        onPointerDown: (_) {
                          miniPointerDownPixels.value =
                              miniScrollController.hasClients
                              ? miniScrollController.position.pixels
                              : 0.0;
                        },
                        child: SingleChildScrollView(
                          controller: miniScrollController,
                          child: _MiniGridTileWrap(
                            count: visibleCount,
                            isExpandedMode: true,
                            expandedNotifier: null,
                            onCollapse: onToggleMiniGridExpanded,
                            participants: participants,
                            session: session,
                            displayNames: displayNames,
                            isAudioOnly: isAudioOnly,
                            onTapParticipant: (i) {
                              if (miniScrollController.hasClients &&
                                  (miniScrollController.position.pixels -
                                              miniPointerDownPixels.value)
                                          .abs() >
                                      1.0) {
                                return;
                              }
                              onTapParticipant(i);
                            },
                          ),
                        ),
                      )
                    : _MiniGridTileWrap(
                        count: visibleCount,
                        isExpandedMode: true,
                        expandedNotifier: null,
                        onCollapse: onToggleMiniGridExpanded,
                        participants: participants,
                        session: session,
                        displayNames: displayNames,
                        isAudioOnly: isAudioOnly,
                        onTapParticipant: onTapParticipant,
                      ),
              ),
              if (hasOverflow)
                GestureDetector(
                  onTap: onToggleMiniGridExpanded,
                  child: Container(
                    height: barHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.grey900.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: colorScheme.onSurface,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpanded
                              ? context.l10n.videoCallShowLess
                              : context.l10n.videoCallShowMore(overflow),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniGridTileWrap extends StatelessWidget {
  const _MiniGridTileWrap({
    required this.count,
    required this.isExpandedMode,
    required this.participants,
    required this.session,
    required this.displayNames,
    required this.isAudioOnly,
    required this.onTapParticipant,
    this.expandedNotifier,
    this.onCollapse,
  });

  final int count;
  final bool isExpandedMode;
  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final List<String> displayNames;
  final bool isAudioOnly;
  final void Function(int index) onTapParticipant;
  final ValueNotifier<bool>? expandedNotifier;
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _DraggableMiniGrid._spacing,
      runSpacing: _DraggableMiniGrid._spacing,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isExpandedMode
                ? () {
                    expandedNotifier?.value = false;
                    onCollapse?.call();
                    onTapParticipant(i);
                  }
                : null,
            child: SizedBox(
              width: _DraggableMiniGrid._tileSize,
              height: _DraggableMiniGrid._tileSize,
              child: IgnorePointer(
                child: _ParticipantTile(
                  participant: participants[i],
                  session: session,
                  isAudioOnly: isAudioOnly,
                  displayName: displayNames[i],
                  borderRadius: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.session,
    required this.isAudioOnly,
    required this.displayName,
    this.borderRadius = 12,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final bool isAudioOnly;
  final String displayName;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final showVideo = !isAudioOnly && participant.hasVideo;

    return Container(
      decoration: BoxDecoration(
        color: colors.grey900,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showVideo)
              Positioned.fill(
                child: IgnorePointer(
                  child: _VideoView(
                    session: session,
                    participantId: participant.participantId,
                    hasVideo: participant.hasVideo,
                    mirror: participant.isSelf,
                  ),
                ),
              )
            else
              Center(
                child: Icon(
                  Icons.person,
                  color: colors.whiteOverlay30,
                  size: 48,
                ),
              ),
            if (displayName.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 8,
                child: Text(
                  displayName,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    shadows: const [Shadow(blurRadius: 4)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedControlsOverlay extends StatelessWidget {
  const _AnimatedControlsOverlay({
    required this.visible,
    required this.duration,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        duration: duration,
        offset: visible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: duration,
          opacity: visible ? 1.0 : 0.0,
          child: child,
        ),
      ),
    );
  }
}

class _ControlsOverlayContent extends StatelessWidget {
  const _ControlsOverlayContent({required this.controls});

  final _CallControls controls;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CallControlsBar(
          mic: controls.mic,
          speaker: controls.speaker,
          camera: controls.camera,
          onEndCall: controls.onEndCall,
        ),
      ],
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customColors.grey900,
      appBar: AppBar(
        backgroundColor: context.customColors.grey900,
        foregroundColor: context.colorScheme.onSurface,
        title: Text(context.l10n.videoCallTitle),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          context.l10n.videoCallFailedToJoin(
            context.l10n.videoCallUnknownError,
          ),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.customColors.rose,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Renders a participant's video via [AudioVideoCallView].
///
/// Returns [SizedBox.shrink] when no [AudioVideoCallSession] is active.
class _VideoView extends StatelessWidget {
  const _VideoView({
    required this.session,
    required this.participantId,
    required this.hasVideo,
    this.mirror = false,
  });

  final AudioVideoCallSession? session;
  final String participantId;
  final bool hasVideo;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return AudioVideoCallView(
      session: session,
      participantId: participantId,
      hasVideo: hasVideo,
      mirror: mirror,
    );
  }
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

    final calleeCard = ref
        .read(contactsServiceProvider)
        .getContactById(contactId)
        ?.card;
    final calleeAvatarImage = calleeCard?.hasProfilePic == true
        ? calleeCard!.image(cacheManager: ref.read(cacheManagerProvider))
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

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: GestureDetector(
        onTap: controller.toggleControlsBar,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: full-screen profile picture or dark fallback
            if (calleeAvatarImage != null)
              Image(
                image: calleeAvatarImage,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Container(color: context.colorScheme.surface),

            // Foreground: top bar + centered avatar + bottom controls
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: showControls ? 1.0 : 0.0,
                        child: IgnorePointer(
                          ignoring: !showControls,
                          child: _CallTopBar(
                            contactId: contactId,
                            onMinimize: () {
                              controller.minimize();
                              if (context.mounted) Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ),

                    // Center: gradient avatar (only when no profile picture)
                    if (calleeAvatarImage == null)
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

/// No-answer end screen for missed or declined calls.
///
/// Renders mode-specific UI: audio calls show avatar + name + message,
/// video calls show a darker surface with the same layout.
class _NoAnswerScreen extends ConsumerWidget {
  const _NoAnswerScreen({
    required this.contactId,
    required this.mediaType,
    required this.peerName,
    required this.message,
    this.calleeAvatarImage,
  });

  final String contactId;
  final CallMediaType mediaType;
  final String peerName;
  final String message;
  final ImageProvider<Object>? calleeAvatarImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      audioVideoCallScreenControllerProvider(contactId).notifier,
    );
    final callIsAudioOnly = ref.read(
      audioVideoCallScreenControllerProvider(
        contactId,
      ).select((s) => s.isAudioOnly),
    );
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isAudioOnly = mediaType == CallMediaType.audio;

    final backgroundColor = isAudioOnly
        ? colorScheme.surface
        : colors.callControlSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  if (isAudioOnly)
                    _CallEndAvatar(image: calleeAvatarImage)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 24),
                  Text(
                    peerName,
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _NoAnswerActionBar(
                isAudioOnly: isAudioOnly,
                onCancel: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
                onCallAgain: () => unawaited(
                  controller.restartCall(isAudioOnly: callIsAudioOnly),
                ),
                cancelContainerColor: isAudioOnly
                    ? colors.callControlSurface
                    : colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar for end-call UI, with placeholder fallback.
/// Uses the app-wide [ProfileCircleAvatar] pattern for consistency.
class _CallEndAvatar extends StatelessWidget {
  const _CallEndAvatar({required this.image});

  final ImageProvider<Object>? image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ProfileCircleAvatar(
        radius: 75,
        image: image,
        child: Icon(
          Icons.person,
          size: 75,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NoAnswerActionBar extends StatelessWidget {
  const _NoAnswerActionBar({
    required this.isAudioOnly,
    required this.onCancel,
    required this.onCallAgain,
    required this.cancelContainerColor,
  });

  final bool isAudioOnly;
  final VoidCallback onCancel;
  final VoidCallback onCallAgain;
  final Color cancelContainerColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NoAnswerActionButton(
              icon: Icons.close,
              label: l10n.videoCallCancel,
              iconColor: colorScheme.onSurface,
              containerColor: cancelContainerColor,
              onTap: onCancel,
            ),
            const SizedBox(width: 80),
            _NoAnswerActionButton(
              icon: isAudioOnly ? Icons.call : Icons.videocam,
              label: l10n.videoCallAgain,
              iconColor: colors.pureWhite,
              containerColor: colors.success,
              onTap: onCallAgain,
            ),
          ],
        ),
      ),
    );
  }
}

class _InCallFlipCameraButton extends StatelessWidget {
  const _InCallFlipCameraButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      right: 10,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.darkGrey.withValues(alpha: 0.75),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.flip_camera_ios, color: colors.pureWhite, size: 16),
        ),
      ),
    );
  }
}

class _InCallMuteButton extends StatelessWidget {
  const _InCallMuteButton({
    required this.isMicEnabled,
    required this.isPermissionError,
    required this.onTap,
  });

  final bool isMicEnabled;
  final bool isPermissionError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      left: 10,
      child: Opacity(
        opacity: isPermissionError ? 0.4 : 1.0,
        child: GestureDetector(
          onTap: isPermissionError ? null : onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isMicEnabled
                  ? colors.darkGrey.withValues(alpha: 0.75)
                  : colors.pureWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMicEnabled ? Icons.mic : Icons.mic_off,
              color: isMicEnabled ? colors.pureWhite : colors.rose,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoAnswerActionButton extends StatelessWidget {
  const _NoAnswerActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.containerColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color containerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: containerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
