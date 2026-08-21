import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/call_log/call_log_entry.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/chat_repository_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../chat_service/delegates/call_chat_item_manager.dart';
import '../contacts_service/contacts_service.dart';

part 'call_log_service.g.dart';

const _logKey = 'CallLogService';

/// Aggregates past calls across all contacts' chats for the Call log screen.
///
/// For each contact, resolves its chat via `getChannelByOtherPartyPermanentDid`
/// and `Chat.deriveId`, fetches its call-only messages via
/// `chat.ChatRepository.listMessagesByMediaKind`, filters to messages
/// carrying [CallMetadata] (`CallMetadata.isCall`), maps each to a
/// [CallLogEntry], and returns the combined list sorted most-recent-first.
/// Contacts whose channel or chat cannot be resolved are skipped, as are
/// contacts whose message history fails to load (logged, not rethrown), so
/// one bad chat cannot fail the whole Call log.
@riverpod
Future<List<CallLogEntry>> callLogEntries(Ref ref) async {
  await ref.read(contactsServiceProvider.notifier).ensureInitialized();

  final contacts = ref.read(contactsServiceProvider).contacts;
  final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
  final chatRepository = await ref.read(chatRepositoryProvider.future);
  final logger = ref.read(appLoggerProvider);

  final entries = <CallLogEntry>[];

  for (final contact in contacts) {
    try {
      final channelDid = contact.channelDid;
      if (channelDid == null) continue;

      final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
        channelDid,
      );
      final ownDid = channel?.permanentChannelDid;
      final otherPartyDid = channel?.otherPartyPermanentChannelDid;
      if (channel == null || ownDid == null || otherPartyDid == null) {
        continue;
      }

      final chatId = chat.Chat.deriveId(
        did: ownDid,
        otherPartyDid: otherPartyDid,
      );

      final messages = CallChatItemManager.hideSupersededCallItems(
        await chatRepository.listMessagesByMediaKind(
          chatId,
          mediaKind: CallMetadata.callKind,
        ),
        contact.supersededCallIds.toSet(),
      );
      for (final item in messages) {
        if (item is! chat.Message) continue;
        for (final attachment in item.attachments) {
          final call = CallMetadata.maybeOf(attachment);
          if (call == null) continue;

          final participantDids =
              call.participation?.participantDids ?? const <String>[];
          final participantNames = participantDids.isEmpty
              ? const <String>[]
              : _resolveParticipantNames(participantDids, contacts);

          entries.add(
            CallLogEntry(
              contactId: contact.id,
              displayLabel: _resolveDisplayLabel(contact),
              mediaType: call.mediaType,
              status: call.status,
              timestamp: item.dateCreated,
              durationMs: call.durationMs,
              isFromMe: item.isFromMe,
              isGroupCall: contact.isGroup,
              participantCount: call.participation?.participantCount ?? 1,
              participantNames: participantNames.isEmpty
                  ? null
                  : participantNames,
            ),
          );
        }
      }
    } catch (error, stackTrace) {
      logger.error(
        'callLogEntries: skipping contact ${contact.id}',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return entries;
}

/// Resolves each of [participantDids] to a display name via [contacts],
/// using the same lookup and fallback rules as [_resolveDisplayLabel].
/// A DID with no matching contact is skipped rather than shown as a DID.
List<String> _resolveParticipantNames(
  List<String> participantDids,
  List<Contact> contacts,
) {
  final names = <String>[];
  for (final did in participantDids) {
    final contact =
        contacts.firstWhereOrNull((c) => c.channelDid == did) ??
        contacts.firstWhereOrNull((c) => c.card.did == did);
    if (contact != null) names.add(_resolveDisplayLabel(contact));
  }
  return names;
}

String _resolveDisplayLabel(Contact contact) {
  final displayName = contact.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) return displayName;

  final fullName = contact.card.displayName.trim();
  if (fullName.isNotEmpty) return fullName;

  return contact.id;
}
