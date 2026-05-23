import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_state.dart';

chat.ConciergeMessage _concierge({
  required chat.ConciergeMessageType type,
  chat.ChatItemStatus status = chat.ChatItemStatus.userInput,
}) => chat.ConciergeMessage(
  chatId: 'chat-id',
  messageId: 'concierge-id',
  senderDid: 'did:key:other',
  isFromMe: false,
  dateCreated: DateTime(2024),
  status: status,
  conciergeType: type,
  data: const {},
);

chat.EventMessage _event(
  String eventType, {
  Map<String, dynamic> data = const {},
}) => chat.EventMessage(
  chatId: 'chat-id',
  messageId: 'event-id',
  senderDid: 'did:key:other',
  isFromMe: false,
  dateCreated: DateTime(2024),
  status: chat.ChatItemStatus.received,
  eventType: chat.EventMessageType.fromJson(eventType),
  data: data,
);

void main() {
  group('ChatScreenState.hasPendingVrcConcierge', () {
    test('returns true when permissionToVerifyRelationship concierge '
        'is userInput', () {
      final state = ChatScreenState(
        messages: [
          _concierge(
            type: chat.ConciergeMessageType.fromJson(
              'permissionToVerifyRelationship',
            ),
          ),
        ],
      );
      expect(state.hasPendingVrcConcierge, isTrue);
    });

    test('returns false when concierge status is confirmed', () {
      final state = ChatScreenState(
        messages: [
          _concierge(
            type: chat.ConciergeMessageType.fromJson(
              'permissionToVerifyRelationship',
            ),
            status: chat.ChatItemStatus.confirmed,
          ),
        ],
      );
      expect(state.hasPendingVrcConcierge, isFalse);
    });

    test('returns false when no messages are present', () {
      expect(ChatScreenState().hasPendingVrcConcierge, isFalse);
    });

    test('returns false for a different concierge type', () {
      final state = ChatScreenState(
        messages: [
          _concierge(type: chat.ConciergeMessageType.permissionToJoinGroup),
        ],
      );
      expect(state.hasPendingVrcConcierge, isFalse);
    });
  });

  group('ChatScreenState.hasVrcExchangeInitiated', () {
    test('returns true when vrcExchangeInitiated event is present', () {
      final state = ChatScreenState(messages: [_event('vrcExchangeInitiated')]);
      expect(state.hasVrcExchangeInitiated, isTrue);
    });

    test('returns false when no vrcExchangeInitiated event', () {
      expect(ChatScreenState().hasVrcExchangeInitiated, isFalse);
    });

    test('returns false for a different event type', () {
      final state = ChatScreenState(messages: [_event('vrcExchangeDoLater')]);
      expect(state.hasVrcExchangeInitiated, isFalse);
    });
  });

  group('ChatScreenState.hasVrcExchangeDoLater', () {
    test('returns true when vrcExchangeDoLater event is present', () {
      final state = ChatScreenState(messages: [_event('vrcExchangeDoLater')]);
      expect(state.hasVrcExchangeDoLater, isTrue);
    });

    test('returns false when no vrcExchangeDoLater event', () {
      expect(ChatScreenState().hasVrcExchangeDoLater, isFalse);
    });
  });

  group('ChatScreenState.hasVrcRequestReceived', () {
    test('returns true when vrcRequestReceived event is present', () {
      final state = ChatScreenState(messages: [_event('vrcRequestReceived')]);
      expect(state.hasVrcRequestReceived, isTrue);
    });

    test('returns false when no vrcRequestReceived event', () {
      expect(ChatScreenState().hasVrcRequestReceived, isFalse);
    });

    test('drives responder role when true', () {
      final state = ChatScreenState(messages: [_event('vrcRequestReceived')]);
      expect(state.hasVrcRequestReceived, isTrue);
    });
  });

  group('ChatScreenState.hasVrcExchangeCompleted', () {
    test('returns true when vrcExchangeCompleted event is present', () {
      final state = ChatScreenState(messages: [_event('vrcExchangeCompleted')]);
      expect(state.hasVrcExchangeCompleted, isTrue);
    });

    test('returns false when no vrcExchangeCompleted event', () {
      expect(ChatScreenState().hasVrcExchangeCompleted, isFalse);
    });
  });

  group('ChatScreenState.vrcRequestIdentityDid and vrcRequestIdentityName', () {
    test('returns identity DID from vrcRequestReceived event data', () {
      final state = ChatScreenState(
        messages: [
          _event('vrcRequestReceived', data: {'identityDid': 'did:key:abc'}),
        ],
      );
      expect(state.vrcRequestIdentityDid, 'did:key:abc');
    });

    test('returns null when vrcRequestReceived event has no identityDid', () {
      final state = ChatScreenState(messages: [_event('vrcRequestReceived')]);
      expect(state.vrcRequestIdentityDid, isNull);
    });

    test('returns identity name from vrcRequestReceived event data', () {
      final state = ChatScreenState(
        messages: [
          _event('vrcRequestReceived', data: {'identityName': 'Alice'}),
        ],
      );
      expect(state.vrcRequestIdentityName, 'Alice');
    });

    test('returns null when no vrcRequestReceived event', () {
      expect(ChatScreenState().vrcRequestIdentityDid, isNull);
      expect(ChatScreenState().vrcRequestIdentityName, isNull);
    });
  });

  group('ChatScreenState.vrcInitiatorIdentityDid and '
      'vrcInitiatorIdentityName', () {
    test('returns identity DID from vrcExchangeInitiated event data', () {
      final state = ChatScreenState(
        messages: [
          _event('vrcExchangeInitiated', data: {'identityDid': 'did:key:xyz'}),
        ],
      );
      expect(state.vrcInitiatorIdentityDid, 'did:key:xyz');
    });

    test('returns identity name from vrcExchangeInitiated event data', () {
      final state = ChatScreenState(
        messages: [
          _event('vrcExchangeInitiated', data: {'identityName': 'Bob'}),
        ],
      );
      expect(state.vrcInitiatorIdentityName, 'Bob');
    });

    test('returns null when no vrcExchangeInitiated event', () {
      expect(ChatScreenState().vrcInitiatorIdentityDid, isNull);
      expect(ChatScreenState().vrcInitiatorIdentityName, isNull);
    });
  });

  group('ChatScreenState.shouldShowVrcBanner', () {
    test('defaults to false', () {
      expect(ChatScreenState().shouldShowVrcBanner, isFalse);
    });

    test('can be set to true', () {
      final state = ChatScreenState(shouldShowVrcBanner: true);
      expect(state.shouldShowVrcBanner, isTrue);
    });

    test('hasPendingVrcConcierge suppresses banner', () {
      final state = ChatScreenState(
        shouldShowVrcBanner: true,
        messages: [
          _concierge(
            type: chat.ConciergeMessageType.fromJson(
              'permissionToVerifyRelationship',
            ),
          ),
        ],
      );
      final suppress = state.hasPendingVrcConcierge;
      expect(suppress ? false : state.shouldShowVrcBanner, isFalse);
    });

    test('hasVrcExchangeInitiated suppresses banner', () {
      final state = ChatScreenState(
        shouldShowVrcBanner: true,
        messages: [_event('vrcExchangeInitiated')],
      );
      final suppress = state.hasVrcExchangeInitiated;
      expect(suppress ? false : state.shouldShowVrcBanner, isFalse);
    });

    test('hasVrcExchangeDoLater suppresses banner', () {
      final state = ChatScreenState(
        shouldShowVrcBanner: true,
        messages: [_event('vrcExchangeDoLater')],
      );
      final suppress = state.hasVrcExchangeDoLater;
      expect(suppress ? false : state.shouldShowVrcBanner, isFalse);
    });
  });

  group('ChatScreenState.shouldEnableVrcAttachment', () {
    test('defaults to false', () {
      expect(ChatScreenState().shouldEnableVrcAttachment, isFalse);
    });

    test('can be set to true', () {
      final state = ChatScreenState(shouldEnableVrcAttachment: true);
      expect(state.shouldEnableVrcAttachment, isTrue);
    });

    test('remains enabled when concierge present but request was received', () {
      final state = ChatScreenState(
        messages: [
          _concierge(
            type: chat.ConciergeMessageType.fromJson(
              'permissionToVerifyRelationship',
            ),
          ),
          _event('vrcRequestReceived'),
        ],
      );
      final shouldEnable =
          !state.hasVrcExchangeInitiated &&
          (!state.hasPendingVrcConcierge ||
              state.hasVrcRequestReceived ||
              state.hasVrcExchangeDoLater);
      expect(shouldEnable, isTrue);
    });

    test('disabled when vrcExchangeInitiated', () {
      final state = ChatScreenState(messages: [_event('vrcExchangeInitiated')]);
      expect(!state.hasVrcExchangeInitiated, isFalse);
    });
  });
}
