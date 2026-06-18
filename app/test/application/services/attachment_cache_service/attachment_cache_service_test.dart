import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/attachment_cache_service/attachment_cache_service.dart';
import 'package:mpx_flutter_reference_app/application/services/attachment_cache_service/chat_media_bytes_cache.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../fakes/fake_app_badge_service.dart';
import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_sdk.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/attach_cache_test.log'),
  );

  group('AttachmentCacheService', () {
    late ProviderContainer container;
    late AttachmentCacheService service;
    late FakeChatSdk fakeChatSdk;
    late _FakeChatSessionService fakeChatSession;

    final testContact = FakeContacts.individualContact;
    final contactId = testContact.id;
    final channelDid = testContact.channelDid!;

    List<Override> buildOverrides() {
      final fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {channelDid: FakeChannels.individualChannel},
      );
      fakeChatSdk = FakeChatSdk();
      final fakeContactsService = FakeContactsService();

      return [
        meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
        chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
        contactsServiceProvider.overrideWith(() => fakeContactsService),
        environmentProvider.overrideWithValue(FakeEnvironment()),
        appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
        networkConnectivityServiceProvider.overrideWith(
          _FakeNetworkConnectivityService.new,
        ),
        // The cache service resolves its ChatService from this provider; a thin
        // fake lets media download/probe paths be driven without a live session.
        chatSessionServiceProvider(channelDid).overrideWith(() {
          fakeChatSession = _FakeChatSessionService();
          return fakeChatSession;
        }),
      ];
    }

    setUp(() async {
      container = ProviderContainer(overrides: buildOverrides());
      container.listen(
        attachmentCacheServiceProvider(contactId),
        (previous, value) {},
        fireImmediately: true,
      );
      service = container.read(
        attachmentCacheServiceProvider(contactId).notifier,
      );
    });

    tearDown(() => container.dispose());

    test('seed writes base64 bytes into cache', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final attachment = ChatAttachment(
        data: ChatAttachmentData(base64: base64Encode(bytes)),
      );

      service.seed(attachment);

      expect(
        service.state[AttachmentCacheService.cacheKey(attachment)],
        equals(bytes),
      );
    });

    test('seed ignores attachment with no base64 data', () {
      final attachment = ChatAttachment();

      service.seed(attachment);

      expect(service.state, isEmpty);
    });

    test('seed handles invalid base64 without throwing', () {
      final attachment = ChatAttachment(
        data: ChatAttachmentData(base64: 'not-valid-base64!!!'),
      );

      expect(() => service.seed(attachment), returnsNormally);
      expect(service.state, isEmpty);
    });

    test('loadAttachment writes base64 bytes into cache', () {
      final bytes = Uint8List.fromList([10, 20, 30]);
      final attachment = ChatAttachment(
        data: ChatAttachmentData(base64: base64Encode(bytes)),
      );

      service.loadAttachment(attachment);

      expect(
        service.state[AttachmentCacheService.cacheKey(attachment)],
        equals(bytes),
      );
    });

    test('loadAttachment skips if already cached', () {
      final bytes = Uint8List.fromList([7, 8, 9]);
      final attachment = ChatAttachment(
        data: ChatAttachmentData(base64: base64Encode(bytes)),
      );

      service.loadAttachment(attachment);
      final stateAfterFirst = service.state;

      service.loadAttachment(attachment);

      expect(identical(service.state, stateAfterFirst), isTrue);
    });

    test('loadAttachment handles invalid base64 without throwing', () {
      final attachment = ChatAttachment(
        data: ChatAttachmentData(base64: '!!!invalid!!!'),
      );

      expect(() => service.loadAttachment(attachment), returnsNormally);
      expect(service.state, isEmpty);
    });

    test('loadAttachment skips hosted media with no transportId', () {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
      );

      service.loadAttachment(attachment);

      expect(service.state, isEmpty);
    });

    test(
      'preload triggers download for hosted image attachment with transportId',
      () async {
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
          mediaType: 'image/jpeg',
          data: ChatAttachmentData(base64: base64Encode([1, 2, 3])),
        )..transportId = 'test-transport-id';
        final message = Message(
          chatId: 'fake-chat-id',
          messageId: 'fake-msg-id',
          value: '',
          dateCreated: DateTime.now(),
          status: ChatItemStatus.confirmed,
          isFromMe: false,
          senderDid: 'fake-sender-did',
          attachments: [attachment],
        );

        service.preload([message]);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final key = AttachmentCacheService.cacheKey(attachment);
        expect(service.state.containsKey(key), isTrue);
      },
    );

    test('preload defers hosted video until explicitly requested', () async {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'video/mp4',
      )..transportId = 'video-transport-id';
      final message = Message(
        chatId: 'fake-chat-id',
        messageId: 'fake-video-msg-id',
        value: '',
        dateCreated: DateTime.now(),
        status: ChatItemStatus.confirmed,
        isFromMe: false,
        senderDid: 'fake-sender-did',
        attachments: [attachment],
      );

      service.preload([message]);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final key = AttachmentCacheService.cacheKey(attachment);
      expect(service.state.containsKey(key), isFalse);
    });

    test('preload triggers download for hosted audio attachment', () async {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'audio/mp4',
        data: ChatAttachmentData(base64: base64Encode([4, 5, 6])),
      )..transportId = 'audio-transport-id';
      final message = Message(
        chatId: 'fake-chat-id',
        messageId: 'fake-audio-msg-id',
        value: '',
        dateCreated: DateTime.now(),
        status: ChatItemStatus.confirmed,
        isFromMe: false,
        senderDid: 'fake-sender-did',
        attachments: [attachment],
      );

      service.preload([message]);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final key = AttachmentCacheService.cacheKey(attachment);
      expect(service.state.containsKey(key), isTrue);
    });

    test('preload failure does not write failed marker', () async {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'audio/mp4',
      )..transportId = 'missing-media-transport-id';
      final message = Message(
        chatId: 'fake-chat-id',
        messageId: 'fake-audio-fail-msg-id',
        value: '',
        dateCreated: DateTime.now(),
        status: ChatItemStatus.confirmed,
        isFromMe: false,
        senderDid: 'fake-sender-did',
        attachments: [attachment],
      );

      service.preload([message]);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final key = AttachmentCacheService.cacheKey(attachment);
      expect(service.state.containsKey(key), isFalse);
    });

    test('auto-load stops retrying once the backoff schedule is exhausted', () {
      fakeAsync((async) {
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
          mediaType: 'image/png',
        )..transportId = 'missing-media-transport-id';

        service.autoLoad(attachment);
        async.flushMicrotasks();

        // A failed auto-load schedules a backoff retry instead of giving up.
        expect(async.pendingTimers, isNotEmpty);

        // Exhaust the full backoff schedule (0.5 + 1 + 2 + 4 + 8 + 8 = 23.5s).
        async.elapse(const Duration(seconds: 24));

        // The retry schedule is bounded: nothing is left pending and the cache
        // is never poisoned with a failed marker.
        expect(async.pendingTimers, isEmpty);
        final key = AttachmentCacheService.cacheKey(attachment);
        expect(service.state.containsKey(key), isFalse);
      });
    });

    test('disposing the service cancels pending auto-load retries', () {
      fakeAsync((async) {
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
          mediaType: 'image/png',
        )..transportId = 'missing-media-transport-id';

        service.autoLoad(attachment);
        async.flushMicrotasks();
        expect(async.pendingTimers, isNotEmpty);

        container.dispose();

        // onDispose cancels the scheduled retry timer.
        expect(async.pendingTimers, isEmpty);
        async.elapse(const Duration(seconds: 24));
      });
    });

    test('loading an image populates the shared warm cache', () {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'image/jpeg',
        data: ChatAttachmentData(base64: base64Encode([1, 2, 3])),
      )..transportId = 'warm-cache-transport-id';
      final key = AttachmentCacheService.cacheKey(attachment);

      service.loadAttachment(attachment);

      final warmCache = container.read(chatMediaBytesCacheProvider);
      expect(warmCache.snapshotFor(contactId)[key], [1, 2, 3]);
    });

    test('video bytes are not added to the warm cache', () {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'video/mp4',
        data: ChatAttachmentData(base64: base64Encode([9, 9, 9])),
      )..transportId = 'warm-cache-video-id';
      final key = AttachmentCacheService.cacheKey(attachment);

      service.loadAttachment(attachment);

      final warmCache = container.read(chatMediaBytesCacheProvider);
      expect(warmCache.snapshotFor(contactId).containsKey(key), isFalse);
    });

    test('re-entering a chat seeds its cache from the warm cache', () {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'image/jpeg',
      )..transportId = 'seeded-transport-id';
      final key = AttachmentCacheService.cacheKey(attachment);

      // A previous visit left the image in the process-lifetime warm cache.
      final warmCache = ChatMediaBytesCache()
        ..put(contactId, key, Uint8List.fromList([1, 2, 3]));

      final reopenedContainer = ProviderContainer(
        overrides: [
          ...buildOverrides(),
          chatMediaBytesCacheProvider.overrideWithValue(warmCache),
        ],
      );
      addTearDown(reopenedContainer.dispose);
      reopenedContainer.listen(
        attachmentCacheServiceProvider(contactId),
        (previous, value) {},
        fireImmediately: true,
      );
      final reopenedService = reopenedContainer.read(
        attachmentCacheServiceProvider(contactId).notifier,
      );

      // The freshly opened chat starts with the image already present, so no
      // spinner or re-download is needed.
      expect(reopenedService.state[key], [1, 2, 3]);
    });

    test(
      'restoreFromLocalCache seeds state from the local media cache',
      () async {
        final bytes = Uint8List.fromList([5, 6, 7]);
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
          mediaType: 'video/mp4',
        )..transportId = 'cached-video-id';
        fakeChatSession.localMedia['cached-video-id'] = bytes;

        await service.restoreFromLocalCache(attachment);

        final key = AttachmentCacheService.cacheKey(attachment);
        expect(service.state[key], equals(bytes));
        // The probe must be cache-only, never a network download.
        expect(fakeChatSession.downloadMediaLocalOnlyCalls, [true]);
      },
    );

    test(
      'restoreFromLocalCache leaves the cache untouched on a miss',
      () async {
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
          mediaType: 'video/mp4',
        )..transportId = 'uncached-video-id';

        await service.restoreFromLocalCache(attachment);

        // No bytes and no failed marker, so the download affordance stays.
        final key = AttachmentCacheService.cacheKey(attachment);
        expect(service.state.containsKey(key), isFalse);
      },
    );

    test('restoreFromLocalCache skips media with no transportId', () async {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'video/mp4',
      );

      await service.restoreFromLocalCache(attachment);

      expect(service.state, isEmpty);
      expect(fakeChatSession.downloadMediaLocalOnlyCalls, isEmpty);
    });

    test(
      'restoreFromLocalCache does not clobber bytes cached during the probe',
      () async {
        final probeBytes = Uint8List.fromList([9, 9, 9]);
        final downloadedBytes = Uint8List.fromList([1, 2, 3]);
        final attachment = ChatAttachment(
          format: AttachmentFormat.hostedMedia.value,
          mediaType: 'video/mp4',
          data: ChatAttachmentData(base64: base64Encode(downloadedBytes)),
        )..transportId = 'racing-video-id';
        fakeChatSession.localMedia['racing-video-id'] = probeBytes;
        final gate = Completer<void>();
        fakeChatSession.downloadGate = gate;

        final future = service.restoreFromLocalCache(attachment);
        // A user-tapped download lands while the probe is still in flight.
        service.loadAttachment(attachment);
        gate.complete();
        await future;

        final key = AttachmentCacheService.cacheKey(attachment);
        expect(service.state[key], equals(downloadedBytes));
      },
    );

    test('restoreFromLocalCache does not write after disposal', () async {
      final attachment = ChatAttachment(
        format: AttachmentFormat.hostedMedia.value,
        mediaType: 'video/mp4',
      )..transportId = 'disposed-video-id';
      fakeChatSession.localMedia['disposed-video-id'] = Uint8List.fromList([
        4,
        2,
      ]);
      final gate = Completer<void>();
      fakeChatSession.downloadGate = gate;

      final future = service.restoreFromLocalCache(attachment);
      container.dispose();
      gate.complete();

      // The post-await disposal guard skips the write instead of throwing.
      await expectLater(future, completes);
    });
  });
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}

/// Thin [ChatSessionService] that skips session wiring and serves media from an
/// in-memory map, so the cache service's download and local-probe paths can be
/// exercised in isolation. An absent transportId throws, mirroring a miss.
class _FakeChatSessionService extends ChatSessionService {
  final Map<String, Uint8List> localMedia = {};
  Completer<void>? downloadGate;
  final List<bool> downloadMediaLocalOnlyCalls = [];

  @override
  ChatServiceState build(String channelDid) => ChatServiceState();

  @override
  Future<Uint8List> downloadMedia(
    ChatAttachment attachment, {
    bool localOnly = false,
  }) async {
    downloadMediaLocalOnlyCalls.add(localOnly);
    final gate = downloadGate;
    if (gate != null) await gate.future;
    final id = attachment.transportId;
    final bytes = id == null ? null : localMedia[id];
    if (bytes == null) {
      throw StateError('No media cached for transportId $id');
    }
    return bytes;
  }
}
