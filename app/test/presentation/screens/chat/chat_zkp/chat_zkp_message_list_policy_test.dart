import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_zkp/chat_zkp_message_list_policy.dart';

void main() {
  const chatId = 'chat-1';
  const contactName = 'Alice';
  final when = DateTime.utc(2026, 3, 1, 12);

  group('ChatZkpMessageListPolicy.hasVerifiedProof', () {
    test('returns false for an empty message list', () {
      expect(ChatZkpMessageListPolicy.hasVerifiedProof([]), isFalse);
    });

    test('returns true when humanZkpProofReceived concierge is present', () {
      final notice = LivenessZkpConciergeMessages.humanZkpProofReceived(
        chatId: chatId,
        messageId: 'proof-received-1',
        dateCreated: when,
        contactName: contactName,
      );

      expect(
        ChatZkpMessageListPolicy.hasVerifiedProof([
          LivenessZkpConciergeChatMapper.toConciergeMessage(notice),
        ]),
        isTrue,
      );
    });

    test('returns false for other human ZKP concierge types', () {
      final messages = <ChatItem>[
        LivenessZkpConciergeChatMapper.toConciergeMessage(
          LivenessZkpConciergeMessages.humanZkpRequest(
            chatId: chatId,
            messageId: 'request-1',
            dateCreated: when,
            contactName: contactName,
          ),
        ),
        LivenessZkpConciergeChatMapper.toConciergeMessage(
          LivenessZkpConciergeMessages.humanZkpProofShared(
            chatId: chatId,
            messageId: 'shared-1',
            dateCreated: when,
          ),
        ),
        LivenessZkpConciergeChatMapper.toConciergeMessage(
          LivenessZkpConciergeMessages.humanZkpPaused(
            chatId: chatId,
            dateCreated: when,
          ),
        ),
      ];

      expect(ChatZkpMessageListPolicy.hasVerifiedProof(messages), isFalse);
    });

    test(
      'returns false for proof attachment messages without verified concierge',
      () {
        final proofMessage = Message(
          chatId: chatId,
          messageId: 'proof-msg-1',
          senderDid: 'did:peer',
          isFromMe: false,
          dateCreated: when,
          status: ChatItemStatus.confirmed,
          value: '',
          attachments: [
            ChatAttachment(
              id: 'att-proof',
              mediaType: 'application/json',
              format: LivenessZkpProtocol.livenessProofFormat,
              lastModifiedTime: when,
              data: ChatAttachmentData(
                json:
                    '{"type":"liveness_proof","proof":"p","publicSignals":"s"}',
              ),
            ),
          ],
        );

        expect(
          ChatZkpMessageListPolicy.hasVerifiedProof([proofMessage]),
          isFalse,
        );
      },
    );

    test('returns false for plain text messages', () {
      final message = Message(
        chatId: chatId,
        messageId: 'text-1',
        senderDid: 'did:peer',
        isFromMe: false,
        dateCreated: when,
        status: ChatItemStatus.confirmed,
        value: 'hello',
        attachments: const [],
      );

      expect(ChatZkpMessageListPolicy.hasVerifiedProof([message]), isFalse);
    });
  });
}
