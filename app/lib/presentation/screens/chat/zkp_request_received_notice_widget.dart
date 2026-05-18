import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../widgets/banners/zkp_notice_banner.dart';
import 'chat_screen_controller.dart';
import 'liveness_check_screen.dart';
import 'proof_flow_controller.dart';

class ZkpRequestReceivedNoticeWidget extends ConsumerWidget {
  const ZkpRequestReceivedNoticeWidget({
    super.key,
    required this.chatItem,
    required String contactId,
  }) : _contactId = contactId;

  final chat.ConciergeMessage chatItem;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactName = chatItem.data['contactName'] as String? ?? '';
    return ZkpNoticeBanner(
      type: ZkpNoticeType.request,
      dateCreated: chatItem.dateCreated.toLocal(),
      contactName: contactName,
      onGenerateProof: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => LivenessCheckScreen(contactId: _contactId),
          ),
        );
      },
      onDoLater: () async {
        await ref
            .read(chatScreenControllerProvider(_contactId).notifier)
            .insertZkpPausedNotice(
              pausedForNoticeMessageId: chatItem.messageId,
            );
        ref
            .read(proofFlowControllerProvider(_contactId).notifier)
            .dismissRequest();
      },
    );
  }
}
