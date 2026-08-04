import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/call_log/call_log_entry.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../infrastructure/providers/chat_repository_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../contacts_service/contacts_service.dart';

part 'call_log_service.g.dart';

/// Aggregates past calls across all contacts' chats for the Call log screen.
///
/// For each contact, resolves its chat via `getChannelByOtherPartyPermanentDid`
/// and `Chat.deriveId`, fetches its messages via
/// `chat.ChatRepository.listMessages`, filters to messages carrying
/// [CallMetadata] (`CallMetadata.isCall`), maps each to a [CallLogEntry], and
/// returns the combined list sorted most-recent-first. Contacts whose channel
/// or chat cannot be resolved are skipped.
@riverpod
Future<List<CallLogEntry>> callLogEntries(Ref ref) async {
  await ref.read(contactsServiceProvider.notifier).ensureInitialized();

  final contacts = ref.read(contactsServiceProvider).contacts;
  final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
  final chatRepository = await ref.read(chatRepositoryProvider.future);

  final entries = <CallLogEntry>[];

  for (final contact in contacts) {
    final channelDid = contact.channelDid;
    if (channelDid == null) continue;

    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      channelDid,
    );
    final ownDid = channel?.permanentChannelDid;
    final otherPartyDid = channel?.otherPartyPermanentChannelDid;
    if (channel == null || ownDid == null || otherPartyDid == null) continue;

    final chatId = chat.Chat.deriveId(
      did: ownDid,
      otherPartyDid: otherPartyDid,
    );

    final messages = await chatRepository.listMessages(chatId);
    for (final item in messages) {
      if (item is! chat.Message) continue;
      for (final attachment in item.attachments) {
        final call = CallMetadata.maybeOf(attachment);
        if (call == null) continue;

        final participantDids =
            call.participation?.participantDids ?? const <String>[];

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
            participantNames: participantDids.isEmpty
                ? null
                : _resolveParticipantNames(participantDids, contacts),
          ),
        );
      }
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
    final contact = contacts.firstWhereOrNull((c) => c.channelDid == did);
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
