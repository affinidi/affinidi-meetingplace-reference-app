import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../mocks/mock_app_logger.dart';

void main() {
  group('CallChatItemManager incoming call resolution', () {
    const channelDid = 'did:peer:other-party';

    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    Message callMessage({
      required String messageId,
      required bool isFromMe,
      required CallStatus status,
      DateTime? dateCreated,
      String callId = '',
    }) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: dateCreated ?? DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: isFromMe,
      senderDid: isFromMe ? 'me' : channelDid,
      attachments: [
        CallMetadata.buildAttachment(
          id: const Uuid().v4(),
          mediaType: CallMediaType.video,
          status: status,
          callId: callId,
        ),
      ],
    );

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    test('it waits for a late incoming item to resolve the messageId', () {
      fakeAsync((async) {
        fakeChatSdk.sessionMessages = [];

        String? resolved;
        unawaited(
          manager.resolveIncomingCallChatItemId().then((value) {
            resolved = value;
          }),
        );

        async.flushMicrotasks();
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'late-incoming',
            isFromMe: false,
            status: CallStatus.calling,
          ),
        ];

        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();

        expect(resolved, 'late-incoming');
      });
    });

    test('it prefers the item matching the requested callId', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'other-call',
          isFromMe: false,
          status: CallStatus.calling,
          callId: 'call-a',
          dateCreated: DateTime(2026, 6, 29, 10),
        ),
        callMessage(
          messageId: 'target-call',
          isFromMe: false,
          status: CallStatus.ringing,
          callId: 'call-b',
          dateCreated: DateTime(2026, 6, 29, 9),
        ),
      ];

      final resolved = await manager.resolveIncomingCallChatItemId(
        callId: 'call-b',
      );

      expect(resolved, 'target-call');
    });

    test('it falls back to the latest by direction when the callId '
        'has no match', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'latest-incoming',
          isFromMe: false,
          status: CallStatus.calling,
          callId: 'call-a',
        ),
      ];

      final resolved = await manager.resolveIncomingCallChatItemId(
        callId: 'call-unknown',
      );

      expect(resolved, 'latest-incoming');
    });

    test(
      'it waits for a late incoming item before updating to missed call',
      () {
        fakeAsync((async) {
          fakeChatSdk.sessionMessages = [];

          unawaited(manager.markCallAsMissed());

          async.flushMicrotasks();
          fakeChatSdk.sessionMessages = [
            callMessage(
              messageId: 'late-incoming',
              isFromMe: false,
              status: CallStatus.calling,
            ),
          ];

          async.elapse(const Duration(milliseconds: 50));
          async.flushMicrotasks();

          expect(fakeChatSdk.updateMessageCalls, hasLength(1));
          expect(
            fakeChatSdk.updateMessageCalls.single.messageId,
            'late-incoming',
          );
        });
      },
    );

    test('resolveIncomingCallItemBefore returns a message created '
        'exactly at the cutoff', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'at-cutoff-incoming',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: cutoff,
        ),
      ];

      final item = await manager.resolveIncomingCallItemBefore(cutoff);

      expect(item?.messageId, 'at-cutoff-incoming');
    });

    test('resolveIncomingCallItemBefore returns an already-settled item so an '
        'orphaned marker can be cleared', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'settled-incoming',
          isFromMe: false,
          status: CallStatus.missed,
          dateCreated: cutoff,
        ),
      ];

      final item = await manager.resolveIncomingCallItemBefore(cutoff);

      expect(item?.messageId, 'settled-incoming');
    });

    test('resolveIncomingCallItemBefore ignores items created after '
        'the cutoff so a newer ringing call is not marked missed', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'newer-ringing',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 12),
        ),
      ];

      final item = await manager.resolveIncomingCallItemBefore(cutoff);

      expect(item, isNull);
    });

    test(
      'resolveIncomingCallItemBefore matches by callId so an older settled '
      'call is never mistaken for the marker target still in flight',
      () async {
        final cutoff = DateTime(2026, 6, 29, 11);
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'older-settled',
            isFromMe: false,
            status: CallStatus.missed,
            dateCreated: DateTime(2026, 6, 29, 9),
            callId: 'old-call',
          ),
        ];

        final item = await manager.resolveIncomingCallItemBefore(
          cutoff,
          callId: 'target-call',
        );

        expect(item, isNull);
      },
    );

    test('resolveIncomingCallItemBefore returns the item whose callId matches '
        'the marker', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'older-settled',
          isFromMe: false,
          status: CallStatus.missed,
          dateCreated: DateTime(2026, 6, 29, 9),
          callId: 'old-call',
        ),
        callMessage(
          messageId: 'target-ringing',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 10),
          callId: 'target-call',
        ),
      ];

      final item = await manager.resolveIncomingCallItemBefore(
        cutoff,
        callId: 'target-call',
      );

      expect(item?.messageId, 'target-ringing');
    });

    test('resolveStaleIncomingCallItemsBefore returns every stale incoming '
        'item created at or before the cutoff', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'orphan-calling',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: DateTime(2026, 6, 29, 9),
          callId: 'call-a',
        ),
        callMessage(
          messageId: 'orphan-ringing',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 10),
          callId: 'call-b',
        ),
        callMessage(
          messageId: 'at-cutoff',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: cutoff,
          callId: 'call-c',
        ),
      ];

      final items = await manager.resolveStaleIncomingCallItemsBefore(cutoff);

      expect(
        items.map((m) => m.messageId),
        unorderedEquals(['orphan-calling', 'orphan-ringing', 'at-cutoff']),
      );
    });

    test('resolveStaleIncomingCallItemsBefore excludes items created after '
        'the cutoff', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'newer-ringing',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 12),
          callId: 'call-a',
        ),
      ];

      final items = await manager.resolveStaleIncomingCallItemsBefore(cutoff);

      expect(items, isEmpty);
    });

    test('resolveStaleIncomingCallItemsBefore excludes non-stale items '
        '(terminal status or from-me)', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'settled-incoming',
          isFromMe: false,
          status: CallStatus.missed,
          dateCreated: DateTime(2026, 6, 29, 9),
          callId: 'call-a',
        ),
        callMessage(
          messageId: 'own-outgoing',
          isFromMe: true,
          status: CallStatus.calling,
          dateCreated: DateTime(2026, 6, 29, 9),
          callId: 'call-b',
        ),
      ];

      final items = await manager.resolveStaleIncomingCallItemsBefore(cutoff);

      expect(items, isEmpty);
    });

    test('resolveStaleIncomingCallItemsBefore with a null notAfter returns '
        'every stale incoming item with no upper time bound', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'far-future-stale',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2099, 1, 1),
          callId: 'call-a',
        ),
        callMessage(
          messageId: 'settled-incoming',
          isFromMe: false,
          status: CallStatus.missed,
          dateCreated: DateTime(2026, 6, 29, 9),
          callId: 'call-b',
        ),
        callMessage(
          messageId: 'excluded-live',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 10),
          callId: 'call-c',
        ),
      ];

      final items = await manager.resolveStaleIncomingCallItemsBefore(
        null,
        excludeCallId: 'call-c',
      );

      expect(items.map((m) => m.messageId), ['far-future-stale']);
    });

    test('resolveStaleIncomingCallItemsBefore excludes the item whose callId '
        'matches excludeCallId', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'stale-orphan',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: DateTime(2026, 6, 29, 9),
          callId: 'call-a',
        ),
        callMessage(
          messageId: 'stale-live',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 10),
          callId: 'call-b',
        ),
      ];

      final items = await manager.resolveStaleIncomingCallItemsBefore(
        cutoff,
        excludeCallId: 'call-b',
      );

      expect(items.map((m) => m.messageId), ['stale-orphan']);
    });
  });

  group('CallChatItemManager outcome reconciliation', () {
    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    Message callMessage({
      required String messageId,
      required bool isFromMe,
      required CallStatus status,
      String callId = '',
      int? durationMs,
      CallParticipation? participation,
      DateTime? dateCreated,
    }) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: dateCreated ?? DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: isFromMe,
      senderDid: isFromMe ? 'me' : 'peer',
      attachments: [
        CallMetadata.buildAttachment(
          id: const Uuid().v4(),
          mediaType: CallMediaType.video,
          status: status,
          callId: callId,
          durationMs: durationMs,
          participation: participation,
        ),
      ],
    );

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    test(
      'resolveCallItemIdForOutcome finds an ended outgoing item by callId',
      () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'ended-own-item',
            isFromMe: true,
            status: CallStatus.ended,
            callId: 'target-call',
          ),
        ];

        final resolved = await manager.resolveCallItemIdForOutcome(
          'target-call',
        );

        expect(resolved, 'ended-own-item');
      },
    );

    test(
      'resolveCallItemIdForOutcome prefers own item over peer item',
      () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'peer-item',
            isFromMe: false,
            status: CallStatus.ended,
            callId: 'target-call',
          ),
          callMessage(
            messageId: 'own-item',
            isFromMe: true,
            status: CallStatus.ended,
            callId: 'target-call',
          ),
        ];

        final resolved = await manager.resolveCallItemIdForOutcome(
          'target-call',
        );

        expect(resolved, 'own-item');
      },
    );

    test(
      'resolveCallItemIdForOutcome never falls back to a non-matching callId',
      () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'wrong-call',
            isFromMe: true,
            status: CallStatus.ended,
            callId: 'other-call',
          ),
        ];

        final resolved = await manager.resolveCallItemIdForOutcome(
          'target-call',
        );

        expect(resolved, isNull);
      },
    );

    test('reconcileCallOutcome keeps selfLeftBeforeEnd and writes the longer '
        'duration', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'msg-1',
          isFromMe: true,
          status: CallStatus.ended,
          callId: 'target-call',
          durationMs: 1000,
          participation: CallParticipation(
            participantCount: 2,
            didSelfJoin: true,
            selfLeftBeforeEnd: true,
          ),
        ),
      ];

      final updated = await manager.reconcileCallOutcome(
        'msg-1',
        duration: const Duration(minutes: 5),
      );

      final metadata = CallMetadata.maybeOf(updated!.attachments.single);
      expect(metadata?.status, CallStatus.ended);
      expect(metadata?.durationMs, const Duration(minutes: 5).inMilliseconds);
      expect(metadata?.participation?.selfLeftBeforeEnd, isTrue);
    });

    test(
      'reconcileCallOutcome never regresses a longer existing duration',
      () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'msg-1b',
            isFromMe: true,
            status: CallStatus.ended,
            callId: 'target-call',
            durationMs: const Duration(minutes: 2).inMilliseconds,
          ),
        ];

        final updated = await manager.reconcileCallOutcome(
          'msg-1b',
          duration: const Duration(seconds: 29),
        );

        final metadata = CallMetadata.maybeOf(updated!.attachments.single);
        expect(metadata?.durationMs, const Duration(minutes: 2).inMilliseconds);
      },
    );

    test(
      'reconcileCallOutcome keeps existing duration when none is provided',
      () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'msg-2',
            isFromMe: true,
            status: CallStatus.ended,
            callId: 'target-call',
            durationMs: 4242,
          ),
        ];

        final updated = await manager.reconcileCallOutcome('msg-2');
        final metadata = CallMetadata.maybeOf(updated!.attachments.single);

        expect(metadata?.durationMs, 4242);
      },
    );

    test(
      'reconcileCallOutcome never overwrites an unanswered missed call item',
      () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'msg-missed',
            isFromMe: false,
            status: CallStatus.missed,
            callId: 'target-call',
          ),
        ];

        final updated = await manager.reconcileCallOutcome(
          'msg-missed',
          duration: const Duration(minutes: 5),
        );

        final metadata = CallMetadata.maybeOf(updated!.attachments.single);
        expect(metadata?.status, CallStatus.missed);
        expect(metadata?.durationMs, isNull);
      },
    );
  });

  group('CallChatItemManager.sendOutgoingCallMessage', () {
    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    test(
      'onSent callback is called immediately when message sent successfully',
      () async {
        Message? sentMessage;
        final messageId = await manager.sendOutgoingCallMessage(
          mediaType: CallMediaType.audio,
          callId: 'test-call-id',
          onSent: (message) {
            sentMessage = message;
          },
        );

        expect(messageId, isNotNull);
        expect(sentMessage, isNotNull);
        expect(sentMessage!.messageId, messageId);
        expect(sentMessage!.isFromMe, isTrue);
      },
    );

    test('onSent callback receives message with call attachment', () async {
      Message? sentMessage;
      await manager.sendOutgoingCallMessage(
        mediaType: CallMediaType.video,
        callId: 'test-call-id-123',
        onSent: (message) {
          sentMessage = message;
        },
      );

      expect(sentMessage, isNotNull);
      expect(sentMessage!.attachments, isNotEmpty);
      final callMetadata = CallMetadata.maybeOf(sentMessage!.attachments.first);
      expect(callMetadata, isNotNull);
      expect(callMetadata!.mediaType, CallMediaType.video);
    });

    test('onSent callback is not called when SDK is unavailable', () async {
      final managerWithNullSdk = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => null,
        logger: FakeAppLogger(),
      );
      Message? sentMessage;
      final messageId = await managerWithNullSdk.sendOutgoingCallMessage(
        mediaType: CallMediaType.audio,
        onSent: (message) {
          sentMessage = message;
        },
      );

      expect(messageId, isNull);
      expect(sentMessage, isNull);
    });

    test('onSent callback is not called when send fails', () async {
      Message? sentMessage;
      fakeChatSdk.sendTextMessageFailuresRemaining = 1;

      await expectLater(
        manager.sendOutgoingCallMessage(
          mediaType: CallMediaType.audio,
          onSent: (message) {
            sentMessage = message;
          },
        ),
        completion(isNull),
      );

      expect(sentMessage, isNull);
    });

    test('onSent callback is optional', () async {
      final messageId = await manager.sendOutgoingCallMessage(
        mediaType: CallMediaType.audio,
        callId: 'test-call-id',
      );

      expect(messageId, isNotNull);
    });
  });

  group('updateCallChatItem return value for immediate UI refresh', () {
    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    test(
      'returns non-null updated Message when status changes successfully',
      () async {
        final messageId = await manager.sendOutgoingCallMessage(
          mediaType: CallMediaType.audio,
        );
        expect(messageId, isNotNull);

        // Manually add the message to sessionMessages so getMessageById can
        // find it
        final originalMessage = Message(
          chatId: 'fake-chat-id',
          messageId: messageId!,
          value: '',
          dateCreated: DateTime.now(),
          status: ChatItemStatus.sent,
          isFromMe: true,
          senderDid: 'fake-sender-did',
          attachments: [
            CallMetadata.buildAttachment(
              mediaType: CallMediaType.audio,
              status: CallStatus.calling,
              callId: 'test-call-id',
              durationMs: 0,
              id: 'call-attachment-id',
            ),
          ],
        );
        fakeChatSdk.sessionMessages = [originalMessage];

        final updated = await manager.updateCallChatItem(
          messageId,
          status: CallStatus.declined,
        );

        expect(
          updated,
          isNotNull,
          reason:
              'updateCallChatItem should return updated Message for immediate '
              'UI refresh instead of waiting for stream echo',
        );
        expect(updated!.messageId, messageId);
      },
    );

    test('returns null when message not found', () async {
      fakeChatSdk.sessionMessages = [];

      final updated = await manager.updateCallChatItem(
        'nonexistent-message-id',
        status: CallStatus.declined,
      );

      expect(
        updated,
        isNull,
        reason: 'updateCallChatItem should return null when message not found',
      );
    });

    test('returns null when SDK unavailable', () async {
      final managerWithNullSdk = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => null,
        logger: FakeAppLogger(),
      );

      final updated = await managerWithNullSdk.updateCallChatItem(
        'any-id',
        status: CallStatus.declined,
      );

      expect(
        updated,
        isNull,
        reason: 'updateCallChatItem should return null when SDK unavailable',
      );
    });
  });

  group('reconcileCallOutcome preserves early leavers\' "you left" label', () {
    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    Message groupCallItem({required bool selfLeftBeforeEnd}) => Message(
      chatId: 'fake-chat-id',
      messageId: 'group-call-item',
      value: '',
      dateCreated: DateTime.now(),
      status: ChatItemStatus.sent,
      isFromMe: true,
      senderDid: 'me',
      attachments: [
        CallMetadata.buildAttachment(
          mediaType: CallMediaType.video,
          status: CallStatus.ended,
          callId: 'room@1',
          durationMs: 16000,
          id: 'call-attachment-id',
          participation: CallParticipation(
            participantCount: 1,
            didSelfJoin: true,
            selfLeftBeforeEnd: selfLeftBeforeEnd,
          ),
        ),
      ],
    );

    test('keeps selfLeftBeforeEnd and writes the longer duration', () async {
      fakeChatSdk.sessionMessages = [groupCallItem(selfLeftBeforeEnd: true)];

      final updated = await manager.reconcileCallOutcome(
        'group-call-item',
        duration: const Duration(seconds: 25),
      );

      expect(updated, isNotNull);
      final attachment = updated!.attachments.firstWhere(CallMetadata.isCall);
      final call = CallMetadata.maybeOf(attachment)!;
      expect(call.status, CallStatus.ended);
      expect(call.durationMs, const Duration(seconds: 25).inMilliseconds);
      expect(call.participation?.selfLeftBeforeEnd, isTrue);
      expect(call.participation?.participantCount, 1);
    });

    test('keeps the existing duration when none is provided', () async {
      fakeChatSdk.sessionMessages = [groupCallItem(selfLeftBeforeEnd: true)];

      final updated = await manager.reconcileCallOutcome('group-call-item');

      final attachment = updated!.attachments.firstWhere(CallMetadata.isCall);
      expect(CallMetadata.maybeOf(attachment)!.durationMs, 16000);
    });

    test('returns null when the item is missing', () async {
      fakeChatSdk.sessionMessages = [];

      final updated = await manager.reconcileCallOutcome('missing');

      expect(updated, isNull);
    });
  });

  group('resolveCallItemIdForOutcome matches settled items by callId', () {
    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    Message callItem({
      required String messageId,
      required bool isFromMe,
      required CallStatus status,
      required String callId,
    }) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: DateTime.now(),
      status: ChatItemStatus.sent,
      isFromMe: isFromMe,
      senderDid: isFromMe ? 'me' : 'peer',
      attachments: [
        CallMetadata.buildAttachment(
          mediaType: CallMediaType.video,
          status: status,
          callId: callId,
          id: const Uuid().v4(),
        ),
      ],
    );

    test('finds this device own already-ended outgoing item', () async {
      fakeChatSdk.sessionMessages = [
        callItem(
          messageId: 'own-outgoing',
          isFromMe: true,
          status: CallStatus.ended,
          callId: 'room@1',
        ),
      ];

      final resolved = await manager.resolveCallItemIdForOutcome('room@1');

      expect(resolved, 'own-outgoing');
    });

    test('prefers the outgoing item over an incoming peer item', () async {
      fakeChatSdk.sessionMessages = [
        callItem(
          messageId: 'peer-incoming',
          isFromMe: false,
          status: CallStatus.ended,
          callId: 'room@1',
        ),
        callItem(
          messageId: 'own-outgoing',
          isFromMe: true,
          status: CallStatus.ended,
          callId: 'room@1',
        ),
      ];

      final resolved = await manager.resolveCallItemIdForOutcome('room@1');

      expect(resolved, 'own-outgoing');
    });

    test('never falls back to a non-matching callId', () async {
      fakeChatSdk.sessionMessages = [
        callItem(
          messageId: 'other-call',
          isFromMe: false,
          status: CallStatus.ringing,
          callId: 'room@other',
        ),
      ];

      final resolved = await manager.resolveCallItemIdForOutcome('room@1');

      expect(resolved, isNull);
    });

    test('returns null for an empty callId', () async {
      final resolved = await manager.resolveCallItemIdForOutcome('');

      expect(resolved, isNull);
    });
  });
}
