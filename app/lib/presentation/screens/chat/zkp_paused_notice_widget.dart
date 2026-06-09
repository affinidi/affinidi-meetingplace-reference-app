import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../widgets/banners/zkp_notice_banner.dart';

class ZkpPausedNoticeWidget extends StatelessWidget {
  const ZkpPausedNoticeWidget({super.key, required this.chatItem});

  final chat.ConciergeMessage chatItem;

  @override
  Widget build(BuildContext context) {
    return ZkpNoticeBanner(
      type: ZkpNoticeType.paused,
      dateCreated: chatItem.dateCreated.toLocal(),
    );
  }
}
