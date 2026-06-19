import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show LivenessZkpConciergeTypes;
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../zkp_declined_notice_widget.dart';
import '../zkp_paused_notice_widget.dart';
import '../zkp_proof_received_notice_widget.dart';
import '../zkp_proof_shared_notice_widget.dart';
import '../zkp_request_initiated_notice_widget.dart';
import '../zkp_request_received_notice_widget.dart';

class ChatZkpConciergeItem extends StatelessWidget {
  const ChatZkpConciergeItem({
    super.key,
    required this.chatItem,
    required this.contactId,
  });

  final chat.ConciergeMessage chatItem;
  final String contactId;

  @override
  Widget build(BuildContext context) {
    switch (chatItem.conciergeType.value) {
      case LivenessZkpConciergeTypes.humanZkpPaused:
        return ZkpPausedNoticeWidget(chatItem: chatItem);
      case LivenessZkpConciergeTypes.humanZkpDeclined:
        return ZkpDeclinedNoticeWidget(chatItem: chatItem);
      case LivenessZkpConciergeTypes.humanZkpProofShared:
        return ZkpProofSharedNoticeWidget(chatItem: chatItem);
      case LivenessZkpConciergeTypes.humanZkpProofReceived:
        return ZkpProofReceivedNoticeWidget(chatItem: chatItem);
      case LivenessZkpConciergeTypes.humanZkpRequest:
        return ZkpRequestReceivedNoticeWidget(
          chatItem: chatItem,
          contactId: contactId,
        );
      case LivenessZkpConciergeTypes.humanZkpRequestInitiated:
        return ZkpRequestInitiatedNoticeWidget(chatItem: chatItem);
      default:
        return const SizedBox.shrink();
    }
  }

  static bool matches(chat.ChatItem item) {
    return item is chat.ConciergeMessage &&
        LivenessZkpConciergeTypes.isHumanZkpType(item.conciergeType.value);
  }
}
