import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_watcher.dart';

/// Records the order the watcher asks for each step of a sync.
class _FakeVtcGroupChatService extends Fake implements VtcGroupChatService {
  final calls = <String>[];

  @override
  Future<void> joinGroupChats() async => calls.add('join');

  @override
  Future<void> syncChats() async => calls.add('sync');
}

void main() {
  group('VtcGroupChatWatcher.sync', () {
    test("joins the member's group chats before bringing owned chats in "
        'step', () async {
      final service = _FakeVtcGroupChatService();

      await VtcGroupChatWatcher(service).sync();

      expect(service.calls, ['join', 'sync']);
    });
  });
}
