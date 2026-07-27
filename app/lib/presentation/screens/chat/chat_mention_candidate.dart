import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/extensions/contact_card_extensions.dart';

class ChatMentionCandidate {
  const ChatMentionCandidate({
    required this.target,
    required this.label,
    required this.searchText,
    this.subtitle,
  });

  factory ChatMentionCandidate.fromGroupMember(sdk.GroupMember member) {
    final firstName = member.contactCard.firstName.trim();
    final fullName = member.contactCard.fullName.trim();
    final baseLabel = firstName.isNotEmpty
        ? firstName
        : fullName.isNotEmpty
        ? fullName
        : member.did;
    return ChatMentionCandidate(
      target: member.did,
      label: '@$baseLabel',
      subtitle: fullName.isNotEmpty && fullName != baseLabel ? fullName : null,
      searchText: [
        baseLabel,
        fullName,
        member.did,
      ].where((value) => value.trim().isNotEmpty).join(' ').toLowerCase(),
    );
  }

  final String target;
  final String label;
  final String searchText;
  final String? subtitle;
}
