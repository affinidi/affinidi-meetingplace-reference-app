import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../domain/models/chat/encryption_notice.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/contacts/contact_type.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/concierge_message_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/contact_extensions.dart';
import '../../../infrastructure/extensions/contact_image_extensions.dart';
import '../../../infrastructure/extensions/string_emoji_extensions.dart';
import '../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/available_attachment_plugins_provider.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/permission_service/permission_service.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../effects/balloon/ballon_effect.dart';
import '../../effects/confetti/confetti_effect.dart';
import '../../effects/screen_effect.dart';
import '../../validators/max_length_validator_type.dart';
import '../../validators/zalgo_text_validator.dart';
import '../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../widgets/bottom_sheet_menu.dart';
import '../../widgets/info_banner.dart';
import '../../widgets/profile_circle_avatar.dart';
import 'chat_activity_progress_indicator.dart';
import 'chat_items/chat_encryption_notice.dart';
import 'chat_items/group_deleted_chat_item.dart';
import 'chat_items/joining_group_chat_item.dart';
import 'chat_items/leaving_group_chat_item.dart';
import 'chat_screen_controller.dart';

part 'awaiting_members_warning.dart';
part 'chat_contact_display_name.dart';
part 'chat_contact_presence_status.dart';
part 'chat_effect.dart';
part 'chat_item.dart';
part 'chat_items/chat_item_from_info.dart';
part 'chat_items/concierge_join_group_request_chat_item.dart';
part 'chat_items/concierge_update_profile_request_chat_item.dart';
part 'chat_items/plain_text_chat_item.dart';
part 'chat_items/reaction_picker_chat_item.dart';
part 'chat_items/unknown_chat_item.dart';
part 'chat_media_options.dart';
part 'chat_message_list.dart';
part 'chat_text_entry.dart';
part 'chat_typing_activity_indicator.dart';
part 'chat_attachment_uploading_indicator.dart';
part 'notifications_unavailable_warning.dart';
part 'reactions.dart';

class ChatScreen extends HookConsumerWidget {
  const ChatScreen({super.key, required String contactId})
    : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    ref.keepAround(provider);

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.initialize();
        if (!context.mounted) return;
        await controller.onScreenOpened();
      });

      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomCenter,
              radius: 1,
              colors: [
                context.colorScheme.primary,
                const Color.fromARGB(159, 5, 19, 94),
              ],
            ),
          ),
        ),
        title: _ChatContactDisplayName(contactId: _contactId),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final matrixRoomId = ref
                  .read(chatScreenControllerProvider(_contactId))
                  .group
                  ?.matrixRoomId;
              if (matrixRoomId == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.video_call_outlined),
                tooltip: 'Start group call',
                onPressed: () async {
                  try {
                    final sdk = await ref.read(meetingPlaceSdkProvider.future);
                    final powerLevel = await sdk.getOwnPowerLevel(
                      roomId: matrixRoomId,
                    );
                    if (powerLevel <= 50) {
                      if (!context.mounted) return;
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            context.l10n.videoCallPermissionDeniedTitle,
                          ),
                          content: Text(
                            context.l10n.videoCallPermissionDeniedMessage(
                              powerLevel,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    VideoCallRoute(
                      contactId: _contactId,
                      matrixRoomId: matrixRoomId,
                    ).go(context);
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to verify permissions. Please try again.',
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    ChatActivityProgressIndicator(contactId: _contactId),
                    _NotificationsUnavailableWarning(_contactId),
                    Expanded(child: _ChatMessageList(_contactId)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: _ChatTypingActivityIndicator(
                        contactId: _contactId,
                      ),
                    ),
                    _AttachmentUploadingIndicator(contactId: _contactId),
                    _ChatTextEntry(contactId: _contactId),
                  ],
                ),
                ChatEffect(contactId: _contactId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
