import 'package:flutter/material.dart';

import '../../../domain/models/chat/zkp_proof_received_notice.dart';
import '../../widgets/banners/zkp_notice_banner.dart';

class ZkpProofReceivedNoticeWidget extends StatelessWidget {
  const ZkpProofReceivedNoticeWidget({
    super.key,
    required ZkpProofReceivedNotice chatItem,
  }) : _chatItem = chatItem;

  final ZkpProofReceivedNotice _chatItem;

  @override
  Widget build(BuildContext context) {
    return ZkpNoticeBanner(
      type: ZkpNoticeType.received,
      dateCreated: _chatItem.dateCreated.toLocal(),
      contactName: _chatItem.contactName,
    );
  }
}
