import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/extensions/contact_card_extensions.dart';

class ChatMentionCandidate {
  const ChatMentionCandidate({
    required this.target,
    required this.label,
    required this.searchText,
    this.subtitle,
    this.avatarImage,
  });

  factory ChatMentionCandidate.fromGroupMember(
    sdk.GroupMember member, {
    required BaseCacheManager cacheManager,
  }) {
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
      avatarImage: member.contactCard.image(cacheManager: cacheManager),
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
  final ImageProvider<Object>? avatarImage;
}
