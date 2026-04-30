import 'package:flutter/material.dart';

import '../../../domain/models/chat/zkp_paused_notice.dart';
import '../../widgets/banners/zkp_notice_banner.dart';

class ZkpPausedNoticeWidget extends StatelessWidget {
  const ZkpPausedNoticeWidget({super.key, required ZkpPausedNotice chatItem})
      : _chatItem = chatItem;

  final ZkpPausedNotice _chatItem;

  @override
  Widget build(BuildContext context) {
    return ZkpNoticeBanner(
      type: ZkpNoticeType.paused,
      dateCreated: _chatItem.dateCreated.toLocal(),
    );
  }
}
