import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../../../application/services/r_cards_service/r_cards_service.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/plugins/r_card_attachments_plugin/r_card_attachment.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import 'concierge_message.dart';

class ChatRCardsExchangedNotice extends ConsumerWidget {
  const ChatRCardsExchangedNotice({super.key, required this.chatItem});

  final chat.ChatItem chatItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableSubjectDids = ref
        .watch(rCardsServiceProvider)
        .map((c) => c.subjectDid)
        .toSet();

    String? rCardSubjectDid;
    if (chatItem is chat.Message) {
      final msg = chatItem as chat.Message;
      rCardSubjectDid = msg.attachments
          .where((a) => a.isRCard)
          .firstOrNull
          ?.rCardSubjectDid;
    }

    final isAvailable =
        rCardSubjectDid != null &&
        rCardSubjectDid.trim().isNotEmpty &&
        availableSubjectDids.contains(rCardSubjectDid);

    final textStyle = context.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConciergeMessage(
            dateCreated: chatItem.dateCreated.toLocal(),
            message: context.l10n.rCardsExchanged,
          ),
          if (isAvailable) ...[
            const SizedBox(height: 2),
            InkWell(
              onTap: () {
                RCardDetailsRoute(
                  subjectDid: rCardSubjectDid!,
                ).push<void>(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  context.l10n.goToRCard,
                  style: textStyle?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
