import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/navigator.dart';
import '../../navigation/routes/dashboard_routes.dart';
import '../app/app_header_banner.dart' show AppHeaderBanner;
import '../screens/chat/audio_video_call/audio_video_call_screen.dart'
    show AudioVideoCallScreen;
import '../screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import '../widgets/banners/active_call/active_call_controller.dart';
import 'video_call_pip_window.dart';

/// Global wrapper that shows [VideoCallPiPWindow] above all routes when a
/// video call is minimized.
///
/// Placed at the top of the [AppHeaderBanner] Stack. Renders only when:
/// - a call is active and minimized (`isMinimized == true`)
/// - the call is not audio-only
///
/// The self camera being off does not hide the window — it renders the self
/// avatar, matching the in-screen self-view.
///
/// Tapping once expands the window slightly as a hint; tapping again
/// navigates back to [AudioVideoCallScreen].
class VideoCallPiPOverlay extends ConsumerWidget {
  const VideoCallPiPOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(activeCallControllerProvider);

    if (callState == null || !callState.isMinimized || callState.isAudioOnly) {
      return const SizedBox.shrink();
    }

    final contactId = callState.contactId;

    final session = ref.read(activeCallControllerProvider.notifier).session;
    final participant = callState.selfParticipant;
    final isCameraEnabled = callState.isCameraEnabled;
    final micPermissionError = ref.watch(
      audioVideoCallScreenControllerProvider(
        contactId,
      ).select((s) => s.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      audioVideoCallScreenControllerProvider(
        contactId,
      ).select((s) => s.cameraPermissionError),
    );

    if (participant == null) return const SizedBox.shrink();

    return _ExpandableOverlay(
      contactId: contactId,
      session: session,
      participant: participant,
      isCameraEnabled: isCameraEnabled,
      micPermissionError: micPermissionError,
      cameraPermissionError: cameraPermissionError,
    );
  }
}

class _ExpandableOverlay extends HookConsumerWidget {
  const _ExpandableOverlay({
    required this.contactId,
    required this.session,
    required this.participant,
    required this.isCameraEnabled,
    required this.micPermissionError,
    required this.cameraPermissionError,
  });

  final String contactId;
  final AudioVideoCallSession? session;
  final AudioVideoCallParticipant participant;
  final bool isCameraEnabled;
  final bool micPermissionError;
  final bool cameraPermissionError;

  static const double _expandedExtra = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.sizeOf(context);
    final isExpanded = useState(false);

    final controller = ref.read(
      audioVideoCallScreenControllerProvider(contactId).notifier,
    );
    final isMicEnabled = ref.watch(
      audioVideoCallScreenControllerProvider(
        contactId,
      ).select((s) => s.isMicEnabled),
    );

    // Auto-collapse icons after 2 seconds.
    useEffect(() {
      if (!isExpanded.value) return null;
      final timer = Timer(const Duration(seconds: 2), () {
        isExpanded.value = false;
      });
      return timer.cancel;
    }, [isExpanded.value]);

    void maximize() {
      isExpanded.value = false;
      ref
          .read(navigatorProvider)
          .go(
            AudioVideoCallRoute(
              contactId: contactId,
              isAudioOnly: false,
            ).location,
          );
    }

    return VideoCallPiPWindow(
      contactId: contactId,
      session: session,
      participant: participant,
      isCameraEnabled: isCameraEnabled,
      availableSize: screenSize,
      additionalSize: isExpanded.value ? _expandedExtra : 0,
      onTap: () => isExpanded.value = !isExpanded.value,
      overlayChildren: isExpanded.value
          ? [
              _PiPMuteButton(
                isMicEnabled: isMicEnabled,
                isPermissionError: micPermissionError,
                onTap: controller.toggleMic,
              ),
              _PiPExpandButton(onTap: maximize),
              _PiPFlipCameraButton(
                isPermissionError: cameraPermissionError,
                onTap: controller.switchCamera,
              ),
            ]
          : const [],
    );
  }
}

class _PiPMuteButton extends StatelessWidget {
  const _PiPMuteButton({
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

class _PiPExpandButton extends StatelessWidget {
  const _PiPExpandButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      right: 44,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.darkGrey.withValues(alpha: 0.75),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.open_in_full, color: colors.pureWhite, size: 14),
        ),
      ),
    );
  }
}

class _PiPFlipCameraButton extends StatelessWidget {
  const _PiPFlipCameraButton({
    required this.isPermissionError,
    required this.onTap,
  });

  final bool isPermissionError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      right: 10,
      child: Opacity(
        opacity: isPermissionError ? 0.4 : 1.0,
        child: GestureDetector(
          onTap: isPermissionError ? null : onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.darkGrey.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flip_camera_ios,
              color: colors.pureWhite,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
