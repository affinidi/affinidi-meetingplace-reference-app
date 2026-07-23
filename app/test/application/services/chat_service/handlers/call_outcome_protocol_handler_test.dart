import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/handlers/call_outcome_protocol_handler.dart';

import '../../../../fakes/fake_outcome_call_chat_item_manager.dart';
import '../../../../mocks/mock_app_logger.dart';

void main() {
  const channelDid = 'did:key:channel';
  final startedAt = DateTime.utc(2026, 1, 1, 12);
  final endedAt = DateTime.utc(2026, 1, 1, 12, 5);

  CallOutcomeProtocolHandler buildHandler(
    FakeOutcomeCallChatItemManager manager,
  ) => CallOutcomeProtocolHandler(
    callChatItemManager: manager,
    logger: FakeAppLogger(),
  );

  StreamData outcomeData({String callId = 'room@1', DateTime? started}) =>
      StreamData(
        event: CallOutcomeChatEvent(
          callId: callId,
          outcome: 'ended',
          endedAt: endedAt,
          startedAt: started,
        ),
      );

  group('canHandle', () {
    test('accepts CallOutcomeChatEvent', () {
      final handler = buildHandler(FakeOutcomeCallChatItemManager());
      expect(
        handler.canHandle(
          CallOutcomeChatEvent(callId: 'c', outcome: 'ended', endedAt: endedAt),
        ),
        isTrue,
      );
    });

    test('rejects other events', () {
      final handler = buildHandler(FakeOutcomeCallChatItemManager());
      expect(
        handler.canHandle(const ChatEffectEvent(effectName: 'confetti')),
        isFalse,
      );
    });
  });

  group('handle', () {
    test('reconciles the resolved item to ended with full duration', () async {
      final manager = FakeOutcomeCallChatItemManager(resolvedId: 'msg-1');
      final handler = buildHandler(manager);

      await handler.handle(
        outcomeData(callId: 'room@1', started: startedAt),
        channelDid,
      );

      expect(manager.lastResolveCallId, 'room@1');
      expect(manager.updates, hasLength(1));
      expect(manager.updates.single.messageId, 'msg-1');
      expect(manager.updates.single.status, CallStatus.ended);
      expect(manager.updates.single.duration, endedAt.difference(startedAt));
    });

    test('leaves duration null when startedAt is absent', () async {
      final manager = FakeOutcomeCallChatItemManager(resolvedId: 'msg-3');
      final handler = buildHandler(manager);

      await handler.handle(outcomeData(), channelDid);

      expect(manager.updates.single.duration, isNull);
    });

    test('does nothing when no call item matches', () async {
      final manager = FakeOutcomeCallChatItemManager();
      final handler = buildHandler(manager);

      await handler.handle(outcomeData(started: startedAt), channelDid);

      expect(manager.updates, isEmpty);
    });

    test('skips outcomes with an empty callId', () async {
      final manager = FakeOutcomeCallChatItemManager(resolvedId: 'msg-4');
      final handler = buildHandler(manager);

      await handler.handle(
        outcomeData(callId: '', started: startedAt),
        channelDid,
      );

      expect(manager.lastResolveCallId, isNull);
      expect(manager.updates, isEmpty);
    });
  });
}
