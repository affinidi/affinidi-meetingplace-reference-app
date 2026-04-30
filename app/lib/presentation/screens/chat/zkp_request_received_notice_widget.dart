import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/chat/zkp_request_received_notice.dart';
import '../../widgets/banners/zkp_notice_banner.dart';
import 'chat_screen_controller.dart';
import 'liveness_check_screen.dart';
import 'proof_flow_controller.dart';

class ZkpRequestReceivedNoticeWidget extends ConsumerWidget {
  const ZkpRequestReceivedNoticeWidget({
    super.key,
    required ZkpRequestReceivedNotice chatItem,
    required String contactId,
  })  : _chatItem = chatItem,
        _contactId = contactId;

  final ZkpRequestReceivedNotice _chatItem;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZkpNoticeBanner(
      type: ZkpNoticeType.request,
      dateCreated: _chatItem.dateCreated.toLocal(),
      contactName: _chatItem.contactName,
      onGenerateProof: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => LivenessCheckScreen(
              contactId: _contactId,
            ),
          ),
        );
      },
      onDoLater: () {
        ref
            .read(chatScreenControllerProvider(_contactId).notifier)
            .insertZkpPausedNotice();
        ref
            .read(proofFlowControllerProvider(_contactId).notifier)
            .dismissRequest();
      },
    );
  }
}
