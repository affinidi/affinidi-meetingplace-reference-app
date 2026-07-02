import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// Fake [AudioVideoCallSession] for testing that allows manual state emission.
class MockAudioVideoCallSession implements AudioVideoCallSession {
  final StreamController<AudioVideoCallState> _stateController =
      StreamController.broadcast();

  @override
  Stream<AudioVideoCallState> get state => _stateController.stream;

  /// Emits a state to the stream.
  Future<void> emitState(AudioVideoCallState state) {
    _stateController.add(state);
    return Future.microtask(() {});
  }

  int hangUpCalls = 0;

  @override
  Future<void> hangUp() async {
    hangUpCalls++;
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {}

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {}

  @override
  Future<void> setCameraEnabled(bool enabled) async {}

  @override
  Future<void> switchCamera() async {}

  void dispose() => _stateController.close();
}
