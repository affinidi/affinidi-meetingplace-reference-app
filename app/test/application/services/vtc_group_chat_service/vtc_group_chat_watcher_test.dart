import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_watcher.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';

/// Records the order the watcher asks for each step of a sync.
class _FakeVtcGroupChatService extends Fake implements VtcGroupChatService {
  final calls = <String>[];

  /// Holds each join open until completed, when set.
  Completer<void>? gate;

  @override
  Future<void> joinGroupChats() async {
    calls.add('join');
    await gate?.future;
  }

  @override
  Future<void> syncChats() async => calls.add('sync');

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

/// Lets a test say when a membership changes or a message arrives.
class _FakeVtcService extends Fake implements VtcService {
  final membershipChanges = StreamController<void>.broadcast();
  final arrivals = StreamController<String>.broadcast();

  @override
  Stream<void> get membershipsChanged => membershipChanges.stream;

  @override
  Stream<String> get inboxArrived => arrivals.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VtcGroupChatWatcher.sync', () {
    test("joins the member's group chats before bringing owned chats in "
        'step', () async {
      final service = _FakeVtcGroupChatService();

      await VtcGroupChatWatcher(service).sync();

      expect(service.calls, ['join', 'sync']);
    });

    test('syncs once more when asked while a sync is running', () async {
      final service = _FakeVtcGroupChatService()..gate = Completer();
      final watcher = VtcGroupChatWatcher(service);

      final first = watcher.sync();
      final second = watcher.sync();
      final third = watcher.sync();
      service.gate!.complete();
      await Future.wait([first, second, third]);

      expect(service.calls, ['join', 'sync', 'join', 'sync']);
    });

    test('syncs once when not asked again meanwhile', () async {
      final service = _FakeVtcGroupChatService()..gate = Completer();
      final watcher = VtcGroupChatWatcher(service);

      final first = watcher.sync();
      service.gate!.complete();
      await first;

      expect(service.calls, ['join', 'sync']);
    });
  });

  group('vtcGroupChatWatcherProvider', () {
    late _FakeVtcGroupChatService service;
    late _FakeVtcService vtc;
    late ProviderContainer container;

    setUp(() async {
      service = _FakeVtcGroupChatService();
      vtc = _FakeVtcService();
      container = ProviderContainer(
        overrides: [
          vtcGroupChatServiceProvider.overrideWithValue(service),
          vtcServiceProvider.overrideWithValue(vtc),
        ],
      );
      await container.read(vtcGroupChatWatcherProvider).sync();
      service.calls.clear();
    });

    tearDown(() => container.dispose());

    test('syncs as a message reaches a watched community inbox', () async {
      vtc.arrivals.add('did:webvh:QmVtc:vtc.example');
      await pumpEventQueue();

      expect(service.calls, ['join', 'sync']);
    });

    test('stops syncing on arrivals once disposed', () async {
      container.dispose();
      vtc.arrivals.add('did:webvh:QmVtc:vtc.example');
      await pumpEventQueue();

      expect(service.calls, isEmpty);
    });
  });
}
