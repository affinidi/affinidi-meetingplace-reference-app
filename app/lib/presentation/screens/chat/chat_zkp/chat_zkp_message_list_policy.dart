import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show LivenessZkpConciergeIds, LivenessZkpConciergeTypes;
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show LivenessZkpAttachmentParser;

import '../../../../domain/models/chat/encryption_notice.dart';
import '../../../themes/app_custom_colors.dart';

sealed class ChatZkpMessageListPolicy {
  factory ChatZkpMessageListPolicy.fromMessages({
    required bool enabled,
    required List<chat.ChatItem> messages,
  }) {
    if (!enabled) return disabled;
    return _Enabled(messages);
  }
  const ChatZkpMessageListPolicy();

  static const disabled = _Disabled();

  static bool hasVerifiedProof(List<chat.ChatItem> messages) {
    return messages.any(
      (item) =>
          item is chat.ConciergeMessage &&
          item.conciergeType.value ==
              LivenessZkpConciergeTypes.humanZkpProofReceived,
    );
  }

  static String? latestHumanZkpRequestNoticeMessageId(
    List<chat.ChatItem> messages,
  ) {
    chat.ConciergeMessage? latest;
    for (final item in messages) {
      if (item is! chat.ConciergeMessage) continue;
      if (item.conciergeType.value !=
          LivenessZkpConciergeTypes.humanZkpRequest) {
        continue;
      }
      if (latest == null || item.dateCreated.isAfter(latest.dateCreated)) {
        latest = item;
      }
    }
    return latest?.messageId;
  }

  bool shouldHide(chat.ChatItem item);

  int nextVisibleIndex(int index, List<chat.ChatItem> messages) {
    var next = index + 1;
    while (next < messages.length && shouldHide(messages[next])) {
      next++;
    }
    return next;
  }

  EdgeInsets horizontalPadding(chat.ChatItem item);

  EdgeInsets bubbleMargin({
    required chat.ChatItem item,
    required int selectedReactionIndex,
    required int index,
  });

  Color bubbleColor(ColorScheme colorScheme, chat.ChatItem item);
}

final class _Disabled extends ChatZkpMessageListPolicy {
  const _Disabled();

  @override
  bool shouldHide(chat.ChatItem item) => false;

  @override
  EdgeInsets horizontalPadding(chat.ChatItem item) =>
      const EdgeInsets.symmetric(horizontal: 20);

  @override
  EdgeInsets bubbleMargin({
    required chat.ChatItem item,
    required int selectedReactionIndex,
    required int index,
  }) => _standardBubbleMargin(
    item,
    selectedReactionIndex: selectedReactionIndex,
    index: index,
  );

  @override
  Color bubbleColor(ColorScheme colorScheme, chat.ChatItem item) =>
      _standardBubbleColor(colorScheme, item);
}

final class _Enabled extends ChatZkpMessageListPolicy {
  _Enabled(List<chat.ChatItem> messages)
    : _pausedNoticeMessageIds = messages
          .whereType<chat.ConciergeMessage>()
          .where(
            (n) =>
                n.conciergeType.value ==
                LivenessZkpConciergeTypes.humanZkpPaused,
          )
          .map((n) => n.messageId)
          .toSet(),
      _hasSharedProof = messages.any(
        (m) =>
            m is chat.ConciergeMessage &&
            m.conciergeType.value ==
                LivenessZkpConciergeTypes.humanZkpProofShared,
      ),
      _hasVerifiedProof = ChatZkpMessageListPolicy.hasVerifiedProof(messages);

  final Set<String> _pausedNoticeMessageIds;
  final bool _hasSharedProof;
  final bool _hasVerifiedProof;

  bool _isHumanZkpConcierge(chat.ChatItem item) =>
      item is chat.ConciergeMessage &&
      LivenessZkpConciergeTypes.isHumanZkpType(item.conciergeType.value);

  bool _isHumanZkpRequest(chat.ChatItem item) =>
      item is chat.ConciergeMessage &&
      item.conciergeType.value == LivenessZkpConciergeTypes.humanZkpRequest;

  bool _isHumanZkpRequestInitiated(chat.ChatItem item) =>
      item is chat.ConciergeMessage &&
      item.conciergeType.value ==
          LivenessZkpConciergeTypes.humanZkpRequestInitiated;

  @override
  bool shouldHide(chat.ChatItem item) {
    if (item is chat.Message && item.value.isEmpty) {
      final attachments = item.attachments;
      if (attachments.isNotEmpty &&
          attachments.every(
            (att) =>
                LivenessZkpAttachmentParser.matchesRequestFormat(
                  att.toCoreAttachment(),
                ) ||
                LivenessZkpAttachmentParser.matchesProofFormat(
                  att.toCoreAttachment(),
                ) ||
                LivenessZkpAttachmentParser.matchesDeclinedFormat(
                  att.toCoreAttachment(),
                ),
          )) {
        return true;
      }
    }

    if (_isHumanZkpRequest(item)) {
      if (_hasSharedProof) return true;
      final expectedPausedId = LivenessZkpConciergeIds.paused(
        forRequestNoticeMessageId: item.messageId,
      );
      return _pausedNoticeMessageIds.contains(expectedPausedId);
    }

    if (_isHumanZkpRequestInitiated(item) && _hasVerifiedProof) {
      return true;
    }

    return false;
  }

  @override
  EdgeInsets horizontalPadding(chat.ChatItem item) {
    if (_isHumanZkpConcierge(item) && !_isHumanZkpRequest(item)) {
      return EdgeInsets.zero;
    }
    return const EdgeInsets.symmetric(horizontal: 20);
  }

  @override
  EdgeInsets bubbleMargin({
    required chat.ChatItem item,
    required int selectedReactionIndex,
    required int index,
  }) {
    if (_isHumanZkpRequest(item)) {
      return const EdgeInsets.fromLTRB(20, 8, 20, 8);
    }
    if (_isHumanZkpConcierge(item)) {
      return const EdgeInsets.symmetric(vertical: 8);
    }
    return _standardBubbleMargin(
      item,
      selectedReactionIndex: selectedReactionIndex,
      index: index,
    );
  }

  @override
  Color bubbleColor(ColorScheme colorScheme, chat.ChatItem item) {
    if (_isHumanZkpConcierge(item)) return Colors.transparent;
    return _standardBubbleColor(colorScheme, item);
  }
}

EdgeInsets _standardBubbleMargin(
  chat.ChatItem item, {
  required int selectedReactionIndex,
  required int index,
}) {
  if (item is EncryptionNotice ||
      item is chat.ConciergeMessage ||
      item is chat.EventMessage) {
    return const EdgeInsets.fromLTRB(20, 8, 20, 8);
  }
  return EdgeInsets.fromLTRB(
    item.isFromMe ? 60 : 0,
    8,
    item.isFromMe ? 0 : 60,
    selectedReactionIndex == index ||
            (item is chat.Message && item.reactions.isNotEmpty)
        ? 0
        : 8,
  );
}

Color _standardBubbleColor(ColorScheme colorScheme, chat.ChatItem item) {
  if (item.type == chat.ChatItemType.conciergeMessage) {
    return AppCustomColors.conciergeMessageColor;
  }
  if (item.type == chat.ChatItemType.eventMessage) {
    return Colors.transparent;
  }
  if (item.isFromMe) {
    if (item.status == chat.ChatItemStatus.error) return Colors.red;
    return colorScheme.primary;
  }
  if (item is chat.Message &&
      item.attachments.any((a) => a.format == 'cierge/trust-task')) {
    return const Color.fromARGB(248, 30, 60, 80);
  }
  return const Color.fromARGB(248, 107, 65, 162);
}
