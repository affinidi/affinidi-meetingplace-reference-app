import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../widgets/banners/zkp_notice_banner.dart';

class ZkpProofReceivedNoticeWidget extends StatelessWidget {
  const ZkpProofReceivedNoticeWidget({
    super.key,
    required this.chatItem,
  });

  final chat.ConciergeMessage chatItem;

  @override
  Widget build(BuildContext context) {
    final name = chatItem.data['contactName'] as String? ?? '';
    return ZkpNoticeBanner(
      type: ZkpNoticeType.received,
      dateCreated: chatItem.dateCreated.toLocal(),
      contactName: name,
    );
  }
}
