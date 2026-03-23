import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/extensions/contact_card_extensions.dart';

/// Encapsulates all @mention logic for group chats:
/// - resolving mentioned member DIDs from message text
/// - building alias maps for autocomplete and mention detection
/// - checking whether the current user is mentioned in a received message
class ChatMentionsService {
  const ChatMentionsService();

  /// Returns the Matrix user IDs that should be included in `m.mentions` for
  /// [messageText], or `null` if no mentions were found.
  ///
  /// Looks up each mentioned member's Matrix user ID via [getChannelByDid].
  Future<List<String>?> resolveMentionUserIds(
    String messageText,
    sdk.Group group,
    Future<sdk.Channel?> Function(String did) getChannelByDid,
  ) async {
    final memberDids = extractMentionedMemberDids(messageText, group);
    if (memberDids.isEmpty) return null;

    final matrixUserIds = <String>{};
    for (final did in memberDids) {
      final channel = await getChannelByDid(did);
      final matrixUserId = channel?.otherPartyMatrixUserId;
      if (matrixUserId != null && matrixUserId.isNotEmpty) {
        matrixUserIds.add(matrixUserId);
      }
    }

    return matrixUserIds.isEmpty ? null : matrixUserIds.toList();
  }

  /// Returns true if [ownMatrixUserId] is listed in message.mentionedUserIds.
  bool isMentionedInMessage(chat.Message message, String? ownMatrixUserId) {
    if (message.mentionedUserIds.isEmpty || ownMatrixUserId == null) {
      return false;
    }
    return message.mentionedUserIds.contains(ownMatrixUserId);
  }

  /// Returns display names of active group members whose aliases start with
  /// [query]. Pass an empty [query] to get all members.
  List<String> getMentionSuggestions(String query, sdk.Group group) {
    final aliasesByDid = _buildAliases(group.members);
    final normalizedQuery = query.toLowerCase();
    final matches = <String>[];

    for (final aliases in aliasesByDid.values) {
      final displayName = aliases.first;
      final hasMatch = aliases.any(
        (alias) => alias.toLowerCase().startsWith(normalizedQuery),
      );
      if (normalizedQuery.isEmpty || hasMatch) {
        matches.add(displayName);
      }
    }

    matches.sort();
    return matches;
  }

  /// Returns the set of member DIDs that are @-mentioned in [messageText].
  Set<String> extractMentionedMemberDids(String messageText, sdk.Group group) {
    final aliasesByDid = _buildAliases(group.members);
    final mentioned = <String>{};

    for (final entry in aliasesByDid.entries) {
      if (entry.value.any((alias) => _containsMention(messageText, alias))) {
        mentioned.add(entry.key);
      }
    }

    return mentioned;
  }

  /// Builds a map of `did → [aliases]` for active group members.
  ///
  /// Each member gets a full-name alias and, where unambiguous, a first-name
  /// alias. Aliases are sorted longest-first so full names are matched before
  /// first names.
  Map<String, List<String>> _buildAliases(List<sdk.GroupMember> members) {
    final activeMembers = members.where(
      (m) =>
          m.status != sdk.GroupMemberStatus.deleted &&
          m.status != sdk.GroupMemberStatus.rejected,
    );

    final fullNames = activeMembers
        .map((m) => m.contactCard.fullName.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    final firstNameCounts = <String, int>{};
    for (final m in activeMembers) {
      final firstName = m.contactCard.firstName.trim().toLowerCase();
      if (firstName.isEmpty) continue;
      firstNameCounts.update(firstName, (c) => c + 1, ifAbsent: () => 1);
    }

    final aliasesByDid = <String, List<String>>{};

    for (final member in activeMembers) {
      final aliases = <String>[];
      final fullName = member.contactCard.fullName.trim();
      final firstName = member.contactCard.firstName.trim();
      final normalizedFirst = firstName.toLowerCase();

      if (fullName.isNotEmpty) aliases.add(fullName);

      final hasPrefixConflict = fullNames.any(
        (name) =>
            name.toLowerCase() != normalizedFirst &&
            name.toLowerCase().startsWith('$normalizedFirst '),
      );
      if (firstName.isNotEmpty &&
          firstNameCounts[normalizedFirst] == 1 &&
          !hasPrefixConflict) {
        aliases.add(firstName);
      }

      if (aliases.isEmpty) continue;
      aliases.sort((a, b) => b.length.compareTo(a.length));
      aliasesByDid[member.did] = aliases;
    }

    return aliasesByDid;
  }

  bool _containsMention(String text, String alias) {
    return RegExp(
      r'(^|\s)@' + RegExp.escape(alias) + r'(?=\s|[.,!?;:)]|$)',
      caseSensitive: false,
    ).hasMatch(text);
  }
}
