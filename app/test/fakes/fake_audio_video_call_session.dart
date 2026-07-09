import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import 'fake_meeting_place_matrix_sdk.dart';

class FakeAudioVideoCallSession implements DisposableAudioVideoCallSession {
  final StreamController<AudioVideoCallState> _stateController =
      StreamController.broadcast();
  final StreamController<CallParticipantEvent> _participantController =
      StreamController.broadcast();

  int hangUpCalls = 0;
  int setSpeakerphoneEnabledCalls = 0;
  bool? lastSpeakerphoneEnabled;

  @override
  void emitAudioVideoCallState(AudioVideoCallState state) {
    emit(state);
  }

  @override
  Stream<AudioVideoCallState> get state => _stateController.stream;

  @override
  Stream<CallParticipantEvent> get participantEvents =>
      _participantController.stream;

  void emit(AudioVideoCallState state) {
    _stateController.add(state);
  }

  Future<void> emitState(AudioVideoCallState state) {
    emit(state);
    return Future.microtask(() {});
  }

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
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    setSpeakerphoneEnabledCalls++;
    lastSpeakerphoneEnabled = enabled;
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {}

  @override
  Future<void> switchCamera() async {}

  @override
  void dispose() {
    _stateController.close();
    _participantController.close();
  }
}
