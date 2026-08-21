import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/missed_call_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/contacts_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../fakes/fake_call_chat_item_manager.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_repository.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../mocks/mock_app_logger.dart';

// =========================================================================
// Missed-call badge credit recovery — durable double-credit regression.
//
// Reproduces the two paths where a credit lands once but the durable "owed"
// state stays set, so a post-restart heal (fresh in-memory dedup) credits the
// SAME episode again (badge == 2). Both must settle to exactly one credit.
// The harness wires the REAL ContactsService (its persistence-merge logic is
// under test) to a MissedCallManager and a fake call-item manager. A "restart"
// is a second container reading the same repository — persisted state survives,
// in-memory _creditedMissedCallIds does not.
// =========================================================================

ProviderContainer _container(FakeContactsRepository repository) =>
    ProviderContainer(
      overrides: [
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
        environmentProvider.overrideWithValue(FakeEnvironment()),
        contactsRepositoryProvider.overrideWith((ref) async => repository),
        meetingPlaceSdkProvider.overrideWith(
          (ref) async => FakeMeetingPlaceSDK(),
        ),
      ],
    );

Ref _refOf(ProviderContainer container) =>
    container.read(Provider<Ref>((ref) => ref));

ContactsService _serviceOf(
  ProviderContainer container,
  FakeContactsRepository repository,
) {
  final service = container.read(contactsServiceProvider.notifier);
  service.state = service.state.copyWith(
    contacts: List<Contact>.from(repository.contacts),
  );
  return service;
}

Message _incomingCallMessage({
  required String channelDid,
  required String messageId,
  required DateTime dateCreated,
}) => Message(
  chatId: 'chat-123',
  messageId: messageId,
  value: '',
  dateCreated: dateCreated,
  status: ChatItemStatus.confirmed,
  isFromMe: false,
  senderDid: channelDid,
  attachments: [
    CallMetadata.buildAttachment(
      id: const Uuid().v4(),
      mediaType: CallMediaType.video,
      status: CallStatus.calling,
      callId: 'call-123',
    ),
  ],
);

void main() {
  int badgeOf(FakeContactsRepository repository, String channelDid) =>
      repository.contacts
          .firstWhere((c) => c.channelDid == channelDid)
          .badgeCount;

  group('missed-call badge credit recovery — durable double-credit', () {
    test(
      'Path (a) — group dual-signal miss: one bump fails, one succeeds for the '
      'same episode; the credit lands once and is NOT re-applied after a '
      'restart',
      () async {
        final contact = FakeContacts.individualContact.copyWith(
          badgeCount: 0,
          missedCallCount: 0,
        );
        final channelDid = contact.channelDid!;
        final repository = FakeContactsRepository(contacts: [contact]);

        final container = _container(repository);
        addTearDown(container.dispose);
        final service = _serviceOf(container, repository);

        // Signal A (the real-callId signal): the bump throws, so no credit
        // lands; the durable marker is written for the episode.
        repository.failUpdateWhen = (_) => true;
        await expectLater(
          service.incrementMissedCallBadge(channelDid, callId: 'miss-X'),
          throwsA(isA<Exception>()),
        );
        repository.failUpdateWhen = null;
        await service.setPendingMissedCall(
          channelDid,
          callId: 'real-call-id',
          missId: 'miss-X',
        );

        // Signal B (the trailing broadcast signal, null transport callId): the
        // bump now succeeds, crediting the SAME episode exactly once. The null
        // transport callId makes the persistence merge fire, so this exercises
        // the sticky lastCreditedMissId rule.
        await service.incrementMissedCallBadge(channelDid, callId: 'miss-X');
        await service.setPendingMissedCall(
          channelDid,
          callId: null,
          missId: 'miss-X',
        );

        expect(
          badgeOf(repository, channelDid),
          1,
          reason: 'the episode is credited exactly once by the successful bump',
        );

        // Restart: a fresh container/service on the same repository has an
        // empty in-memory dedup set. A background stream re-heal (chat closed)
        // must NOT re-credit the already-credited episode.
        final container2 = _container(repository);
        addTearDown(container2.dispose);
        final service2 = _serviceOf(container2, repository);
        final marker = await service2.getPendingMissedCallAt(channelDid);
        final manager = MissedCallManager(
          ref: _refOf(container2),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: FakeCallChatItemManager(isStaleReturn: true),
          onUpsertChatItem: (_) {},
        );

        await manager.healArrivedStaleCallItemIfPending(
          _incomingCallMessage(
            channelDid: channelDid,
            messageId: 'msg-a',
            dateCreated: marker!.subtract(const Duration(minutes: 1)),
          ),
        );

        expect(
          badgeOf(repository, channelDid),
          1,
          reason:
              'the credit must not be re-applied across a restart — exactly '
              'one credit per episode',
        );
      },
    );

    test(
      'Path (b) — deferred clear: a reconcile heals an unrelated stale item '
      '(crediting the owed episode) but keeps the marker because the marked '
      'item has not synced; a later restart heal must NOT re-credit',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        // The episode is owed: the initial bump failed at record time, so no
        // successful bump has recorded miss-Y as credited. Owed is derived —
        // pendingMissedCallMissId ('miss-Y') != lastCreditedMissId (null).
        final contact = FakeContacts.individualContact.copyWith(
          badgeCount: 0,
          missedCallCount: 0,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'marked-call-not-synced',
          pendingMissedCallMissId: 'miss-Y',
        );
        final channelDid = contact.channelDid!;
        final repository = FakeContactsRepository(contacts: [contact]);

        final container = _container(repository);
        addTearDown(container.dispose);
        // Populate the service state so the replay bump can find the contact.
        _serviceOf(container, repository);

        // Reconcile heals an UNRELATED stale item (crediting the owed episode)
        // but the marked item has not synced, so the marker is kept.
        final unrelated = _incomingCallMessage(
          channelDid: channelDid,
          messageId: 'msg-unrelated',
          dateCreated: markerTime.subtract(const Duration(minutes: 2)),
        );
        final manager = MissedCallManager(
          ref: _refOf(container),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: FakeCallChatItemManager(
            isStaleReturn: true,
            staleItemsReturn: [unrelated],
          ),
          onUpsertChatItem: (_) {},
        );

        await manager.reconcilePendingMissedCall();

        expect(
          badgeOf(repository, channelDid),
          1,
          reason:
              'the owed episode is credited once when the unrelated heal '
              'runs',
        );

        // Restart: the marked item finally syncs via the stream. The heal must
        // NOT re-credit the already-credited episode.
        final container2 = _container(repository);
        addTearDown(container2.dispose);
        final service2 = _serviceOf(container2, repository);
        final marked = _incomingCallMessage(
          channelDid: channelDid,
          messageId: 'marked',
          dateCreated: markerTime.subtract(const Duration(seconds: 5)),
        );
        final manager2 = MissedCallManager(
          ref: _refOf(container2),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: FakeCallChatItemManager(isStaleReturn: true),
          onUpsertChatItem: (_) {},
        );
        // Silence unused-variable lint for the rehydrated service handle.
        expect(service2, isNotNull);

        await manager2.healArrivedStaleCallItemIfPending(marked);

        expect(
          badgeOf(repository, channelDid),
          1,
          reason:
              'the credit must not be re-applied across a restart — exactly '
              'one credit per episode',
        );
      },
    );
  });
}
