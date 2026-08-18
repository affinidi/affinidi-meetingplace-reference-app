import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// Fake [AudioVideoCallSession] for testing that allows manual state emission.
class MockAudioVideoCallSession implements AudioVideoCallSession {
  final StreamController<AudioVideoCallState> _stateController =
      StreamController.broadcast();
  final StreamController<CallParticipantEvent> _participantController =
      StreamController.broadcast();

  int hangUpCalls = 0;

  // Latest state emitted, replayed to late subscribers so a fresh listen
  // (matching the real session's documented "emits immediately with the
  // current state" contract) never misses the current value.
  AudioVideoCallState _latestState = AudioVideoCallState.initial;

  @override
  Stream<AudioVideoCallState> get state {
    late final StreamController<AudioVideoCallState> controller;
    StreamSubscription<AudioVideoCallState>? sourceSubscription;
    controller = StreamController<AudioVideoCallState>(
      onListen: () {
        sourceSubscription = _stateController.stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        controller.add(_latestState);
      },
      onCancel: () => sourceSubscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Stream<CallParticipantEvent> get participantEvents =>
      _participantController.stream;

  /// Emits a state to the stream.
  Future<void> emitState(AudioVideoCallState state) {
    _latestState = state;
    _stateController.add(state);
    return Future.microtask(() {});
  }

  /// Emits a participant event to the stream.
  Future<void> emitParticipantEvent(CallParticipantEvent event) {
    _participantController.add(event);
    return Future.microtask(() {});
  }

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

  void dispose() {
    _stateController.close();
    _participantController.close();
  }
}
