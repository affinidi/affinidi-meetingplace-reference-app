import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart'
    show AudioVideoCallView;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../profile_circle_avatar.dart';
import 'video_call_pip_overlay.dart' show VideoCallPiPOverlay;

Offset? _lastPiPPosition;

/// Clears the remembered PiP drag position so the next call starts from the
/// default resting spot.
void resetVideoCallPiPPosition() {
  _lastPiPPosition = null;
}

@visibleForTesting
Offset resolveVideoCallPiPRestingPosition({
  required Size availableSize,
  required double windowWidth,
  required double baseHeight,
  required double bottomInset,
  required bool showControlsBar,
  required double systemGestureLeft,
  Offset? rememberedPosition,
}) {
  final maxX = availableSize.width - windowWidth - VideoCallPiPWindow._margin;
  final maxY = showControlsBar
      ? availableSize.height -
            baseHeight -
            VideoCallPiPWindow._controlsBarHeight
      : availableSize.height - baseHeight - VideoCallPiPWindow._margin;

  final minX =
      VideoCallPiPWindow._margin +
      (systemGestureLeft - VideoCallPiPWindow._margin).clamp(
        0.0,
        VideoCallPiPWindow._margin,
      );
  const minY = VideoCallPiPWindow._margin;

  final defaultY =
      availableSize.height -
      bottomInset -
      VideoCallPiPWindow._controlsBarHeight -
      baseHeight;
  final rawPos = rememberedPosition ?? Offset(maxX, defaultY);

  return Offset(rawPos.dx.clamp(minX, maxX), rawPos.dy.clamp(minY, maxY));
}

/// Draggable self-camera PiP window shared between the in-call screen and
/// [VideoCallPiPOverlay].
///
/// - Rectangular (120×180) when the camera has an active video track.
/// - Square (120×120) with an avatar placeholder when the camera has no track.
/// - Drags freely within [availableSize] and snaps to the nearest horizontal
///   edge on release.
/// - Tap behaviour is controlled by [onTap]. Pass `null` to simply absorb
///   taps without triggering the parent gesture detector (the default in the
///   in-call screen).
/// - Pass [additionalSize] to uniformly grow the window (used by
///   [VideoCallPiPOverlay]'s first-tap expand animation).
/// - Pass [overlayChildren] to layer action buttons on top of the content
///   (flip-camera, mute, etc.).
/// - Pass [showControlsBar] so the window leaves room above the controls bar
///   when calculating the drag bottom boundary.
class VideoCallPiPWindow extends HookConsumerWidget {
  const VideoCallPiPWindow({
    super.key,
    required this.contactId,
    required this.session,
    required this.participant,
    required this.isCameraEnabled,
    required this.availableSize,
    this.primaryChild,
    this.useCameraSizedWindowWhenVideoOff = false,
    this.showControlsBar = false,
    this.onTap,
    this.additionalSize = 0.0,
    this.overlayChildren = const [],
  });

  final String contactId;
  final AudioVideoCallSession? session;
  final AudioVideoCallParticipant participant;
  final bool isCameraEnabled;
  final Widget? primaryChild;
  final bool useCameraSizedWindowWhenVideoOff;

  /// The space in which the window can be dragged.
  /// In the call screen this is the SafeArea LayoutBuilder constraints.
  /// In the floating overlay this is MediaQuery.sizeOf(context).
  final Size availableSize;

  /// Whether the controls bar is visible. When true the drag bottom boundary
  /// is raised to prevent the window overlapping the controls.
  final bool showControlsBar;

  /// Tap callback. Null absorbs the tap without side-effects.
  final VoidCallback? onTap;

  /// Extra pixels added equally to width and height. Used for the
  /// first-tap expand animation in [VideoCallPiPOverlay].
  final double additionalSize;

  /// Widgets layered in the Stack on top of the video / avatar content.
  /// Positioned widgets (e.g. corner buttons) work naturally here.
  final List<Widget> overlayChildren;

  static const double _windowWidth = 120;
  static const double _cameraHeight = 180;
  static const double _offHeight = 120;
  static const double _cornerRadius = 12;
  static const double _margin = 16;

  /// Approximate height of the controls bar (padding + pill + safe-area
  /// inset is handled by the SafeArea ancestor).
  static const double _controlsBarHeight = 124;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.customColors;

    final cameraOn = isCameraEnabled && participant.hasVideo;
    final baseHeight = cameraOn || useCameraSizedWindowWhenVideoOff
        ? _cameraHeight
        : _offHeight;
    final windowWidth = _windowWidth + additionalSize;
    final windowHeight = baseHeight + additionalSize;

    final availableWidth = availableSize.width;
    final availableHeight = availableSize.height;

    final maxX = availableWidth - windowWidth - _margin;
    final maxY = showControlsBar
        ? availableHeight - windowHeight - _controlsBarHeight
        : availableHeight - windowHeight - _margin;

    final systemGestureLeft = context.mediaQuery.systemGestureInsets.left;
    final minX = _margin + (systemGestureLeft - _margin).clamp(0.0, _margin);
    const minY = _margin;

    final position = useState<Offset?>(_lastPiPPosition);
    final isDragging = useState(false);
    final dragStartGlobal = useRef<Offset?>(null);
    final posAtDragStart = useRef<Offset>(Offset.zero);

    final bottomInset = context.mediaQuery.padding.bottom;
    final pos = resolveVideoCallPiPRestingPosition(
      availableSize: availableSize,
      windowWidth: windowWidth,
      baseHeight: windowHeight,
      bottomInset: bottomInset,
      showControlsBar: showControlsBar,
      systemGestureLeft: systemGestureLeft,
      rememberedPosition: position.value,
    );

    return AnimatedPositioned(
      duration: isDragging.value
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ?? () {},
        onPanStart: (details) {
          isDragging.value = true;
          dragStartGlobal.value = details.globalPosition;
          posAtDragStart.value = pos;
        },
        onPanUpdate: (details) {
          final start = dragStartGlobal.value;
          if (start == null) return;
          final delta = details.globalPosition - start;
          position.value = Offset(
            (posAtDragStart.value.dx + delta.dx).clamp(minX, maxX),
            (posAtDragStart.value.dy + delta.dy).clamp(minY, maxY),
          );
        },
        onPanEnd: (_) {
          isDragging.value = false;
          final currentX = position.value?.dx ?? pos.dx;
          final midX = (minX + maxX) / 2;
          final snapped = Offset(
            currentX < midX ? minX : maxX,
            (position.value?.dy ?? pos.dy).clamp(minY, maxY),
          );
          position.value = snapped;
          _lastPiPPosition = snapped;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: windowWidth,
          height: windowHeight,
          decoration: BoxDecoration(
            color: colors.callControlSurface,
            borderRadius: BorderRadius.circular(_cornerRadius),
            boxShadow: [
              BoxShadow(
                color: colors.grey900.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_cornerRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child:
                      primaryChild ??
                      (cameraOn
                          ? _SelfVideoView(
                              session: session,
                              participantId: participant.participantId,
                              hasVideo: participant.hasVideo,
                            )
                          : const Center(child: _SelfAvatarPlaceholder())),
                ),
                ...overlayChildren,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelfVideoView extends StatelessWidget {
  const _SelfVideoView({
    required this.session,
    required this.participantId,
    required this.hasVideo,
  });

  final AudioVideoCallSession? session;
  final String participantId;
  final bool hasVideo;

  @override
  Widget build(BuildContext context) {
    return AudioVideoCallView(
      session: session,
      participantId: participantId,
      hasVideo: hasVideo,
      mirror: true,
    );
  }
}

/// Avatar shown in the PiP window when the camera has no active video track.
/// Displays the current identity's profile picture, falling back to a
/// person icon if no profile picture is set.
class _SelfAvatarPlaceholder extends ConsumerWidget {
  const _SelfAvatarPlaceholder();

  static const double _diameter = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(
      identitiesServiceProvider.select(
        (s) => s.currentIdentity ?? s.identities.firstOrNull,
      ),
    );
    final cacheManager = ref.read(cacheManagerProvider);
    final image = identity != null && identity.card.hasProfilePic
        ? identity.card.image(cacheManager: cacheManager)
        : null;

    return ProfileCircleAvatar(
      radius: _diameter / 2,
      image: image,
      child: Icon(
        Icons.person,
        size: _diameter / 2,
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
