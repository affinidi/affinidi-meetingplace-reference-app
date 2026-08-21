import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/call_log_service/call_log_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../mocks/fake_app_logger.dart';

/// One recorded call to [_RecordingChatRepository.listMessagesByMediaKind].
typedef _MediaKindQuery = ({String chatId, String mediaKind, int? limit});

/// Records every invocation instead of delegating to an in-memory store, so
/// the test can assert exactly which repository method `callLogEntries`
/// calls. That is the only discriminator between the old unbounded
/// `listMessages` query and the new bounded `listMessagesByMediaKind` one:
/// both produce identical output once [CallMetadata.maybeOf] filters the
/// result down to call items, so an output-only assertion would pass on the
/// old code too.
class _RecordingChatRepository implements ChatRepository {
  _RecordingChatRepository(this._callMessages);

  final List<ChatItem> _callMessages;

  final List<String> listMessagesCalls = [];
  final List<_MediaKindQuery> listMessagesByMediaKindCalls = [];

  @override
  Future<List<ChatItem>> listMessages(String chatId) async {
    listMessagesCalls.add(chatId);
    return [];
  }

  @override
  Future<List<ChatItem>> listMessagesByMediaKind(
    String chatId, {
    required String mediaKind,
    int? limit,
  }) async {
    listMessagesByMediaKindCalls.add((
      chatId: chatId,
      mediaKind: mediaKind,
      limit: limit,
    ));
    return _callMessages;
  }

  @override
  Future<ChatItem> createMessage(ChatItem message) =>
      throw UnimplementedError('not used by callLogEntries');

  @override
  Future<ChatItem> updateMesssage(ChatItem message) =>
      throw UnimplementedError('not used by callLogEntries');

  @override
  Future<ChatItem?> getMessage({
    required String chatId,
    required String messageId,
  }) => throw UnimplementedError('not used by callLogEntries');

  @override
  Future<String?> getSyncMarker(String chatId) =>
      throw UnimplementedError('not used by callLogEntries');

  @override
  Future<void> updateSyncMarker({
    required String chatId,
    required String eventId,
  }) => throw UnimplementedError('not used by callLogEntries');
}

/// Seeds [ContactsService] state directly and makes `ensureInitialized` a
/// no-op, so `callLogEntries` sees a fixed contact list without touching a
/// real contacts repository.
class _TestContactsService extends ContactsService {
  _TestContactsService(this._contacts);

  final List<Contact> _contacts;

  @override
  ContactsServiceState build() => ContactsServiceState(contacts: _contacts);

  @override
  Future<void> ensureInitialized() async {}
}

Message _callMessage({
  required String chatId,
  required String messageId,
  required String senderDid,
  required bool isFromMe,
  required CallStatus status,
  required DateTime dateCreated,
  int? durationMs,
}) => Message(
  chatId: chatId,
  messageId: messageId,
  value: '',
  dateCreated: dateCreated,
  status: ChatItemStatus.confirmed,
  isFromMe: isFromMe,
  senderDid: senderDid,
  attachments: [
    CallMetadata.buildAttachment(
      id: const Uuid().v4(),
      mediaType: CallMediaType.video,
      status: status,
      callId: messageId,
      durationMs: durationMs,
    ),
  ],
);

ProviderContainer _buildContainer({
  required _RecordingChatRepository chatRepository,
  required List<Contact> contacts,
  required FakeMeetingPlaceSDK coreSdk,
}) {
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      contactsServiceProvider.overrideWith(
        () => _TestContactsService(contacts),
      ),
      chatRepositoryProvider.overrideWith((ref) async => chatRepository),
      meetingPlaceSdkProvider.overrideWith((ref) async => coreSdk),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final contact = FakeContacts.individualContact;
  final channelDid = contact.channelDid!;
  final channel = FakeChannels.individualChannel;
  final expectedChatId = Chat.deriveId(
    did: channel.permanentChannelDid!,
    otherPartyDid: channel.otherPartyPermanentChannelDid!,
  );

  group('callLogEntries', () {
    test('switches to the call-only listMessagesByMediaKind query and maps the '
        'resulting call messages sorted most-recent-first', () async {
      final olderCall = _callMessage(
        chatId: expectedChatId,
        messageId: 'call-1',
        senderDid: channelDid,
        isFromMe: true,
        status: CallStatus.ended,
        dateCreated: DateTime.utc(2026, 1, 1, 10),
        durationMs: 15000,
      );
      final newerCall = _callMessage(
        chatId: expectedChatId,
        messageId: 'call-2',
        senderDid: channelDid,
        isFromMe: false,
        status: CallStatus.missed,
        dateCreated: DateTime.utc(2026, 1, 2, 9),
      );

      final chatRepository = _RecordingChatRepository([olderCall, newerCall]);
      final coreSdk = FakeMeetingPlaceSDK(channels: {channelDid: channel});
      final container = _buildContainer(
        chatRepository: chatRepository,
        contacts: [contact],
        coreSdk: coreSdk,
      );

      final entries = await container.read(callLogEntriesProvider.future);

      // 1. Real output: the SUT's channel-resolve -> maybeOf -> entry-build
      // -> sort pipeline ran for real and produced correct entries, most
      // recent first.
      expect(entries, hasLength(2));

      expect(entries[0].contactId, contact.id);
      expect(entries[0].status, CallStatus.missed);
      expect(entries[0].mediaType, CallMediaType.video);
      expect(entries[0].durationMs, isNull);
      expect(entries[0].isFromMe, isFalse);
      expect(entries[0].participantCount, 1);
      expect(entries[0].timestamp, newerCall.dateCreated);

      expect(entries[1].contactId, contact.id);
      expect(entries[1].status, CallStatus.ended);
      expect(entries[1].mediaType, CallMediaType.video);
      expect(entries[1].durationMs, 15000);
      expect(entries[1].isFromMe, isTrue);
      expect(entries[1].participantCount, 1);
      expect(entries[1].timestamp, olderCall.dateCreated);

      // 2. The switch: the bounded call-only query was used, for the
      // right chat, asking for call-kind media, with no limit applied.
      expect(chatRepository.listMessagesByMediaKindCalls, hasLength(1));
      final query = chatRepository.listMessagesByMediaKindCalls.single;
      expect(query.chatId, expectedChatId);
      expect(query.mediaKind, CallMetadata.callKind);
      expect(query.limit, isNull);

      // 3. The guard: this fails on the old code (which called
      // listMessages) and passes on the new.
      expect(chatRepository.listMessagesCalls, isEmpty);
    });
  });
}
