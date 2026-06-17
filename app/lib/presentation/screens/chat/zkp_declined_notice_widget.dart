import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../widgets/banners/zkp_notice_banner.dart';

class ZkpDeclinedNoticeWidget extends StatelessWidget {
  const ZkpDeclinedNoticeWidget({super.key, required this.chatItem});

  final chat.ConciergeMessage chatItem;

  @override
  Widget build(BuildContext context) {
    final contactName = chatItem.data['contactName'] as String? ?? '';
    return ZkpNoticeBanner(
      type: ZkpNoticeType.declined,
      dateCreated: chatItem.dateCreated.toLocal(),
      contactName: contactName,
    );
  }
}
