import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/missed_call_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:uuid/uuid.dart';

import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_chat_session_service.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';
import 'mocks/mock_app_logger.dart';

const _callerDid = 'did:key:caller';
const _callId = 'call-1';
const _itemId = 'incoming-call-item';

class _FakeMeetingPlaceMatrixSDK extends Fake implements MeetingPlaceMatrixSDK {
  final _incoming = StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final _cancelled = StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final declinedCallIds = <String>[];

  void emitIncoming(IncomingAudioVideoCallEvent event) => _incoming.add(event);

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls => _incoming.stream;
  @override
  Stream<IncomingAudioVideoCallEvent> get cancelledCalls => _cancelled.stream;
  @override
  Future<void> acceptCall({required String callId}) async {}
  @override
  Future<void> declineCall({required String callId}) async =>
      declinedCallIds.add(callId);
  @override
  Future<void> leaveCurrentCall() async {}
}

/// Contacts fake whose [setPendingMissedCall] persists the marker exactly like
/// the production store, then fires [onAfterSetPending] — modelling a chat
/// message-stream event that lands during the marker's DB-write yield.
class _RaceContactsService extends FakeContactsService {
  _RaceContactsService({super.contacts});
  Future<void> Function()? onAfterSetPending;

  @override
  Future<void> setPendingMissedCall(String channelDid, {String? callId}) async {
    await super.setPendingMissedCall(channelDid, callId: callId);
    final hook = onAfterSetPending;
    if (hook != null) await hook();
  }
}

/// Chat-session fake whose decline write runs through the REAL
/// [CallChatItemManager], so the resolve/skip/update logic under test is
/// production code, not a stub.
class _RealBackedChatSessionService extends FakeChatSessionService {
  _RealBackedChatSessionService(this.manager);
  final CallChatItemManager manager;

  @override
  Future<bool> markCallAsDeclined({String? callId}) =>
      manager.markCallAsDeclined(callId: callId);
}

Message _incomingCallItem({
  required CallStatus status,
  required DateTime dateCreated,
}) => Message(
  chatId: 'fake-chat-id',
  messageId: _itemId,
  value: '',
  dateCreated: dateCreated,
  status: ChatItemStatus.confirmed,
  isFromMe: false,
  senderDid: _callerDid,
  attachments: [
    CallMetadata.buildAttachment(
      id: const Uuid().v4(),
      mediaType: CallMediaType.video,
      status: status,
      callId: _callId,
    ),
  ],
);

CallStatus _currentStatus(FakeChatSdk sdk) {
  final item = (sdk.sessionMessages ?? const <ChatItem>[])
      .whereType<Message>()
      .firstWhere((m) => m.messageId == _itemId);
  final attachment = item.attachments.firstWhere(CallMetadata.isCall);
  return CallMetadata.maybeOf(attachment)!.status;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/incoming_call_decline_race_test.log'),
    );
  });

  const description =
      'an active decline persists as declined even when a stale-item heal '
      'races the pending-missed marker write';

  test(description, () async {
    final fakeChatSdk = FakeChatSdk()
      ..sessionMessages = [
        _incomingCallItem(
          status: CallStatus.ringing,
          dateCreated: DateTime.utc(2020, 1, 1),
        ),
      ];

    // REAL call-item manager + REAL missed-call manager share one chat SDK,
    // so isStale / resolve-skip / heal-to-missed are all production logic.
    final realManager = CallChatItemManager(
      ensureInitialized: () async {},
      getChatSdk: () => fakeChatSdk,
      logger: FakeAppLogger(),
    );

    final contactsService = _RaceContactsService(
      contacts: [
        FakeContacts.individualContact.copyWith(channelDid: _callerDid),
      ],
    );
    final chatService = _RealBackedChatSessionService(realManager);
    final fakeSDK = _FakeMeetingPlaceMatrixSDK();

    final container = ProviderContainer(
      overrides: [
        meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
        contactsServiceProvider.overrideWith(() => contactsService),
        chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
        chatSessionServiceProvider(_callerDid).overrideWith(() => chatService),
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
      ],
    );
    addTearDown(container.dispose);

    final missedManager = MissedCallManager(
      ref: container.read(Provider<Ref>((ref) => ref)),
      otherPartyPermanentChannelDid: _callerDid,
      callChatItemManager: realManager,
      onUpsertChatItem: (_) {},
    );

    // The racing heal reads the CURRENT item (as a real chat stream would):
    //  - marker-before-declined ordering -> item still ringing -> healed to
    //    missed, and the later declined write then skips the settled item;
    //  - declined-before-marker ordering  -> item already declined (terminal)
    //    -> heal sees a non-stale item and does nothing.
    contactsService.onAfterSetPending = () async {
      final current = (await fakeChatSdk.messages)
          .whereType<Message>()
          .firstWhere((m) => m.messageId == _itemId);
      await missedManager.healArrivedStaleCallItemIfPending(current);
    };

    container.read(incomingCallServiceProvider);
    await container.read(meetingPlaceSdkProvider.future);
    await pumpEventQueue();

    fakeSDK.emitIncoming(
      IncomingAudioVideoCallEvent(
        callId: _callId,
        callerPermanentChannelDid: _callerDid,
        otherPartyPermanentChannelDid: _callerDid,
        mediaType: CallMediaType.video,
        invitedAt: DateTime.utc(2020, 1, 1),
      ),
    );
    await pumpEventQueue();

    container
        .read(incomingCallServiceProvider.notifier)
        .decline(callId: _callId);

    // Let _markCallAsDeclined finish, including the resolve retry loop the
    // marker-first ordering enters after the heal settles the item.
    await Future<void>.delayed(const Duration(seconds: 1));
    await pumpEventQueue();

    expect(
      _currentStatus(fakeChatSdk),
      CallStatus.declined,
      reason:
          'An actively declined call must persist as declined. If the pending '
          'marker is written before the declined chat-item write, a stale-item '
          'heal racing the marker settles the item to missed and the declined '
          'write then skips it. The reorder (declined write first) closes that '
          'window.',
    );
  });
}
