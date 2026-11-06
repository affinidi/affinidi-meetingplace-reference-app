import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import '../../../domain/models/vtc/vtc_chat_posting.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import 'chat_screen_controller.dart';

const _logKey = 'VtcChatPosting';

/// Who may post in the chat open with a contact, by the contact's id, when it
/// is a community group chat where only the group's managers post: null when
/// everyone may, or the chat cannot be read now. Only a failure's type is
/// logged.
final vtcChatPostingProvider = FutureProvider.autoDispose
    .family<VtcChatPosting?, String>((ref, contactId) async {
      final groupId = ref.watch(
        chatScreenControllerProvider(
          contactId,
        ).select((state) => state.group?.id),
      );
      final channelDid = ref
          .read(contactsServiceProvider)
          .getContactById(contactId)
          ?.channelDid;
      if (groupId == null || channelDid == null) return null;
      try {
        final sdk = await ref.read(meetingPlaceSdkProvider.future);
        final channel = await sdk.findChannelByOtherPartyPermanentDid(
          channelDid,
        );
        if (channel == null) return null;
        return await ref
            .read(vtcGroupChatServiceProvider)
            .postingIn(channel, chatGroupId: groupId);
      } on Exception catch (error) {
        ref
            .read(appLoggerProvider)
            .warning(
              'Failed reading who may post: ${error.runtimeType}',
              name: _logKey,
            );
        return null;
      }
    }, name: 'vtcChatPostingProvider');
