import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallParticipant, AudioVideoCallSession;
import 'package:meeting_place_matrix_livekit/meeting_place_matrix_livekit.dart'
    show AudioVideoCallView;

import '../../infrastructure/extensions/build_context_extensions.dart';
import 'video_call_pip_overlay.dart' show VideoCallPiPOverlay;

/// Last snapped position of the PiP window — persisted across widget
/// rebuilds so the position is restored when switching between the in-call
/// screen and [VideoCallPiPOverlay].
Offset? _lastPiPPosition;

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
    this.showControlsBar = false,
    this.onTap,
    this.additionalSize = 0.0,
    this.overlayChildren = const [],
  });

  final String contactId;
  final AudioVideoCallSession? session;
  final AudioVideoCallParticipant participant;
  final bool isCameraEnabled;

  /// The space in which the window can be dragged.
  /// In the call screen this is the SafeArea LayoutBuilder constraints.
  /// In the floating overlay this is MediaQuery.sizeOf(context).
  final Size availableSize;

  /// Whether the controls bar is visible. When true the drag bottom boundary
  /// is raised to prevent the window overlapping the controls.
  final bool showControlsBar;

  /// Tap callback. Null absorbs the tap without side-effects.
  final VoidCallback? onTap;

  /// Extra pixels added equally to width and height — used for the
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
    final baseHeight = cameraOn ? _cameraHeight : _offHeight;
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
    final defaultY =
        availableHeight - bottomInset - _controlsBarHeight - baseHeight;
    final rawPos = position.value ?? Offset(maxX, defaultY);

    final pos = Offset(
      rawPos.dx.clamp(minX, maxX),
      rawPos.dy.clamp(minY, maxY),
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
                  child: cameraOn
                      ? _SelfVideoView(
                          session: session,
                          participantId: participant.participantId,
                        )
                      : const Center(child: _SelfAvatarPlaceholder()),
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

class _SelfVideoView extends ConsumerWidget {
  const _SelfVideoView({required this.session, required this.participantId});

  final AudioVideoCallSession? session;
  final String participantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = session;
    if (activeSession == null) return const SizedBox.shrink();

    return AudioVideoCallView(
      session: activeSession,
      participantId: participantId,
      mirror: true,
    );
  }
}

/// Gradient person icon shown when the camera has no active video track.
class _SelfAvatarPlaceholder extends StatelessWidget {
  const _SelfAvatarPlaceholder();

  static const double _diameter = 40;

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
