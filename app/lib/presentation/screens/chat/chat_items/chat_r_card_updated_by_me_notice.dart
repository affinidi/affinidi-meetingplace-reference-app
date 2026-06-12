import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'concierge_message.dart';

class ChatRCardUpdatedByMeNotice extends StatelessWidget {
  const ChatRCardUpdatedByMeNotice({super.key, required this.dateCreated});

  final DateTime dateCreated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: ConciergeMessage(
        dateCreated: dateCreated.toLocal(),
        message: context.l10n.rCardFooterUpdateShared,
      ),
    );
  }
}
