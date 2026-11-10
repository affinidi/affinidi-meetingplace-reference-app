import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import 'chat_screen_controller.dart';

const _logKey = 'ChatCanPost';

/// Whether the member on this phone may post in the chat open with a
/// contact, by the contact's id: false only in a group chat that lets just
/// its owner and moderators post, as the chat itself says, which also
/// refuses the member's reactions, deletions and calls. True when the chat
/// cannot be read now, as the chat refuses what it must anyway. Only a
/// failure's type is logged.
final chatCanPostProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  contactId,
) async {
  final isGroupChat = ref.watch(
    chatScreenControllerProvider(
      contactId,
    ).select((state) => state.group != null),
  );
  final channelDid = ref
      .read(contactsServiceProvider)
      .getContactById(contactId)
      ?.channelDid;
  if (!isGroupChat || channelDid == null) return true;
  try {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await sdk.findChannelByOtherPartyPermanentDid(channelDid);
    if (channel == null) return true;
    return await sdk.canPostInGroup(channel);
  } on Exception catch (error) {
    ref
        .read(appLoggerProvider)
        .warning(
          'Failed reading whether this member may post: '
          '${error.runtimeType}',
          name: _logKey,
        );
    return true;
  }
}, name: 'chatCanPostProvider');
