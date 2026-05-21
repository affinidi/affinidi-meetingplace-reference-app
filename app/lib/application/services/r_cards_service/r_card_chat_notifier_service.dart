import 'dart:async';
import 'dart:convert';

import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/chat_repository_provider.dart';
import '../../../infrastructure/providers/relationship_sdk_provider.dart';
import '../chat_service/chat_session_service.dart' show ChatSessionService;
import '../contacts_service/contacts_service.dart';

part 'r_card_chat_notifier_service.g.dart';

/// Global service that creates chat messages for R-Cards delivered via the
/// DIDComm channel-inauguration (OOB) path.
///
/// Listens on [MeetingPlaceRelationshipSDK.receivedRCardsOnChannel], which
/// surfaces the originating channel alongside each parsed R-Card. This
/// channel context is used to:
///   • skip group channels (R-Cards are individual-only),
///   • build the stable chat message ID, and
///   • set the sender DID correctly.
///
/// VDIP-path R-Cards (explicit sends) are handled by [ChatSessionService] and
/// are intentionally NOT processed here.
@Riverpod(keepAlive: true)
class RCardChatNotifierService extends _$RCardChatNotifierService {
  static const _logKey = 'RCARDCHAT';

  late final AppLogger _logger = ref.read(appLoggerProvider);

  StreamSubscription<ChannelRCardEvent>? _sub;

  @override
  void build() {
    unawaited(_init());
    ref.onDispose(() => _sub?.cancel());
  }

  Future<void> _init() async {
    try {
      final sdk = await ref.read(relationshipSdkProvider.future);
      final chatRepo = await ref.read(chatRepositoryProvider.future);

      _sub = sdk.receivedRCardsOnChannel.listen(
        (ChannelRCardEvent event) =>
            unawaited(_onRCardReceived(event, chatRepo)),
        onError: (Object error, StackTrace st) {
          _logger.error(
            'Error in R-Card chat notifier stream',
            error: error,
            stackTrace: st,
            name: _logKey,
          );
        },
      );
    } catch (error, st) {
      _logger.error(
        'Failed to start R-Card chat notifier',
        error: error,
        stackTrace: st,
        name: _logKey,
      );
    }
  }

  Future<void> _onRCardReceived(
    ChannelRCardEvent event,
    chat.ChatRepository chatRepo,
  ) async {
    final channel = event.channel;
    final rCard = event.rCard;

    // R-Cards are individual-only; skip group channels.
    final localChannelDid = channel.permanentChannelDid;
    final theirChannelDid = channel.otherPartyPermanentChannelDid;
    if (localChannelDid == null ||
        localChannelDid.isEmpty ||
        theirChannelDid == null ||
        theirChannelDid.isEmpty) {
      return;
    }

    final contact = ref
        .read(contactsServiceProvider)
        .getContactByChannelDid(theirChannelDid);
    if (contact?.isGroup ?? false) return;

    final chatId = '$localChannelDid-$theirChannelDid';

    // Stable message ID so the message is idempotent across restarts.
    final messageId = const Uuid().v5(
      Namespace.url.value,
      'rcard_auto_exchange|$chatId|${rCard.subjectDid}',
    );

    final existing = await chatRepo.getMessage(
      chatId: chatId,
      messageId: messageId,
    );
    if (existing != null) return;

    try {
      final vcJson = jsonDecode(rCard.vcBlob) as Map<String, dynamic>;
      final attachments = RCardDIDCommAttachmentBuilder.fromVcJson(
        vcJson,
        isAutoExchange: true,
      );

      final message = chat.Message(
        chatId: chatId,
        messageId: messageId,
        senderDid: theirChannelDid,
        isFromMe: false,
        dateCreated: rCard.receivedAt,
        status: chat.ChatItemStatus.confirmed,
        value: '',
        attachments: attachments,
      );

      await chatRepo.createMessage(message);

      _logger.info(
        'Auto-exchange R-Card chat message created for $chatId',
        name: _logKey,
      );
    } catch (error, st) {
      _logger.error(
        'Failed to create auto-exchange R-Card chat message',
        error: error,
        stackTrace: st,
        name: _logKey,
      );
    }
  }
}
