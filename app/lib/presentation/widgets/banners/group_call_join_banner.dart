import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../screens/chat/audio_video_call/audio_video_call_screen.dart';
import '../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import '../../screens/chat/chat_screen_controller.dart';
import 'active_call/active_call_controller.dart';

class GroupCallJoinBanner extends ConsumerWidget {
  const GroupCallJoinBanner({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActiveHere = ref.watch(
      activeCallControllerProvider.select(
        (s) =>
            s != null &&
            s.contactId == contactId &&
            isConnectedCallStatus(s.status),
      ),
    );
    if (!isActiveHere) return const SizedBox.shrink();

    final isCallSupported = ref.watch(
      chatScreenControllerProvider(contactId).select((s) => s.isCallSupported),
    );

    return Container(
      width: double.infinity,
      color: context.customColors.darkGrey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.videocam, color: context.colorScheme.onSurface, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.videoCallGroupCallActive,
              style: context.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: isCallSupported
                ? () {
                    unawaited(
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              AudioVideoCallScreen(contactId: contactId),
                        ),
                      ),
                    );
                  }
                : null,
            style: TextButton.styleFrom(
              foregroundColor: context.customColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.l10n.videoCallGroupCallJoin,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.customColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
