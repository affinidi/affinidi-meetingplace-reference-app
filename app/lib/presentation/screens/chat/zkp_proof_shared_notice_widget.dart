import 'package:flutter/material.dart';

import '../../../domain/models/chat/zkp_proof_shared_notice.dart';
import '../../widgets/banners/zkp_notice_banner.dart';

class ZkpProofSharedNoticeWidget extends StatelessWidget {
  const ZkpProofSharedNoticeWidget({
    super.key,
    required ZkpProofSharedNotice chatItem,
  }) : _chatItem = chatItem;

  final ZkpProofSharedNotice _chatItem;

  @override
  Widget build(BuildContext context) {
    return ZkpNoticeBanner(
      type: ZkpNoticeType.shared,
      dateCreated: _chatItem.dateCreated.toLocal(),
    );
  }
}
