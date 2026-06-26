import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_livekit_flutter/src/room/flutter_livekit_room.dart';

void main() {
  group('FlutterLiveKitRoom', () {
    test('participants returns empty list when room is not connected', () {
      final room = FlutterLiveKitRoom();
      expect(room.participants, isEmpty);
    });

    test('ownParticipantId is null when room is not connected', () {
      final room = FlutterLiveKitRoom();
      expect(room.ownParticipantId, isNull);
    });

    test(
      'disconnect completes without error when room was never connected',
      () async {
        final room = FlutterLiveKitRoom();
        await expectLater(room.disconnect(), completes);
      },
    );

    test('setMicrophoneEnabled no-ops when room is not connected', () async {
      final room = FlutterLiveKitRoom();
      await expectLater(room.setMicrophoneEnabled(true), completes);
    });

    test('setCameraEnabled no-ops when room is not connected', () async {
      final room = FlutterLiveKitRoom();
      await expectLater(room.setCameraEnabled(true), completes);
    });

    test('switchCamera no-ops when room is not connected', () async {
      final room = FlutterLiveKitRoom();
      await expectLater(room.switchCamera(), completes);
    });

    test('forceRemoteKeyframe no-ops when room is not connected', () async {
      final room = FlutterLiveKitRoom();
      await expectLater(
        room.forceRemoteKeyframe('@alice:example.org'),
        completes,
      );
    });
  });
}
