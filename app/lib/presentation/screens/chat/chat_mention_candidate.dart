import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/extensions/contact_card_extensions.dart';

String chatMentionDisplayNameForMember(sdk.GroupMember member) {
  String normalize(String value) {
    final cleaned = value.trim().replaceFirst(RegExp(r'^@+'), '');
    return cleaned.split(RegExp(r'\s+')).first;
  }

  final firstName = normalize(member.contactCard.firstName);
  if (firstName.isNotEmpty) return firstName;
  final fullName = normalize(member.contactCard.fullName);
  if (fullName.isNotEmpty) return fullName;
  return member.did;
}

class ChatMentionCandidate {
  const ChatMentionCandidate({
    required this.target,
    required this.label,
    required this.normalizedLabel,
    required this.searchText,
    this.subtitle,
    this.avatarImage,
  });

  factory ChatMentionCandidate.fromGroupMember(
    sdk.GroupMember member, {
    required BaseCacheManager cacheManager,
  }) {
    final fullName = member.contactCard.fullName.trim();
    final baseLabel = chatMentionDisplayNameForMember(member);
    return ChatMentionCandidate(
      target: member.did,
      label: '@$baseLabel',
      normalizedLabel: baseLabel.toLowerCase(),
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
  final String normalizedLabel;
  final String searchText;
  final String? subtitle;
  final ImageProvider<Object>? avatarImage;
}
