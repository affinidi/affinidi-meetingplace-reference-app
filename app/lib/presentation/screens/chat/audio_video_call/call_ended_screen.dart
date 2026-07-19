import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/duration_extensions.dart';
import '../../../widgets/call_ended/call_ended_controller.dart';
import '../../../widgets/profile_circle_avatar.dart';

/// Full-screen "Call ended" shown to both parties after a connected call ends.
///
/// Rendered as a global overlay via `CallEndedOverlay` so it covers any screen
/// the user is on, including minimized calls. Dismissed via the X button.
class CallEndedScreen extends ConsumerWidget {
  const CallEndedScreen({
    super.key,
    required this.contactId,
    required this.peerName,
    required this.durationSeconds,
    required this.isAudioOnly,
    this.calleeAvatarImage,
    this.errorMessage,
  });

  final String contactId;
  final String peerName;
  final int durationSeconds;
  final bool isAudioOnly;
  final ImageProvider<Object>? calleeAvatarImage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callEndedController = ref.read(callEndedControllerProvider.notifier);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final hasErrorMessage = errorMessage != null && errorMessage!.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  _CallEndedAvatar(image: calleeAvatarImage),
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
                    hasErrorMessage
                        ? context.l10n.videoCallCallFailed
                        : context.l10n.videoCallCallEnded,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!hasErrorMessage) ...[
                    const SizedBox(height: 6),
                    Text(
                      Duration(seconds: durationSeconds).label,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Spacer(flex: 3),
                  if (hasErrorMessage)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.onError,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onError,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                iconSize: 35,
                icon: Icon(Icons.close, color: colorScheme.onSurface),
                onPressed: callEndedController.dismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallEndedAvatar extends StatelessWidget {
  const _CallEndedAvatar({required this.image});

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
